`timescale 1ns / 1ps

module riscv_system(
    input logic clk,
    input logic reset,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_write_data
    );
    
    logic completed_transaction;
    logic [31:0] load_data;
    logic [31:0] store_data;
    logic mem_request;
    logic mem_read_or_write;
    logic [31:0] mem_address;
    
    logic [31:0] ARADDR;
    logic ARVALID;
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic RREADY;
    
    logic [31:0] AWADDR;
    logic AWVALID;
    logic AWREADY;
    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;
    logic WREADY;
    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;
    
    
    
    riscv_pipelined cpu_inst 
    ( .clk(clk), .reset(reset), .completed_transaction(completed_transaction), .load_data_response(load_data), 
    .store_data_request(store_data), .mem_request(mem_request), .mem_read_or_write(mem_read_or_write),
    .mem_address(mem_address), .debug_pc(debug_pc), .debug_write_data(debug_write_data) );
    
    axi_lite_master axi_inst 
    ( .clk(clk), .reset(reset), .store_data(store_data), .mem_request(mem_request), .mem_read_or_write(mem_read_or_write), 
    .mem_address(mem_address), .ARREADY(ARREADY), .RDATA(RDATA), .RRESP(RRESP), .RVALID(RVALID), .AWREADY(AWREADY), 
    .WREADY(WREADY), .BRESP(BRESP), .BVALID(BVALID), .load_data(load_data), .completed_transaction(completed_transaction), 
    .ARADDR(ARADDR), .ARVALID(ARVALID), .RREADY(RREADY), .AWADDR(AWADDR), .AWVALID(AWVALID), .WDATA(WDATA), .WSTRB(WSTRB), 
    .WVALID(WVALID), .BREADY(BREADY) );
    
endmodule
