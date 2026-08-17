// Module: wptr_full.v
// Description: Write Pointer (Binary & Gray) and Full Flag Logic

module wptr_full #(
    parameter ADDRSIZE = 4
)(
    input  wire                 wclk,      // Write Clock
    input  wire                 wrst_n,    // Write Reset (Active Low)
    input  wire                 winc,      // Write Increment (Sender wants to write)
    input  wire [ADDRSIZE:0]    wq2_rptr,  // Synchronized Read Pointer (Gray Code)
    
    output reg                  wfull,     // FIFO Full Flag
    output wire [ADDRSIZE-1:0]  waddr,     // Binary Write Address (to fifomem.v)
    output reg  [ADDRSIZE:0]    wptr       // Gray Code Write Pointer (to sync_w2r.v)
);

    reg  [ADDRSIZE:0] wbin;
    wire [ADDRSIZE:0] wgraynext, wbinnext;
    wire              wfull_val;

    // 1. Next Binary Pointer Logic
    // Increment only if requested (winc) AND the FIFO is not full
    assign wbinnext = wbin + (winc & ~wfull);

    // 2. Memory Address Output
    // Strip the MSB, just like we did in the read pointer
    assign waddr = wbin[ADDRSIZE-1:0];

    // 3. Binary-to-Gray Code Conversion
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;

    // 4. FIFO Full Flag Logic (The Hard Part)
    // A FIFO is full when the MSB and 2nd MSB of the Gray pointers are opposite,
    // but all the lower bits are perfectly identical.
    assign wfull_val = (wgraynext == {~wq2_rptr[ADDRSIZE:ADDRSIZE-1], 
                                       wq2_rptr[ADDRSIZE-2:0]});

    // 5. Synchronous State Updates
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wbin  <= 0;
            wptr  <= 0;
            wfull <= 1'b0; // FIFO is inherently empty (not full) on reset
        end else begin
            wbin  <= wbinnext;
            wptr  <= wgraynext;
            wfull <= wfull_val;
        end
    end

endmodule