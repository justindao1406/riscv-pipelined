`timescale 1ns / 1ps

module axi_lite_master_tb();

    logic clk;
    logic reset;
    logic [31:0] store_data;
    logic mem_request;
    logic mem_read_or_write; 
    logic [31:0] mem_address;
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic [31:0] load_data;
    logic completed_transaction;
    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;
    
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
    
    .load_data(load_data),
    .completed_transaction(completed_transaction),
    
    .ARADDR(ARADDR),
    .ARVALID(ARVALID),
    .RREADY(RREADY)
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
        store_data = 0;
        
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
                
        if (load_data == RDATA && completed_transaction) begin
            $display("TEST SUCCESS: load_data matches with RDATA and completed_trasaction equals to 1");
        end
        else begin
            $error("TEST FAILED");
        end
        
        @(posedge clk);
        
        #1;
        
        if (dut.current_state == 2'd0 && ARVALID == 1'd0 && ARADDR == 32'd0 && RREADY == 1'd0 && completed_transaction == 1'd0) begin
            $display("TEST SUCCESS: current state = %0d ARVALUD = %0d ARADDR = %0d RREADY = %0d completed transaction = %0d", 
            dut.current_state, ARVALID, ARADDR, RREADY, completed_transaction );
        end
        else begin
            $error("TEST FAIL");
        end
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule
