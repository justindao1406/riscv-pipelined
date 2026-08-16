`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 11:23:21 AM
// Design Name: 
// Module Name: instruction_memory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_memory(
    input logic [31:0] current_pc, // acts as address
    output logic [31:0] instruction
    );
    
    logic [31:0] memory_array [0:255];
    logic [7:0] word_index;
    
    always_comb begin
        word_index = current_pc[9:2]; // [9:2] are the bits that select the index since pc jumps by 4 bytes
        instruction = memory_array[word_index];
    end
    
    initial begin
        $readmemh("instructions.mem", memory_array);
    end
    
endmodule
