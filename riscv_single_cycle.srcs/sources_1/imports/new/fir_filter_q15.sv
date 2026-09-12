`timescale 1ns / 1ps

module fir_filter_q15(
    input signed [15:0] coefficients [0:14], input signed [15:0] sample_in, input sample_valid,
    input clk, input reset, output logic signed [15:0] sample_out, output logic output_valid 
    );
    
    integer i;
    integer j;
    
    reg signed [35:0] temp_sum; // Since 32 + log2(16) = 36 [ accumulator width = product width + log2(# of products) ]
    reg signed [35:0] temp_shift; // shifts temp_sum to the right by 15 bits then fills upper bits with MSB
    
    reg signed [16:0] pair_sum; // prevents overflow for symmetric addition
    // done by converting 2 16-bit samples to 17 bits w/ the extra bit being the signed bit.
   
    reg delayed_valid; // delays sample_valid by one clock cyle
    
    // first clock cycle: sample stored in sample_delay (sample_valid)
    // second clock cycle: sample output calculated (delayed_valid)
    
    parameter TAPS = 15;
    reg signed [15:0] sample_delay [0:TAPS-1];
    
    always @(posedge clk) begin
        if (reset) begin
            sample_out <= 0;
            output_valid <= 0;
            delayed_valid <= 0;
            pair_sum  = 17'sd0;
            temp_sum  = 36'sd0;
            temp_shift = 36'sd0;
            for (i=0; i <= TAPS-1; i = i+1) begin
                sample_delay[i] <= 0;
            end
        end       
  
        else begin
            delayed_valid <= sample_valid;
            if (sample_valid) begin
                for (i=0; i < TAPS-1; i = i+1) begin
                    sample_delay[i+1] <= sample_delay[i];
                end
                sample_delay[0] <= sample_in;                 
            end               
            if (delayed_valid) begin
                temp_sum = 0;
                for (j=0; j < 7; j=j+1) begin
                    pair_sum = {sample_delay[j][15], sample_delay[j]} + {sample_delay[14-j][15], sample_delay[14-j]};
                    temp_sum = temp_sum + (pair_sum * coefficients[j]);
                end
                temp_sum = temp_sum + (sample_delay[7] * coefficients[7]);
                temp_shift = temp_sum >>> 15;
                
                if (temp_shift > 32767)
                    sample_out <= 32767;
                else if (temp_shift < -32768)
                    sample_out <= -32768;
                else
                    sample_out <= temp_shift;          
            end
            output_valid <= delayed_valid;
         end
    end
    
endmodule
