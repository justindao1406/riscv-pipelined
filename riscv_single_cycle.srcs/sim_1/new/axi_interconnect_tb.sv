`timescale 1ns / 1ps

module axi_interconnect_tb();

    logic clk;
    logic reset;

    // Master -> interconnect
    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;

    logic [31:0] AWADDR;
    logic AWVALID;
    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;
    logic BREADY;

    // AXI slave -> interconnect
    logic memory_ARREADY;
    logic memory_AWREADY;
    logic [31:0] memory_RDATA;
    logic memory_RVALID;
    logic [1:0] memory_RRESP;
    logic memory_WREADY;
    logic [1:0] memory_BRESP;
    logic memory_BVALID;

    logic gpio_ARREADY;
    logic gpio_AWREADY;
    logic [31:0] gpio_RDATA;
    logic gpio_RVALID;
    logic [1:0] gpio_RRESP;
    logic gpio_WREADY;
    logic [1:0] gpio_BRESP;
    logic gpio_BVALID;

    // Interconnect -> master
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;

    logic AWREADY;
    logic WREADY;
    logic [1:0] BRESP;
    logic BVALID;

    // Interconnect -> AXI slaves
    logic [31:0] memory_ARADDR;
    logic [31:0] memory_AWADDR;
    logic [31:0] gpio_ARADDR;
    logic [31:0] gpio_AWADDR;

    logic memory_ARVALID;
    logic memory_AWVALID;
    logic memory_RREADY;

    logic gpio_ARVALID;
    logic gpio_AWVALID;
    logic gpio_RREADY;

    logic [31:0] memory_WDATA;
    logic [3:0] memory_WSTRB;
    logic memory_WVALID;
    logic memory_BREADY;

    logic [31:0] gpio_WDATA;
    logic [3:0] gpio_WSTRB;
    logic gpio_WVALID;
    logic gpio_BREADY;


    axi_interconnect dut (
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

        .memory_ARREADY(memory_ARREADY),
        .memory_AWREADY(memory_AWREADY),
        .memory_RDATA(memory_RDATA),
        .memory_RVALID(memory_RVALID),
        .memory_RRESP(memory_RRESP),
        .memory_WREADY(memory_WREADY),
        .memory_BRESP(memory_BRESP),
        .memory_BVALID(memory_BVALID),

        .gpio_ARREADY(gpio_ARREADY),
        .gpio_AWREADY(gpio_AWREADY),
        .gpio_RDATA(gpio_RDATA),
        .gpio_RVALID(gpio_RVALID),
        .gpio_RRESP(gpio_RRESP),
        .gpio_WREADY(gpio_WREADY),
        .gpio_BRESP(gpio_BRESP),
        .gpio_BVALID(gpio_BVALID),

        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),

        .AWREADY(AWREADY),
        .WREADY(WREADY),
        .BRESP(BRESP),
        .BVALID(BVALID),

        .memory_ARADDR(memory_ARADDR),
        .memory_AWADDR(memory_AWADDR),
        .gpio_ARADDR(gpio_ARADDR),
        .gpio_AWADDR(gpio_AWADDR),

        .memory_ARVALID(memory_ARVALID),
        .memory_AWVALID(memory_AWVALID),
        .memory_RREADY(memory_RREADY),

        .gpio_ARVALID(gpio_ARVALID),
        .gpio_AWVALID(gpio_AWVALID),
        .gpio_RREADY(gpio_RREADY),

        .memory_WDATA(memory_WDATA),
        .memory_WSTRB(memory_WSTRB),
        .memory_WVALID(memory_WVALID),
        .memory_BREADY(memory_BREADY),

        .gpio_WDATA(gpio_WDATA),
        .gpio_WSTRB(gpio_WSTRB),
        .gpio_WVALID(gpio_WVALID),
        .gpio_BREADY(gpio_BREADY)
    );
    
    initial begin
        clk = 0;
        reset = 1;
        ARADDR = 0;
        ARVALID = 0;
        RREADY = 0;
        AWADDR = 0;
        AWVALID = 0;
        WDATA = 0;
        WSTRB = 0;
        WVALID = 0;
        BREADY = 0;
        memory_ARREADY = 0;
        memory_AWREADY = 0;
        memory_RDATA = 0;
        memory_RVALID = 0;
        memory_RRESP = 0;
        memory_WREADY = 0;
        memory_BRESP = 0;
        memory_BVALID = 0;
        gpio_ARREADY = 0;
        gpio_AWREADY = 0;
        gpio_RDATA = 0;
        gpio_RVALID = 0;
        gpio_RRESP = 0;
        gpio_WREADY = 0;
        gpio_BRESP = 0;
        gpio_BVALID = 0;
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        reset = 0;
        
        // ---------------------------------- READ ----------------------------------  
        
        // memory
        
        ARADDR = 32'h0000_0004;
        ARVALID = 1;
        
        memory_ARREADY = 1;
        
        wait (ARVALID && ARREADY) begin
            $display("ARVALID and ARREADY both equal to 1");
        end
        
        if (memory_ARVALID == 1 &&
            memory_ARADDR == 32'h0000_0004 &&
            gpio_ARVALID == 0) begin
            $display("TEST PASSED: Memory address routed correctly");
        end
        else begin
            $display("TEST FAILED: Memory address routing");
        end 
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        memory_ARREADY = 0;
        
        repeat (5) begin
            @(posedge clk);
        end  
        
        memory_RDATA  = 32'd67;
        memory_RRESP  = 2'b00;
        memory_RVALID = 1;   
        
        RREADY = 1;
        #1;
       
        if (RVALID == 1 && RDATA == 32'd67 && RRESP == 2'b00 && memory_RREADY == 1) begin
            $display("TEST PASSED: Read transfer succesful");
        end     
        else begin
            $display("TEST FAILED");
        end
        
        if (gpio_ARVALID == 0 && gpio_RREADY == 0) begin
            $display("TEST PASSED: GPIO not involved");
        end
        else begin
            $display("TEST FAILED");
        end
        
        wait (RVALID && RREADY);
        
        @(posedge clk);
        #1;
        
        memory_RVALID = 0;
        RREADY = 0;
        
        // gpio
        
        @(posedge clk);
        
        ARADDR = 32'h1000_0008;
        ARVALID = 1;
        
        gpio_ARREADY = 1;
        
        wait (ARVALID && ARREADY) begin
            $display("ARVALID and ARREADY both equal to 1");
        end
        
        if (gpio_ARVALID == 1 &&
            gpio_ARADDR == 32'h1000_0008 &&
            memory_ARVALID == 0) begin
            $display("TEST PASSED: GPIO address routed correctly");
        end
        else begin
            $display("TEST FAILED: GPIO address routing");
        end
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        gpio_ARREADY = 0;
        
        repeat (5) begin
            @(posedge clk);
        end  
        
        gpio_RDATA  = 32'd69;
        gpio_RRESP  = 2'b00;
        gpio_RVALID = 1;   
        
        RREADY = 1;
        
        #1;
       
        if (RVALID == 1 && RDATA == 32'd69 && RRESP == 2'b00 && gpio_RREADY == 1) begin
            $display("TEST PASSED: Read transfer succesful");
        end     
        else begin
            $display("TEST FAILED");
        end
        
        if (memory_ARVALID == 0 && memory_RREADY == 0) begin
            $display("TEST PASSED: Memory not involved");
        end
        else begin
            $display("TEST FAILED");
        end
        
        wait (RVALID && RREADY);
        
        @(posedge clk);
        #1;
        
        gpio_RVALID = 0;
        RREADY = 0;
        
        // ---------------------------------- WRITE ----------------------------------        
        
        // memory 
        
        AWADDR = 32'h0000_0004;
        AWVALID = 1;
        
        memory_AWREADY = 1;
        
        wait (AWVALID && AWREADY) begin
            $display("AWVALID and AWREADY both equal to 1");
        end

        @(posedge clk);
        #1;        
        
        if (memory_AWVALID == 1 &&
            memory_AWADDR == 32'h0000_0004 &&
            gpio_AWVALID == 0) begin
            $display("TEST PASSED: Memory address routed correctly");
        end
        else begin
            $display("TEST FAILED: Memory address routing");
        end 
        
        AWVALID = 0;
        memory_AWREADY = 0;
        
        repeat (5) begin
            @(posedge clk);
        end  
        
        WDATA  = 32'd67;
        WSTRB = 4'b1111;
        WVALID = 1;   
        
        memory_WREADY = 1;
        
        @(posedge clk);
        
        wait (WVALID && WREADY) begin
            $display("WVALID and WREADY both equal to 1");
        end
        
        #1;
       
        if (memory_WVALID == 1 && memory_WDATA == 32'd67 && memory_WSTRB == 4'b1111 && WREADY == 1) begin
            $display("TEST PASSED: Write data transfer succesful");
        end     
        else begin
            $display("TEST FAILED");
        end
        
        if (gpio_AWVALID == 0 && gpio_WVALID == 0) begin
            $display("TEST PASSED: GPIO not involved");
        end
        else begin
            $display("TEST FAILED");
        end
        
        #1;
        
        WVALID = 0;
        memory_WREADY = 0;
        
        @(posedge clk);
        #1
        
        memory_BRESP = 2'b00;
        memory_BVALID = 1;
        BREADY = 1;
        
        #1;
        
        if (BRESP == 2'b00 && BVALID == 1 && memory_BREADY== 1) begin
            $display("TEST PASSED: Write transfer succesful");
        end     
        else begin
            $display("TEST FAILED");
        end
        
        wait (BVALID && BREADY);
        
        @(posedge clk);
        #1;
        
        memory_BVALID = 0;
        BREADY = 0;     
        
        @(posedge clk);
        
        // gpio
        
        AWADDR = 32'h1000_0004;
        AWVALID = 1;
        
        gpio_AWREADY = 1;
        
        wait (AWVALID && AWREADY) begin
            $display("AWVALID and AWREADY both equal to 1");
        end
        
        @(posedge clk);
        #1;
        
        if (gpio_AWVALID == 1 &&
            gpio_AWADDR == 32'h1000_0004 &&
            memory_AWVALID == 0) begin
            $display("TEST PASSED: Memory address routed correctly");
        end
        else begin
            $display("TEST FAILED: Memory address routing");
        end 
        
        AWVALID = 0;
        gpio_AWREADY = 0;      
        
        repeat (5) begin
            @(posedge clk);
        end  
        
        WDATA  = 32'd67;
        WSTRB = 4'b1111;
        WVALID = 1;   
        
        gpio_WREADY = 1;
        #1;
        
        @(posedge clk);
       
        if (gpio_WVALID == 1 && gpio_WDATA == 32'd67 && gpio_WSTRB == 4'b1111 && WREADY == 1) begin
            $display("TEST PASSED: Write data transfer succesful");
        end     
        else begin
            $display("TEST FAILED");
        end
        
        if (memory_AWVALID == 0 && memory_WVALID == 0) begin
            $display("TEST PASSED: Memory not involved");
        end
        else begin
            $display("TEST FAILED");
        end
        
        #1;
        
        WVALID = 0;
        gpio_WREADY = 0;
        
        @(posedge clk);
        #1
        
        gpio_BRESP = 2'b00;
        gpio_BVALID = 1;
        BREADY = 1;
        
        #1;
        
        if (BRESP == 2'b00 && BVALID == 1 && gpio_BREADY== 1) begin
            $display("TEST PASSED: Write transfer succesful");
        end     
        else begin
            $display("TEST FAILED");
        end
        
        wait (BVALID && BREADY);
        
        @(posedge clk);
        #1;
        
        gpio_BVALID = 0;
        BREADY = 0;               
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end
    
endmodule