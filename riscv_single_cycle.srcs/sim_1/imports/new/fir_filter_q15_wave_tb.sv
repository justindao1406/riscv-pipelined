`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/11/2026 06:45:49 PM
// Design Name: 
// Module Name: fir_filter_q15_wave_tb
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


module fir_filter_q15_wave_tb();
    
    integer i;

    logic clk;
    logic reset;
    logic signed [15:0] sample_in;
    logic sample_valid;
    logic signed [15:0] coefficients [0:14];
    wire signed [15:0] sample_out;
    wire output_valid;
    
    logic signed [15:0] input_wave_samples [0:479];
    logic signed [15:0] predicted_outputs [0:479];
    
    integer input_position;
    integer output_position;
    integer error_count;
    
    fir_filter_q15 I1 ( .coefficients(coefficients), .sample_in(sample_in), .sample_valid(sample_valid), 
    .clk(clk), .reset(reset), .sample_out(sample_out), .output_valid(output_valid) );
    
    initial begin
        clk = 0;
        reset = 1;
        sample_valid = 0;
        sample_in = 16'h0000;
        output_position = 0;
        input_position = 0;
        error_count = 0;
        
        coefficients[0] = -122;
        coefficients[1] = -159;
        coefficients[2] = -71;
        coefficients[3] = 587;
        coefficients[4] = 2122;
        coefficients[5] = 4283;
        coefficients[6] = 6233;
        coefficients[7] = 7021;
        coefficients[8] = 6233;
        coefficients[9] = 4283;
        coefficients[10] = 2122;
        coefficients[11] = 587;
        coefficients[12] = -71;
        coefficients[13] = -159;
        coefficients[14] = -122;
        
        $readmemh("input_samples.mem", input_wave_samples);
        $readmemh("predicted_outputs.mem", predicted_outputs);
        
        @(negedge clk) begin
            reset = 0;
            sample_valid = 0;
        end
        
        for (i=0; i<=479; i=i+1) begin       
            @(negedge clk) begin
                sample_valid = 1;                   
                sample_in = input_wave_samples[input_position];
                input_position = input_position + 1;
            end
        end
        @(negedge clk) begin    
            sample_valid = 0;
        end
        repeat(2) // lets delayed_valid calculate the final output + lets output_valid = 0
            @(posedge clk); 
            @(negedge clk);
            
        if (error_count == 0 && output_position == 480) begin
            $display("TEST PASSED: All sample outputs match the predicted outputs");
        end
        else begin
            $display("TEST FAILED: error count is %0d", error_count);
        end
        $finish;
    end
    
    always begin
    #5;
    clk = ~clk;
    end
    
    always @(negedge clk) begin
    if (output_valid == 1) begin
        if (sample_out !== predicted_outputs[output_position]) begin
            error_count = error_count + 1;
            $error("Mismatch at position %0d : sample output = %0d and predicted output = %0d", output_position, sample_out, predicted_outputs[output_position]);
        end
        output_position = output_position + 1;
    end
    end

endmodule
