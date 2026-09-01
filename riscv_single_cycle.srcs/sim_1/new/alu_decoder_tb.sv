`timescale 1ns / 1ps

module alu_decoder_tb();

    logic [1:0] alu_op;
    logic [2:0] funct3;
    logic funct7_bit5;
    logic opcode_bit5;
    logic [3:0] alu_ctrl;
    
    alu_decoder dut ( .alu_op(alu_op), .funct3(funct3), .funct7_bit5(funct7_bit5), .opcode_bit5(opcode_bit5), .alu_ctrl(alu_ctrl) );
    
    task automatic check_ad (
        input logic [1:0] test_alu_op,
        input logic [2:0] test_funct3,
        input logic test_funct7_b5,
        input logic test_opcode_b5,
        input logic [3:0] predicted_res
    );
        begin
            alu_op = test_alu_op;
            funct3 = test_funct3;
            funct7_bit5 = test_funct7_b5;
            opcode_bit5 = test_opcode_b5;
            #1;
            
            if (alu_ctrl !== predicted_res) begin
                $error("TEST FAILED: The control %b does not match the predicted control %b", alu_ctrl, predicted_res);
            end
            else begin
                $display("TEST PASSED: control = %b", alu_ctrl);
            end       
        end
    endtask
    
    initial begin
        check_ad(2'b00, 3'b111, 1, 1, 4'b0000); // Force add
        check_ad(2'b01, 3'b111, 1, 1, 4'b0001); // Branch sub
        check_ad(2'b10, 3'b000, 0, 1, 4'b0000); // R-type add
        check_ad(2'b10, 3'b000, 1, 1, 4'b0001); // R-type sub
        check_ad(2'b10, 3'b000, 1, 0, 4'b0000); // I-type addi
        check_ad(2'b10, 3'b001, 0, 1, 4'b0101); // sll
        check_ad(2'b10, 3'b010, 0, 1, 4'b1000); // slt
        check_ad(2'b10, 3'b011, 0, 1, 4'b1001); // sltu
        check_ad(2'b10, 3'b100, 0, 1, 4'b0100); // xor
        check_ad(2'b10, 3'b101, 0, 1, 4'b0110); // srl
        check_ad(2'b10, 3'b101, 1, 1, 4'b0111); // sra
        check_ad(2'b10, 3'b110, 0, 1, 4'b0011); // or
        check_ad(2'b10, 3'b111, 0, 1, 4'b0010); // and
        
        check_ad(2'b11, 3'b111, 1, 1, 4'b0000); // invalid
        
        $finish;
    end
    
endmodule
