`timescale 1ns / 1ps

module axi_interconnect(
    input clk,
    input reset,
    
    // input: master (AXI master) -> slave (interconnect)
    input logic [31:0] ARADDR,
    input logic ARVALID,
    input logic RREADY,
    
    input logic [31:0] AWADDR,
    input logic AWVALID,
    input logic [31:0] WDATA,
    input logic [3:0] WSTRB,
    input logic WVALID,
    input logic BREADY,
    
    // output: slave (interconnect) -> master (AXI master)
    output logic ARREADY,
    output logic [31:0] RDATA,
    output logic [1:0] RRESP,
    output logic RVALID,
    
    output logic AWREADY,
    output logic WREADY,
    output logic [1:0] BRESP,
    output logic BVALID
    );
    
    // peripheral signals
    
    logic memory_ARVALID;
    logic memory_ARREADY;
    logic [31:0] memory_RDATA;
    logic [1:0] memory_RRESP;
    logic memory_RVALID;
    logic memory_RREADY;
    logic memory_AWVALID;
    logic memory_AWREADY;
    logic [31:0] memory_WDATA;
    logic [3:0] memory_WSTRB;
    logic memory_WVALID;
    logic memory_WREADY;
    logic [1:0] memory_BRESP;
    logic memory_BVALID;
    logic memory_BREADY;    
    
    logic gpio_ARVALID;
    logic gpio_ARREADY;
    logic [31:0] gpio_RDATA;
    logic [1:0] gpio_RRESP;
    logic gpio_RVALID;
    logic gpio_RREADY;
    logic gpio_AWVALID;
    logic gpio_AWREADY;
    logic [31:0] gpio_WDATA;
    logic [3:0] gpio_WSTRB;
    logic gpio_WVALID;
    logic gpio_WREADY;
    logic [1:0] gpio_BRESP;
    logic gpio_BVALID;
    logic gpio_BREADY;        
    
    // select flags
    
    logic memory_read_select;
    logic gpio_read_select;
    
    logic memory_write_select;
    logic gpio_write_select;
    
    always_comb begin
        memory_read_select  = 0;
        gpio_read_select    = 0;
        memory_write_select = 0;
        gpio_write_select   = 0;
        memory_ARVALID = 0;
        gpio_ARVALID   = 0;
        memory_AWVALID = 0;
        gpio_AWVALID   = 0;               
    
        if (ARADDR[31:16] == 16'h0000) begin
            memory_read_select = 1;
            memory_ARVALID = ARVALID;
        end
        if (AWADDR[31:16] == 16'h0000) begin
            memory_write_select = 1;
            memory_AWVALID = AWVALID;
        end
        
        if (ARADDR[31:12] == 20'h10000) begin
            gpio_read_select = 1;
            gpio_ARVALID = ARVALID;
        end
        
        if (AWADDR[31:12] == 20'h10000) begin
            gpio_write_select = 1;
            gpio_AWVALID = AWVALID;
        end
    end
    
endmodule
