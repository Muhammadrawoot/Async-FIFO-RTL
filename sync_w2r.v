// Module: sync_w2r.v
// Description: 2-Flop Synchronizer passing the Write Pointer into the Read Domain

module sync_w2r #(
    parameter ADDRSIZE = 4
)(
    input  wire                 rclk,      // Read Clock (Destination Domain)
    input  wire                 rrst_n,    // Read Reset (Active Low)
    input  wire [ADDRSIZE:0]    wptr,      // Async Write Pointer (From Write Domain)
    
    output reg  [ADDRSIZE:0]    rq2_wptr   // Synchronized Write Pointer
);

    // Internal register for the first flip-flop stage
    reg [ADDRSIZE:0] rq1_wptr;

    // 2-Stage Shift Register (Synchronizer)
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            // On reset, clear both flip-flops to 0
            rq1_wptr <= 0;
            rq2_wptr <= 0;
        end else begin
            // Stage 1: Sample the incoming async signal
            rq1_wptr <= wptr;      
            
            // Stage 2: Sample the output of Stage 1
            rq2_wptr <= rq1_wptr;  
        end
    end

endmodule