`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2026 12:24:10 PM
// Design Name: 
// Module Name: pc
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


module pc(
    input clk,
    input logic reset,
    input logic [31:0] next_pc,
    output logic [31:0] current_pc
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            current_pc <= 32'd0;
        end
        else begin
            current_pc <= next_pc;    
        end
    
    end
    
endmodule
