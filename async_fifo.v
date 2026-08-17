// Module: async_fifo.v
// Description: Top-level wrapper tying all 5 Async FIFO modules together

module async_fifo #(
    parameter DATASIZE = 8,
    parameter ADDRSIZE = 4
)(
    input  wire                 winc,   // Write Increment (Sender wants to write)
    input  wire                 wclk,   // Write Clock (100MHz)
    input  wire                 wrst_n, // Write Reset (Active Low)
    
    input  wire                 rinc,   // Read Increment (Receiver wants to read)
    input  wire                 rclk,   // Read Clock (33MHz)
    input  wire                 rrst_n, // Read Reset (Active Low)
    
    input  wire [DATASIZE-1:0]  wdata,  // Write Data Input
    
    output wire [DATASIZE-1:0]  rdata,  // Read Data Output
    output wire                 wfull,  // FIFO Full Flag
    output wire                 rempty  // FIFO Empty Flag
);

    // ---------------------------------------------------------
    // INTERNAL WIRES (The "solder" connecting the modules)
    // ---------------------------------------------------------
    wire [ADDRSIZE-1:0] waddr, raddr;
    wire [ADDRSIZE:0]   wptr, rptr, wq2_rptr, rq2_wptr;
    wire                wclken;

    // The memory is only enabled if the sender wants to write AND it is not full
    assign wclken = winc & ~wfull;

    // ---------------------------------------------------------
    // MODULE INSTANTIATIONS
    // ---------------------------------------------------------

    // 1. Dual-Port RAM
    fifomem #(DATASIZE, ADDRSIZE) mem_inst (
        .wclk(wclk),
        .wclken(wclken),
        .waddr(waddr),
        .wdata(wdata),
        .raddr(raddr),
        .rdata(rdata)
    );

    // 2. Read Pointer to Write Domain Synchronizer
    sync_r2w #(ADDRSIZE) sync_r2w_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .rptr(rptr),
        .wq2_rptr(wq2_rptr)
    );

    // 3. Write Pointer to Read Domain Synchronizer
    sync_w2r #(ADDRSIZE) sync_w2r_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .wptr(wptr),
        .rq2_wptr(rq2_wptr)
    );

    // 4. Read Pointer & Empty Logic
    rptr_empty #(ADDRSIZE) rptr_empty_inst (
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rq2_wptr(rq2_wptr),
        .rempty(rempty),
        .raddr(raddr),
        .rptr(rptr)
    );

    // 5. Write Pointer & Full Logic
    wptr_full #(ADDRSIZE) wptr_full_inst (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wq2_rptr(wq2_rptr),
        .wfull(wfull),
        .waddr(waddr),
        .wptr(wptr)
    );

endmodule