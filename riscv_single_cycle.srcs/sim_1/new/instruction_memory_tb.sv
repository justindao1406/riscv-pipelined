`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 11:53:04 AM
// Design Name: 
// Module Name: instruction_memory_tb
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


module instruction_memory_tb();
    
    logic [31:0] current_pc;
    logic [31:0] instruction;
    
    instruction_memory dut ( .current_pc(current_pc), .instruction(instruction) );
    
    initial begin
        dut.memory_array[0] = 32'h00500093;
        dut.memory_array[1] = 32'h00700113;
        dut.memory_array[2] = 32'h002081B3;
        dut.memory_array[3] = 32'h00000063;
        dut.memory_array[255] = 32'h12345678;
    end
    
    task automatic check_im(
        input logic [31:0] test_pc,
        input logic [31:0] predicted_res
    );
        begin
            current_pc = test_pc;
            #1;
            
            if (instruction !== predicted_res) begin
                $error("TEST FAILED: The instruction %08h does not match the predicted instruction %08h", instruction, predicted_res);
            end
            else begin
                $display("TEST PASSED: instructions = %08h", instruction);
            end       
            
        end
    endtask
    
    initial begin
        #1;
        check_im(32'd0, 32'h00500093);
        check_im(32'd4, 32'h00700113);
        check_im(32'd8, 32'h002081B3);
        check_im(32'd12, 32'h00000063);
        check_im(32'd1020, 32'h12345678);
        
        $finish;    
    end
    
endmodule
