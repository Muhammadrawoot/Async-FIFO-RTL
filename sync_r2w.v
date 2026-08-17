// Module: sync_r2w.v
// Description: 2-Flop Synchronizer passing the Read Pointer into the Write Domain

module sync_r2w #(
    parameter ADDRSIZE = 4
)(
    input  wire                 wclk,      // Write Clock (Destination Domain)
    input  wire                 wrst_n,    // Write Reset (Active Low)
    input  wire [ADDRSIZE:0]    rptr,      // Async Read Pointer (From Read Domain)
    
    output reg  [ADDRSIZE:0]    wq2_rptr   // Synchronized Read Pointer
);

    // Internal register for the first flip-flop stage
    reg [ADDRSIZE:0] wq1_rptr;

    // 2-Stage Shift Register (Synchronizer)
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            // On reset, clear both flip-flops to 0
            wq1_rptr <= 0;
            wq2_rptr <= 0;
        end else begin
            // Stage 1: Sample the incoming async signal
            wq1_rptr <= rptr;      
            
            // Stage 2: Sample the output of Stage 1
            wq2_rptr <= wq1_rptr;  
        end
    end

endmodule