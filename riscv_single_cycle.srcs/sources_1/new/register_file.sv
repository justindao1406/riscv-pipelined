`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/12/2026 07:47:45 PM
// Design Name: 
// Module Name: register_file
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


module register_file( 
    input clk, 
    input logic write_enable, 
    input logic [4:0] write_addr, 
    input logic [4:0] rs1_addr,
    input logic [4:0] rs2_addr, 
    input logic [31:0] write_data, 
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data 
);
    logic [31:0] register_array [0:31];
    
    always_comb begin
        if (rs1_addr == 0) begin
            rs1_data = 32'd0;
        end
        else begin
            rs1_data = register_array[rs1_addr];
        end
        
        if (rs2_addr == 0) begin
            rs2_data = 32'd0;
        end
        else begin
            rs2_data = register_array[rs2_addr];
        end
    end
    
    always_ff @(posedge clk) begin
        if (write_enable == 1 && write_addr != 5'd0) begin            
            register_array[write_addr]  <= write_data;
        end    
    end
    
endmodule
