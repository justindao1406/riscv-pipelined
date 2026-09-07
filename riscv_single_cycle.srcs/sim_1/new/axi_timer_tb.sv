`timescale 1ns / 1ps

module axi_timer_tb();

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
    
    axi_timer dut (
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
    
    logic [31:0] count_before;

    initial begin
        reset = 1;
        clk = 0;
        ARADDR = 32'd0;
        ARVALID = 0;
        RREADY = 0;
        AWADDR = 32'd0;
        AWVALID = 0;
        WDATA = 32'd0;
        WSTRB = 4'd0;
        WVALID = 0;
        BREADY = 0;
        
        repeat (2) begin
            @(posedge clk);
        end
        
        // TEST 1 : COMPARE
        
        #1;
        reset = 0;
        
        AWADDR = 32'h1000_2008;
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
        WDATA  = 32'h000_000A; // 10
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
        
        
        if (dut.compare == 4'b1010 && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: COMPARE write is the right value and B response successful");
        end
        else begin
            $error("TEST FAILED: COMPARE is NOT the right value and B response unsuccessful");
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
        
        // TEST 2 : Enable timer
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        AWADDR = 32'h1000_2004;
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
        WDATA  = 32'h000_00001; 
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
        
        repeat (2) begin // wait a few clock cycles to see increment 
            @(posedge clk);
        end
        #1;
        
        
        if (dut.enable == 1 && dut.count > 0 && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: timer enabled and count incremented to %0d", dut.count);
        end
        else begin
            $error("TEST FAILED: timer did not enable/increment or B response unsuccessful");
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
        
        // TEST 3 : Compare match
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        wait (dut.compare_match == 1);
        #1;
        
        ARADDR = 32'h1000_200C;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h0000_0001) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for STATUS read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for STATUS read");
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
        
        // TEST 4 : disable timer
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        AWADDR = 32'h1000_2004;
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
        WDATA  = 32'h000_00000; 
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
        
        count_before = dut.count;
        
        repeat (2) begin // wait a few clock cycles to see increment 
            @(posedge clk);
        end
        #1;
        
        
        if (dut.enable == 0 && dut.count == count_before && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: timer disabled and count stayed at %0d", dut.count);
        end
        else begin
            $error("TEST FAILED: timer did not get disabled");
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
        
        // TEST 5 : clear timer
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        AWADDR = 32'h1000_2004;
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
        WDATA  = 32'h000_00002; 
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
        
        repeat (2) begin // wait a few clock cycles to see increment 
            @(posedge clk);
        end
        #1;
        
        
        if (dut.enable == 0 && dut.count == 0 && dut.compare_match == 0 &&
            BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: timer disabled, count cleared, and compare_match cleared");
        end
        else begin
            $error("TEST FAILED: timer clear unsuccessful");
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
    
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule