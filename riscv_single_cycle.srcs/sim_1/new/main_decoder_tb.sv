`timescale 1ns / 1ps

module main_decoder_tb();

    logic [6:0] opcode;
    logic reg_write;
    logic mem_write;
    logic [1:0] alu_src_a;
    logic alu_src_b;
    logic [1:0] result_src;
    logic [2:0] imm_sel;
    logic branch;
    logic [1:0] jump;
    logic [1:0] alu_op;
    
    main_decoder dut ( .opcode(opcode), .reg_write(reg_write), .mem_write(mem_write),
    .alu_src_a(alu_src_a), .alu_src_b(alu_src_b), .result_src(result_src), .imm_sel(imm_sel),
    .branch(branch), .jump(jump), .alu_op(alu_op) );
    
    logic [14:0] actual_controls;
    assign actual_controls = {reg_write, mem_write, alu_src_a, alu_src_b, result_src,
    imm_sel, branch, jump, alu_op};
    
    task automatic check_md(
        input logic [6:0] test_opcode,
        input logic [14:0] predicted_res
    );
        begin
            opcode = test_opcode;
            #1;
            
            if (actual_controls !== predicted_res) begin
                $error("TEST FAILED: The controls %b does not match the predicted controls %b", actual_controls, predicted_res);
            end
            else begin
                $display("TEST PASSED: controls = %b", actual_controls);
            end       
        
        end
    endtask
    
    initial begin
        check_md(7'b0110011, 15'b1_0_00_0_00_000_0_00_10); // R TYPE
        check_md(7'b0010011, 15'b1_0_00_1_00_000_0_00_10); // I TYPE
        check_md(7'b0000011, 15'b1_0_00_1_01_000_0_00_00); // Load
        check_md(7'b0100011, 15'b0_1_00_1_00_001_0_00_00); // Store
        check_md(7'b1100011, 15'b0_0_00_0_00_010_1_00_01); // Branch
        check_md(7'b1101111, 15'b1_0_00_0_10_100_0_01_00); // jal
        check_md(7'b1100111, 15'b1_0_00_1_10_000_0_10_00); // jalr
        check_md(7'b0110111, 15'b1_0_10_1_00_011_0_00_00); // lui
        check_md(7'b0010111, 15'b1_0_01_1_00_011_0_00_00); // auipc
        
        check_md(7'b1111111, 15'b0_0_00_0_00_000_0_00_00); // invalid
    
    $finish;
    end
    
endmodule
