`timescale 1ns / 1ps

module axi_bram_tb();

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
    
    axi_bram dut (
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
        WSTRB = 4'd0;
        WVALID = 0;
        BREADY = 0;
        
        // TEST 1 : Full 32 bit WRITE
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        reset = 0;        
        
        AWADDR = 32'h0000_6464;
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
        WDATA  = 32'h1234_5678; 
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
        
        
        if (BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: B response successful");
        end
        else begin
            $error("TEST FAILED: B response unsuccessful");
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
        
        // TEST 2 : Read same address back
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h0000_6464;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h1234_5678) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for BRAM read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for BRAM read");
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
        
        // TEST 3 : Write in different address
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;      
        
        AWADDR = 32'h0000_4444;
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
        WDATA  = 32'h1234_4321; 
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
        
        
        if (BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: B response successful");
        end
        else begin
            $error("TEST FAILED: B response unsuccessful");
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
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h0000_4444;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h1234_4321) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for BRAM read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for BRAM read");
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
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h0000_6464;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h1234_5678) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for BRAM read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for BRAM read");
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
        
        // TEST 4 : Partial Byte Write 
        
        repeat (2) begin
            @(posedge clk);
        end
        #1; 
        
        AWADDR = 32'h0000_6464;
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
        WDATA  = 32'hAAAA_AA99; 
        WSTRB  = 4'b0001;
        
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
        
        
        if (BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: B response successful");
        end
        else begin
            $error("TEST FAILED: B response unsuccessful");
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
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h0000_6464;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h1234_5699) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for BRAM read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for BRAM read");
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
        
        // TEST 5 : Delayed RREADY
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h0000_6464;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h1234_5699) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for BRAM read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for BRAM read");
        end
        
        repeat (10) begin
            @(posedge clk);
        end
        #1;
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h1234_5699) begin // checking if RVALID, RRESP, RDATA has stable values
            $display("TEST PASSED: Read response held while RREADY = 0");
        end
        else begin
            $error("TEST FAILED: Read response did not hold while RREADY = 0");
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
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule