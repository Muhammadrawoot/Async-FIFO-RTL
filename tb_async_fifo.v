`timescale 1ns / 1ps

module tb_async_fifo();

    parameter DATASIZE = 8;
    parameter ADDRSIZE = 4;

    // Inputs
    reg winc, wclk, wrst_n;
    reg rinc, rclk, rrst_n;
    reg [DATASIZE-1:0] wdata;

    // Outputs
    wire [DATASIZE-1:0] rdata;
    wire wfull;
    wire rempty;

    // Instantiate the Top-Level FIFO
    async_fifo #(DATASIZE, ADDRSIZE) uut (
        .winc(winc), .wclk(wclk), .wrst_n(wrst_n),
        .rinc(rinc), .rclk(rclk), .rrst_n(rrst_n),
        .wdata(wdata), .rdata(rdata),
        .wfull(wfull), .rempty(rempty)
    );

    // ---------------------------------------------------------
    // DUAL CLOCK GENERATION (The Stress Test)
    // ---------------------------------------------------------
    // Write Clock: 100 MHz (10ns period) -> FAST
    always #5 wclk = ~wclk; 
    
    // Read Clock: 33.3 MHz (30ns period) -> SLOW
    always #15 rclk = ~rclk; 

    // Loop variable for generating data
    integer i;

    // ---------------------------------------------------------
    // TEST SEQUENCE
    // ---------------------------------------------------------
    initial begin
        // 1. Initialize Inputs to Zero
        wclk = 0; winc = 0; wrst_n = 0; wdata = 0;
        rclk = 0; rinc = 0; rrst_n = 0;

        // 2. Hold Reset for a few clock cycles, then release
        #40;
        wrst_n = 1;
        rrst_n = 1;
        #40;

        // 3. BURST WRITE: Fill the entire FIFO at 100MHz
        @(posedge wclk);
        for (i = 0; i < 16; i = i + 1) begin
            winc = 1;
            wdata = i + 8'hA0; // Writes Hex A0, A1, A2, A3...
            @(posedge wclk);
        end
        winc = 0; // Stop writing, FIFO should now assert 'wfull'

        // 4. WAIT: Let the pointers cross the clock domains
        #100;

        // 5. BURST READ: Empty the entire FIFO at 33MHz
        @(posedge rclk);
        for (i = 0; i < 16; i = i + 1) begin
            rinc = 1;
            @(posedge rclk);
        end
        rinc = 0; // Stop reading, FIFO should now assert 'rempty'

        // 6. Finish Simulation
        #100;
        $finish;
    end

endmodule