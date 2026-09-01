`timescale 1ns / 1ps

module alu(
    input logic [31:0] op1,
    input logic [31:0] op2, 
    input logic [3:0] alu_ctrl, 
    output logic [31:0] alu_res );
    
    localparam [3:0]
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_AND = 4'b0010,
    ALU_OR = 4'b0011,
    ALU_XOR = 4'b0100,
    ALU_SLL = 4'b0101,
    ALU_SRL = 4'b0110,
    ALU_SRA = 4'b0111,
    ALU_SLT = 4'b1000,
    ALU_SLTU = 4'b1001;

    always_comb begin
        case (alu_ctrl)
            ALU_ADD: alu_res = op1 + op2; 
            ALU_SUB: alu_res = op1 - op2; 
            ALU_AND: alu_res = op1 & op2; 
            ALU_OR: alu_res = op1 | op2; 
            ALU_XOR: alu_res = op1 ^ op2; 
            ALU_SLL: alu_res = op1 << op2[4:0];
            ALU_SRL: alu_res = op1 >> op2[4:0];
            ALU_SRA: alu_res = $signed(op1) >>> op2[4:0];
            ALU_SLT: alu_res = $signed(op1) < $signed(op2);
            ALU_SLTU: alu_res = op1 < op2;           
            default: alu_res = 32'b0;         
        endcase
    end
endmodule
