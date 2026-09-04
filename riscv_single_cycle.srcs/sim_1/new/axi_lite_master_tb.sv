`timescale 1ns / 1ps

module axi_lite_master_tb();

    logic clk;
    logic reset;
    logic [31:0] store_data;
    logic mem_request;
    logic mem_read_or_write; 
    logic [31:0] mem_address;

    // Read channel signals
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;

    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;

    // Write channel signals
    logic AWREADY;
    logic WREADY;
    logic [1:0] BRESP;
    logic BVALID;

    logic [31:0] AWADDR;
    logic AWVALID;
    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;
    logic BREADY;

    // CPU response
    logic [31:0] load_data;
    logic completed_transaction;
    
    axi_lite_master dut (
        .clk(clk),
        .reset(reset),
        
        .store_data(store_data),
        .mem_request(mem_request),
        .mem_read_or_write(mem_read_or_write),
        .mem_address(mem_address),
        
        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),

        .AWREADY(AWREADY),
        .WREADY(WREADY),
        .BRESP(BRESP),
        .BVALID(BVALID),
        
        .load_data(load_data),
        .completed_transaction(completed_transaction),
        
        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .RREADY(RREADY),

        .AWADDR(AWADDR),
        .AWVALID(AWVALID),
        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WVALID(WVALID),
        .BREADY(BREADY)
    );
    
    initial begin
        clk = 0;
        reset = 1;
        mem_request = 0;
        mem_read_or_write = 0;
        mem_address = 0;
        
        ARREADY = 0;
        RVALID = 0;
        RDATA = 0;
        RRESP = 0;
        
        AWREADY = 0;
        WREADY = 0;
        BRESP = 2'd0;
        BVALID = 0;
        
        store_data = 0;
        
        // Test 1 - Read test
        
        @(posedge clk)
        #1
        
        reset = 0;
        mem_request = 1;
        mem_read_or_write = 0;
        mem_address = 32'd4;
        
        repeat (5) begin
            @(posedge clk);
        end
        
        $display("ARREADY = %0d ARADDR = %0d", ARREADY, ARADDR);
        ARREADY = 1;
        
        repeat (5) begin
            @(posedge clk);
        end
        
        $display("RREADY = %0d", RREADY);
        
        RDATA = 32'd10;
        RRESP = 2'b00;
        RVALID = 1;
        
        #1;
        
        mem_request = 0;
                
        if (load_data == RDATA && completed_transaction && RRESP == 2'b00) begin
            $display("TEST SUCCESS: load_data matches with RDATA and completed_trasaction equals to 1");
        end
        else begin
            $error("TEST FAILED");
        end
        
        @(posedge clk);
        
        #1;
        
        if (dut.current_state == 2'd0 && ARVALID == 1'd0 && ARADDR == 32'd0 && RREADY == 1'd0 && completed_transaction == 1'd0) begin
            $display("TEST SUCCESS: current state = %0d ARVALUD = %0d ARADDR = %0d RREADY = %0d completed transaction = %0d", 
            dut.current_state, ARVALID, ARADDR, RREADY, completed_transaction);
        end
        else begin
            $error("TEST FAIL");
        end
        
        @(posedge clk);
        
        ARREADY = 0;
        RVALID  = 0;
        
        // Test 2 - Address accepted first, data accepted later
        
        reset = 0;
        mem_request = 1;
        mem_read_or_write = 1;
        mem_address = 32'd4;
        store_data = 32'd10;
        
        repeat (5) begin
            @(posedge clk);
        end
        
        $display("AWVALID = %0d WVALID = %0d AWADDR = %0d WDATA = %0d WSTRB %0d", 
        AWVALID, WVALID, AWADDR, WDATA, WSTRB);
        
        AWREADY = 1;
        @(posedge clk)
        #1
        
        $display("AWVALID = %0d WVALID = %0d AWADDR = %0d WDATA = %0d WSTRB %0d address_done = %0d, data_done = %0d", 
        AWVALID, WVALID, AWADDR, WDATA, WSTRB, dut.address_done, dut.data_done);
        
        AWREADY = 0;
        
        repeat (5) begin
            @(posedge clk);
        end
        
        WREADY = 1;
        
        @(posedge clk)
        
        #1;
        
        $display("AWVALID = %0d WVALID = %0d AWADDR = %0d WDATA = %0d WSTRB %0d address_done = %0d, data_done = %0d", 
        AWVALID, WVALID, AWADDR, WDATA, WSTRB, dut.address_done, dut.data_done);
        
        repeat (5) begin
            @(posedge clk);
        end     
        
        #1;
        
        BRESP = 2'b00;
        BVALID = 1; 
        mem_request = 0;
        
        #1;
        
        if (completed_transaction && BRESP == 2'b00) begin
            $display("TEST SUCCESS: completed_trasaction equals to 1");
        end
        else begin
            $error("TEST FAILED");
        end
        
        @(posedge clk)
        
        #1;
        
        if (dut.current_state == 2'd0 && dut.address_done == 0 && dut.data_done == 0 && BREADY == 0 && completed_transaction == 0) begin
            $display("TEST SUCCESS: state=%0d address_done=%0d data_done=%0d BREADY=%0d completed_transaction=%0d",
                dut.current_state,
                dut.address_done,
                dut.data_done,
                BREADY,
                completed_transaction);
        end
        else begin
            $error("TEST FAILED: state=%0d address_done=%0d data_done=%0d BREADY=%0d completed_transaction=%0d",
                dut.current_state,
                dut.address_done,
                dut.data_done,
                BREADY,
                completed_transaction);
        end        
        
        AWREADY = 0;
        WREADY = 0;
        BVALID = 0;
        mem_request = 0;
        
        @(posedge clk);
        
        // Test 3 - Data accepted first, address accepted later
        
        mem_request = 1;
        mem_read_or_write = 1;
        
        repeat (5) begin
            @(posedge clk);
        end   
        
        WREADY = 1;
        
        @(posedge clk)
        
        #1;
        
        $display("data_done = %0d WVALID = %0d AWVALID = %0d", dut.data_done, WVALID, AWVALID);
        
        repeat (5) begin
            @(posedge clk);
        end   
        
        AWREADY = 1;
        
        @(posedge clk)
        
        #1;
        
        $display("address_done = %0d WVALID = %0d AWVALID = %0d", dut.address_done, WVALID, AWVALID);
        
        @(posedge clk);
        
        repeat (5) begin
            @(posedge clk);
        end   
        
        #1;
        
        BRESP = 2'b00;
        BVALID = 1; 
        mem_request = 0;
        
        #1;
        
        if (completed_transaction && BRESP == 2'b00) begin
            $display("TEST SUCCESS: completed_trasaction equals to 1");
        end
        else begin
            $error("TEST FAILED");
        end
        
        @(posedge clk);
        
        #1;
        
        if (dut.current_state == 2'd0 && dut.address_done == 0 && dut.data_done == 0 && BREADY == 0 && completed_transaction == 0) begin
            $display("TEST SUCCESS: state=%0d address_done=%0d data_done=%0d BREADY=%0d completed_transaction=%0d",
                dut.current_state,
                dut.address_done,
                dut.data_done,
                BREADY,
                completed_transaction);
        end
        else begin
            $error("TEST FAILED: state=%0d address_done=%0d data_done=%0d BREADY=%0d completed_transaction=%0d",
                dut.current_state,
                dut.address_done,
                dut.data_done,
                BREADY,
                completed_transaction);
        end          
        
        AWREADY = 0;
        WREADY = 0;
        BVALID = 0;
        
        // Test 4 - Address and data accepted in the same cycle
        
        mem_request = 1;
        mem_read_or_write = 1;
        
        repeat (5) begin
            @(posedge clk);
        end   
        
        #1;
        
        AWREADY = 1;
        WREADY = 1;
        
        @(posedge clk);
        
        #1;
        
        $display("address_done = %0d data_done = %0d AWVALID = %0d WVALID = %0d", 
        dut.address_done, dut.data_done, AWVALID, WVALID);
        
        repeat (5) begin
            @(posedge clk);
        end
        
        BRESP = 2'b00;
        BVALID = 1; 
        mem_request = 0;
        
        #1;
        
        if (completed_transaction && BRESP == 2'b00) begin
            $display("TEST SUCCESS: completed_trasaction equals to 1");
        end
        else begin
            $error("TEST FAILED");
        end
        
        @(posedge clk);
        
        #1;
        
        if (dut.current_state == 2'd0 && dut.address_done == 0 && dut.data_done == 0 && BREADY == 0 && completed_transaction == 0) begin
            $display("TEST SUCCESS: state=%0d address_done=%0d data_done=%0d BREADY=%0d completed_transaction=%0d",
                dut.current_state,
                dut.address_done,
                dut.data_done,
                BREADY,
                completed_transaction);
        end
        else begin
            $error("TEST FAILED: state=%0d address_done=%0d data_done=%0d BREADY=%0d completed_transaction=%0d",
                dut.current_state,
                dut.address_done,
                dut.data_done,
                BREADY,
                completed_transaction);
        end            
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule