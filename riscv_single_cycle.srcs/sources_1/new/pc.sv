`timescale 1ns / 1ps

module pc(
    input clk,
    input logic reset,
    input logic [31:0] next_pc,
    input logic is_stall,
    output logic [31:0] current_pc
    );
    
    always_ff @(posedge clk) begin
        if (reset) begin
            current_pc <= 32'd0;
        end
        else if (is_stall) begin
            current_pc <= current_pc;
        end
        else begin
            current_pc <= next_pc;    
        end
    
    end
    
endmodule
