`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2026 05:23:16 PM
// Design Name: 
// Module Name: alu_decoder
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


module alu_decoder(
    input logic [1:0] alu_op,
    input logic [2:0] funct3,
    input logic funct7_bit5,
    input logic opcode_bit5, // distinguises R type and I type
    output logic [3:0] alu_ctrl
    );
    
    // alu_op
    
    localparam [1:0]
    force_add = 2'b00, // perform add (obv)
    compare_branch = 2'b01, // perform sub
    decode_f3_f7 = 2'b10;
    
    // funct3
    
    localparam [2:0]
    ADD = 3'b000, // distinguished by funct7_bit5=0
    SUB = 3'b000, // distinguished by funct7_bit5=1
    
    SRL = 3'b101, // distinguished by funct7_bit5=0
    SRA = 3'b101, // distinguished by funct7_bit5=1
    
    SLL = 3'b001,
    SLT = 3'b010,
    SLTU = 3'b011,
    X_OR = 3'b100, 
    _OR = 3'b110,
    _AND = 3'b111;
    
    // if branch = 1 then fcn3 serves different purposes:
    // 000 -> BEQ, 001 -> BNE, 100 -> BLT, 101 -> BGE, 110 -> BLTU, 111 -> BGEU
    
    // alu_ctrl
    
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
        alu_ctrl = ALU_ADD;
    
        case (alu_op)
            force_add: alu_ctrl = ALU_ADD;
            compare_branch: alu_ctrl = ALU_SUB;
            decode_f3_f7: begin
                case (funct3) 
                    ADD: begin
                        if (opcode_bit5 == 1 && funct7_bit5 == 1) begin // sub
                            alu_ctrl = ALU_SUB;
                        end
                        else begin
                            alu_ctrl = ALU_ADD;
                        end
                    end
                    SLL: alu_ctrl = ALU_SLL;
                    SLT: alu_ctrl = ALU_SLT;
                    SLTU: alu_ctrl = ALU_SLTU;
                    X_OR: alu_ctrl = ALU_XOR;
                    SRL: begin
                        if (funct7_bit5 == 0) begin
                            alu_ctrl = ALU_SRL;
                        end
                        else begin
                            alu_ctrl = ALU_SRA;
                        end
                    end
                    _OR: alu_ctrl = ALU_OR;
                    _AND: alu_ctrl = ALU_AND;
                endcase
            end
            default: alu_ctrl = ALU_ADD;
        endcase
    end
    
endmodule
