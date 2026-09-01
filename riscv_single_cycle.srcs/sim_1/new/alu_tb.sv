`timescale 1ns / 1ps

module alu_tb();

    logic [31:0] op1; 
    logic [31:0] op2;
    logic [3:0] alu_ctrl;
    logic [31:0] alu_res;
    
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
    
    alu dut ( .op1(op1), .op2(op2), .alu_ctrl(alu_ctrl), .alu_res(alu_res) );

    task automatic check_op(
        input logic [31:0] test_op1,
        input logic [31:0] test_op2,
        input logic [3:0] test_ctrl,
        input logic [31:0] predicted_res
    );
        begin
            op1 = test_op1;
            op2 = test_op2;
            
            alu_ctrl = test_ctrl;
            #1;
            
            if (alu_res !== predicted_res) begin
                $error("TEST FAILED: The value %0d does not match the predicted value %0d", alu_res, predicted_res);
            end
            else begin
                $display("TEST PASSED: result = %0d", alu_res);
            end
        end
    endtask
    
    initial begin
        check_op(32'd1, 32'd1, ALU_ADD, 32'd2);
        check_op(32'd3, 32'd1, ALU_SUB, 32'd2);
        check_op(32'h0000000C, 32'h0000000A, ALU_AND, 32'h00000008);
        check_op(32'h0000000C, 32'h0000000A, ALU_OR, 32'h0000000E);
        check_op(32'hFCB14001, 32'hFCA14001, ALU_XOR, 32'h00100000);
        check_op(32'hFFFFFFF0, 32'd2, ALU_SLL, 32'hFFFFFFC0);
        check_op(32'hFFFFFFF0, 32'd2, ALU_SRL, 32'h3FFFFFFC);
        check_op(32'hFFFFFFF0, 32'd2, ALU_SRA, 32'hFFFFFFFC);
        check_op(32'hFFFFFFFF, 32'd1, ALU_SLT, 32'd1);
        check_op(32'hFFFFFFFF, 32'd1, ALU_SLTU, 32'd0);
        
        check_op(32'hFFFFFFFF, 32'd1, 4'b1111, 32'd0);
        check_op(32'd1, 32'd34, ALU_SLL, 32'd4); // check if op2 stays within [4:0]
    
        $finish;
    end
    
endmodule
