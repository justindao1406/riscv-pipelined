`timescale 1ns / 1ps

module riscv_system(
    input logic clk,
    input logic reset,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_write_data
    );
    
    logic completed_transaction;
    logic [31:0] load_data_response;
    logic [31:0] store_data_request;
    logic mem_request;
    logic mem_read_or_write;
    logic [31:0] mem_address;
    
    riscv_pipelined cpu_inst 
    ( .clk(clk), .reset(reset), .completed_transaction(completed_transaction), .load_data_response(load_data_response),
    .store_data_request(store_data_request), .mem_request(mem_request), .mem_read_or_write(mem_read_or_write),
    .mem_address(mem_address), .debug_pc(debug_pc), .debug_write_data(debug_write_data) );
    
    data_memory data_mem_inst
     ( .clk(clk), .reset(reset), .request_sent(mem_request), .write_enable(mem_read_or_write && !reset && mem_request), .address(mem_address), 
     .data_in(store_data_request), .data_out(load_data_response), .completed_transaction(completed_transaction) );
    
endmodule
