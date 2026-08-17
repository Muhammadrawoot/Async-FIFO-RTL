// Module: rptr_empty.v
// Description: Read Pointer (Binary & Gray) and Empty Flag Logic

module rptr_empty #(
    parameter ADDRSIZE = 4
)(
    input  wire                 rclk,      // Read Clock
    input  wire                 rrst_n,    // Read Reset (Active Low)
    input  wire                 rinc,      // Read Increment (Receiver wants to read)
    input  wire [ADDRSIZE:0]    rq2_wptr,  // Synchronized Write Pointer (Gray Code)
    
    output reg                  rempty,    // FIFO Empty Flag
    output wire [ADDRSIZE-1:0]  raddr,     // Binary Read Address (to fifomem.v)
    output reg  [ADDRSIZE:0]    rptr       // Gray Code Read Pointer (to sync_r2w.v)
);

    reg  [ADDRSIZE:0] rbin;
    wire [ADDRSIZE:0] rgraynext, rbinnext;
    wire              rempty_val;

    // 1. Next Binary Pointer Logic
    // Increment only if requested (rinc) AND the FIFO is not empty
    assign rbinnext = rbin + (rinc & ~rempty);

    // 2. Memory Address Output
    // The memory only needs the lower 4 bits (ADDRSIZE-1:0)
    assign raddr = rbin[ADDRSIZE-1:0];

    // 3. Binary-to-Gray Code Conversion (The Magic Equation)
    assign rgraynext = (rbinnext >> 1) ^ rbinnext;

    // 4. FIFO Empty Flag Logic
    // FIFO is empty if the Read Pointer completely catches up to the Write Pointer
    assign rempty_val = (rgraynext == rq2_wptr);

    // 5. Synchronous State Updates
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rbin   <= 0;
            rptr   <= 0;
            rempty <= 1'b1; // FIFO is inherently empty on reset
        end else begin
            rbin   <= rbinnext;
            rptr   <= rgraynext;
            rempty <= rempty_val;
        end
    end

endmodule