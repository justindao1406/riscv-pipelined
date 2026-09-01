`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/17/2026 04:00:24 PM
// Design Name: 
// Module Name: riscv_pipelined_tb
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


module riscv_pipelined_tb_display();

    integer i;
    integer errors;

    logic clk;
    logic reset;
    
    logic [31:0] expected_registers [1:21];
    
    riscv_pipelined dut ( .clk(clk), .reset(reset) );
    
    initial begin
        clk = 0;
        reset = 1;
        
        for ( i = 1; i <= 31; i++ ) begin
            dut.rf_inst.register_array[i] = 32'd0;   
        end
        
        @(negedge clk);
        reset = 0;
        
        repeat (30) begin
            @(posedge clk);
        end
        
        #2;
        
        for (i=1; i <= 21; i++) begin
            $display("REGISTER %0d = %0d", i, dut.rf_inst.register_array[i]);
        end
        
        $finish;
    end
    
    always @(posedge clk) begin
        #1;
        if (!reset) begin
            $display("PC: F=%0d, D=%0d, E=%0d, M=%0d, W=%0d", dut.pcF, dut.pcD, dut.pcE, dut.pcM, dut.pcW);
            
            $display("INSTR: F=%08h, D=%08h", dut.instructionF, dut.instructionD);
             
            $display("RD ADDR: D=%0d, E=%0d, M=%0d, W=%0d", dut.rd_addrD, dut.rd_addrE, dut.rd_addrM, dut.rd_addrW);
            
            $display("REG WRITE: D=%0d, E=%0d, M=%0d, W=%0d", dut.reg_writeD, dut.reg_writeE, dut.reg_writeM, dut.reg_writeW);
            
            $display("ALU RES: E=%08h, M=%08h, W=%08h", dut.alu_resE, dut.alu_resM, dut.alu_resW);
            
            $display("WRITE DATA: W=%08h", dut.write_dataW);
            
            $display("OP 1 INPUT (E) = %08h , OP 2 INPUT(E) = %08h", dut.op1_inputE, dut.op2_inputE);
            
            $display("RS1 DATA (E) = %08h , RS2 DATA (E) = %08h", dut.rs1_dataE, dut.rs2_dataE);
            
            $display("FORWARDED RS1 (E) = %08h , FORWARDED RS2 (E) = %08h", dut.forwarded_rs1E, dut.forwarded_rs2E);
            
            $display("TAKE BRANCH (E): %0d", dut.take_branchE);
            
            $display("BRANCH TARGET (E): %0d", dut.branch_targetE);
            
            $display("IS LOAD: %0d", dut.is_loadE);
            
            $display("IS STALL : %0d", dut.is_stall);
            
            $display("IS FLUSH : %0d", dut.is_flush);
            
            
            $display("----------------------------------------------------------------------------------------");
        end
    
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule
