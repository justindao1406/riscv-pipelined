`timescale 1ns / 1ps

module axi_gpio_tb();

    logic clk;
    logic reset;

    // Master -> GPIO
    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;

    logic [31:0] AWADDR;
    logic AWVALID;

    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;

    logic BREADY;

    // Physical GPIO input
    logic [3:0] gpio_in;

    // GPIO -> Master
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;

    logic AWREADY;
    logic WREADY;

    logic BVALID;
    logic [1:0] BRESP;

    // Physical GPIO output
    logic [3:0] gpio_out;


    axi_gpio dut (
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

        .gpio_in(gpio_in),

        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),

        .AWREADY(AWREADY),
        .WREADY(WREADY),

        .BVALID(BVALID),
        .BRESP(BRESP),

        .gpio_out(gpio_out)
    );
    
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
        gpio_in = 4'd0;
        
        repeat (2) begin
            @(posedge clk);
        end
        
        #1;
        reset = 0;
        
        // TEST 1: Write GPIO_OUT
        
        AWADDR = 32'h1000_0000;
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
        
        
        if (gpio_out == 4'b1010 && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: gpio_out write is the right value and B response successful");
        end
        else begin
            $error("TEST FAILED: gpio_write is NOT the right value and B response unsuccessful");
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
        
        // TEST 2: Read GPIO_OUT
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h1000_0000;
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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h0000_000A) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for GPIO read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for GPIO read");
        end
        
        ARVALID = 0;
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
        
        // TEST 3: Read GPIO_IN
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        ARADDR = 32'h1000_0004;
        ARVALID = 1;
        gpio_in = 4'b1011;

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
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h0000_000B) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for GPIO read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for GPIO read");
        end
        
        ARVALID = 0;
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
        
        // TEST 4 - Write GPIO_OUT w/ invalid WSTRB
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        AWADDR = 32'h1000_0000;
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
        WDATA  = 32'h000_0005; // 5
        WSTRB  = 4'b1110;
        
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
        
        
        if (gpio_out == 4'b1010 && BVALID == 1 && BRESP == 2'b00) begin
            $display("TEST PASSED: gpio_out write is the right value (UNCHANGED) and B response successful");
        end
        else begin
            $error("TEST FAILED: gpio_write is NOT the right value and B response unsuccessful");
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