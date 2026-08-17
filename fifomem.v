// Module: fifomem.v
// Description: Dual-port RAM memory buffer for Asynchronous FIFO
// Muhammad Shabab Rawoot

module fifomem #(
    parameter DATASIZE = 8,  
    parameter ADDRSIZE = 4   
)(
    input  wire wclk,    
    input  wire                 wclken,  // Write Enable (wclken = winc && !wfull)
    input  wire [ADDRSIZE-1:0] waddr,   // Write Address
    input  wire [DATASIZE-1:0] wdata,   // Write Data Input
    input  wire [ADDRSIZE-1:0] raddr,   // Read Address
    output wire [DATASIZE-1:0] rdata    // Read Data Output
);

    // Calculate memory depth (2^ADDRSIZE)
    localparam DEPTH = 1 << ADDRSIZE;

    // Memory array declaration: DEPTH words, each DATASIZE bits wide
    reg [DATASIZE-1:0] mem [0:DEPTH-1];

    // Read operation (Combinational/Unregistered)
    // Continuously outputs data located at the current read address
    assign rdata = mem[raddr];

    // Write operation (Synchronous to Write Clock)
    always @(posedge wclk) begin
        if (wclken) begin
            mem[waddr] <= wdata;
        end
    end

endmodule