`timescale 1ns / 1ps

module data_memory(
    input logic clk,
    input logic write_enable,
    input logic [31:0] address,
    input logic [31:0] data_in, // write data
    output logic [31:0] data_out  // read data
    );
    
    logic [31:0] memory_array [0:255];
    logic [7:0] word_index;
    
    // load
    
    always_comb begin
        word_index = address[9:2];
        data_out = memory_array[word_index];
    end
    
    // store
    
    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory_array[word_index] <= data_in;        
        end
    end
    
endmodule
