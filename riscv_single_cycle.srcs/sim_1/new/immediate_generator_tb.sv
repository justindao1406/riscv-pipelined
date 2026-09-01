`timescale 1ns / 1ps

module immediate_generator_tb();

    logic [31:0] instr;
    logic [2:0] format_sel;
    logic [31:0] immediate;
    
    localparam [2:0]
    i_type = 3'd0,
    s_type = 3'd1,
    b_type = 3'd2,
    u_type = 3'd3,
    j_type = 3'd4;
    
    immediate_generator dut ( .instr(instr), .format_sel(format_sel), .immediate(immediate) );
    
    task automatic check_imm(
    input logic [31:0] test_instr,
    input logic [2:0] test_sel,
    input logic [31:0] predicted_res
    );
        begin
            instr = test_instr;
            format_sel = test_sel;
            #1;
            
            if (immediate !== predicted_res) begin
                $error("TEST FAILED: The value %08h does not match the predicted value %08h", immediate, predicted_res);
            end
            else begin
                $display("TEST PASSED: result = %0d", immediate);
            end           
        end    
    endtask
    
    initial begin
        check_imm(32'h00C00013, 3'd0, 32'd12); // addi x0,x0,12
        check_imm(32'hFFC00013, 3'd0, 32'hFFFFFFFC); // addi x0,x0,-4
        check_imm(32'h00002A23, 3'd1, 32'd20); // sw x0,20(x0)
        check_imm(32'hFE002C23, 3'd1, 32'hFFFFFFF8); // sw x0,-8(x0)
        check_imm(32'h00000863, 3'd2, 32'd16); // beq x0,x0,16
        check_imm(32'hFE000CE3, 3'd2, 32'hFFFFFFF8); // beq x0,x0,-8
        check_imm(32'h12345037, 3'd3, 32'h12345000); // lui x0,0x12345
        check_imm(32'h0200006F, 3'd4, 32'd32); // jal x0,32
        check_imm(32'hFF1FF06F, 3'd4, 32'hFFFFFFF0); // jal x0,-16
        check_imm(32'hFFFFFFFF, 3'b111, 32'd0); // tests a non valid form_sel
        
        $finish;
    end
    
endmodule
