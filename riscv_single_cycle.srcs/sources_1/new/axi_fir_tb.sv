`timescale 1ns / 1ps

module axi_fir_tb();

    logic clk;
    logic reset;
    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;
    logic [31:0] AWADDR;
    logic AWVALID;
    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;
    logic BREADY;
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic AWREADY;
    logic WREADY;
    logic BVALID;
    logic [1:0] BRESP;

    axi_fir dut (
        .clk(clk),
        .reset(reset),

        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .RREADY(RREADY),

        .AWADDR(AWADDR),
        .AWVALID(AWVALID),

        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WVALID(WVALID),

        .BREADY(BREADY),

        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),

        .AWREADY(AWREADY),
        .WREADY(WREADY),

        .BVALID(BVALID),
        .BRESP(BRESP)
    );
    
    initial begin
        clk = 0;
        reset = 1;
        ARADDR = 32'd0;
        ARVALID = 0;
        RREADY = 0;
        AWADDR = 32'd0;
        AWVALID = 0;
        WDATA = 32'd0;
        WSTRB = 4'b0000;
        WVALID = 0;
        BREADY = 0;
        
        repeat (2) begin
            @(posedge clk);
        end
        
        #1;
        reset = 0;
        
        // TEST 1 : WRITE
        
        AWADDR = 32'h1000_3000;
        AWVALID = 1;
        
        wait (AWVALID && AWREADY) begin
            if (AWVALID && AWREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end
        
        @(posedge clk);
        #1;
        
        AWVALID = 0;
        WVALID = 1;
        WDATA  = 32'h0000_03E8; // 1000
        WSTRB  = 4'b1111;
        
        wait (WVALID && WREADY) begin
            if (WVALID && WREADY) begin
                $display("TEST PASSED: Data successful");
            end
            else begin
                $error("TEST FAILED: Data failed");
            end        
        end       
        
        @(posedge clk);
        #1;
        WVALID = 0;
        
        if (dut.fir_sample_in == 16'd1000 && dut.fir_sample_valid == 1 && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: fir_sample_in write is the right value and B response successful");
        end
        else begin
            $error("TEST FAILED: fir_sample_in is NOT the right value or B response unsuccessful");
        end
        
        BREADY = 1;
        
        @(posedge clk);
        #1;
        
        BREADY = 0;
        
        if (AWREADY == 1) begin
            $display("TEST PASSED: AWREADY = %0d", AWREADY);
        end
        else begin
            $error("TEST FAILED: AWREADY = %0d", AWREADY);
        end
        
        wait (dut.result_available == 1) begin
            #1;
            if (dut.fir_sample_out_reg == 16'hFFFC) begin
                $display("TEST PASSED: result available equals to 1 and fir output is correct");
            end
            else begin
                $error("TEST FAILED: result available equals to 1 BUT fir output is NOT correct");    
            end
        end
        
        // TEST 2 : READ STATUS
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h1000_3008;
        ARVALID = 1;                

        wait (ARVALID && ARREADY) begin
            if (ARVALID && ARREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end        
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'd1 && dut.result_available == 1) begin 
            $display("TEST PASSED: RVALID, RRESP, result_available and RDATA are correct for FIR STATUS");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP, result_available and RDATA are NOT correct for FIR STATUS");
        end
        
        RREADY = 1;
        
        @(posedge clk);
        #1;
        
        RREADY = 0;
        
        if (RVALID == 0) begin
            $display("TEST PASSED: RVALID went back to 0 (idle)");
        end
        else begin
            $error("TEST FAILED: RVALID DID NOT go back to 0 (not idle)");
        end
        
        if (dut.result_available == 1) begin 
            $display("TEST PASSED: result_available correct");
        end
        else begin
            $error("TEST FAILED: result_available incorrect");
        end
        
        // TEST 3 : READ OUTPUT
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h1000_3004;
        ARVALID = 1;

        wait (ARVALID && ARREADY) begin
            if (ARVALID && ARREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end        
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'hFFFF_FFFC && dut.result_available == 0) begin
            $display("TEST PASSED: RVALID, RRESP, result available and RDATA are correct for read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP, result available and RDATA are NOT correct for read");
        end
        
        RREADY = 1;
        
        @(posedge clk);
        #1;
        
        RREADY = 0;
        
        if (RVALID == 0) begin
            $display("TEST PASSED: RVALID went back to 0 (idle)");
        end
        else begin
            $error("TEST FAILED: RVALID DID NOT go back to 0 (not idle)");
        end        
        
        // TEST 4 : CONFIRM STATUS CLEARED
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h1000_3008;
        ARVALID = 1;                

        wait (ARVALID && ARREADY) begin
            if (ARVALID && ARREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end        
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'd0 && dut.result_available == 0) begin 
            $display("TEST PASSED: RVALID, RRESP, result_available and RDATA are correct for FIR STATUS");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP, result_available and RDATA are NOT correct for FIR STATUS");
        end
        
        RREADY = 1;
        
        @(posedge clk);
        #1;
        
        RREADY = 0;
        
        if (RVALID == 0) begin
            $display("TEST PASSED: RVALID went back to 0 (idle)");
        end
        else begin
            $error("TEST FAILED: RVALID DID NOT go back to 0 (not idle)");
        end
        
        if (dut.result_available == 0) begin 
            $display("TEST PASSED: result_available correct");
        end
        else begin
            $error("TEST FAILED: result_available incorrect");
        end
        
        // TEST 5 : INVALID WSTRB
        
        AWADDR = 32'h1000_3000;
        AWVALID = 1;
        
        wait (AWVALID && AWREADY) begin
            if (AWVALID && AWREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end
        
        @(posedge clk);
        #1;
        
        AWVALID = 0;
        WVALID = 1;
        WDATA  = 32'h0000_07D0; // 2000
        WSTRB  = 4'b0001; // invalid
        
        wait (WVALID && WREADY) begin
            if (WVALID && WREADY) begin
                $display("TEST PASSED: Data successful");
            end
            else begin
                $error("TEST FAILED: Data failed");
            end        
        end       
        
        @(posedge clk);
        #1;
        WVALID = 0;
        
        if (dut.fir_sample_in == 16'd1000 && dut.fir_sample_valid == 0 && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: fir_sample_in write is the right value and B response successful");
        end
        else begin
            $error("TEST FAILED: fir_sample_in is NOT the right value or B response unsuccessful");
        end
        
        BREADY = 1;
        
        @(posedge clk);
        #1;
        
        BREADY = 0;
        
        if (AWREADY == 1) begin
            $display("TEST PASSED: AWREADY = %0d", AWREADY);
        end
        else begin
            $error("TEST FAILED: AWREADY = %0d", AWREADY);
        end
        
        repeat (5) begin
            @(posedge clk);
        end
        #1;        

        if (dut.result_available == 0 && dut.fir_sample_out_reg == 16'hFFFC) begin
            $display("TEST PASSED: result available equals to 0 and fir output is correct");
        end
        else begin
            $error("TEST FAILED: result available equals to 0 OR fir output is NOT correct");    
        end 
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule