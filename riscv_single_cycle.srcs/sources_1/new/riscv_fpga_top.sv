`timescale 1ns / 1ps

module riscv_fpga_top(
    input logic sysclk,
    input logic reset_button,
    output logic [3:0] led
    );
    
    logic cpu_clk;
    logic clock_locked; // clocking wizard stabilizes to 100 MHz
    logic cpu_reset;
    
    logic [31:0] debug_pc;
    logic [31:0] debug_write_data;
    
    cpu_clock_gen cpu_clk_inst ( .clk_out1(cpu_clk), .reset(reset_button), .locked(clock_locked), .clk_in1(sysclk) ); 
    assign cpu_reset = reset_button || !clock_locked;
    
    riscv_pipelined riscv_pip_inst ( .clk(cpu_clk), .reset(cpu_reset), .debug_pc(debug_pc), .debug_write_data(debug_write_data) );
    
    // sticky pass
    
    logic test_passed;
    
    assign led[0] = test_passed && !reset_button;
    assign led[1] = clock_locked && !reset_button;
    assign led[2] = reset_button;
    assign led[3] = 0;
    
    always_ff @(posedge cpu_clk) begin
        if (cpu_reset) begin
            test_passed <= 0;
        end
        else if (debug_pc == 32'd96 && debug_write_data == 32'd130) begin
            test_passed <= 1;
        end
    end
    
endmodule
