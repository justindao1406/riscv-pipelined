`timescale 1ns / 1ps

module fir_filter_q15_top(
    input clk, input reset, input logic signed [15:0] sample_in, 
    input sample_valid, output logic signed [15:0] sample_out, output output_valid);

    logic signed [15:0] coefficients [0:14];
    
    // Symmetric coefficients : linear-phase FIR filters where every freq. component is delayed equally
    // Common for low-pass, high-pass, band-pass filters
    
    assign coefficients[0] = -122;
    assign coefficients[1] = -159;
    assign coefficients[2] = -71;
    assign coefficients[3] = 587;
    assign coefficients[4] = 2122;
    assign coefficients[5] = 4283;
    assign coefficients[6] = 6233;
    assign coefficients[7] = 7021;
    assign coefficients[8] = 6233;
    assign coefficients[9] = 4283;
    assign coefficients[10] = 2122;
    assign coefficients[11] = 587;
    assign coefficients[12] = -71;
    assign coefficients[13] = -159;
    assign coefficients[14] = -122;

    // Connecting the coefficients to the fir filter processing core
        
    fir_filter_q15 fir_core ( .coefficients(coefficients), .sample_in(sample_in), .sample_valid(sample_valid), 
    .clk(clk), .reset(reset), .sample_out(sample_out), .output_valid(output_valid) );
    
endmodule
