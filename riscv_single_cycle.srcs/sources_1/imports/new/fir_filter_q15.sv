`timescale 1ns / 1ps

module fir_filter_q15(
    input signed [15:0] coefficients [0:14], input signed [15:0] sample_in, input sample_valid,
    input clk, input reset, output logic signed [15:0] sample_out, output logic output_valid 
    );
    
    integer i;
    integer j;
    
    logic signed [35:0] final_sum; // Since 32 + log2(16) = 36 [ accumulator width = product width + log2(# of products) ]
    logic signed [35:0] temp_shift; // shifts temp_sum to the right by 15 bits then fills upper bits with MSB
   
    logic delayed_valid; // delays sample_valid by one clock cyle
    
    parameter TAPS = 15;
    logic signed [15:0] sample_delay [0:TAPS-1];
    
    // PIPELINING:
    // sample_valid -> delayed_valid -> product_valid -> sum_level_1_valid
    // -> sum_level_2_valid -> final_sum_valid -> output_valid
    
    logic signed [16:0] pair [0:6];
    logic signed [32:0] product [0:7];
    logic signed [33:0] sum_level_1 [0:3];
    logic signed [34:0] sum_level_2 [0:1];
    
    logic product_valid; 
    logic sum_level_1_valid;
    logic sum_level_2_valid;
    logic final_sum_valid;
    
    always @(posedge clk) begin
        if (reset) begin
            sample_out <= 0;
            output_valid <= 0;
            delayed_valid <= 0;
            final_sum  <= 36'sd0;
            temp_shift = 36'sd0;
            product_valid <= 0;
            sum_level_1_valid <= 0;
            sum_level_2_valid <= 0;
            final_sum_valid <= 0;
            for (int i=0; i <= TAPS-1; i++) begin
                sample_delay[i] <= 0;
            end
            for (int i=0; i <= 6; i++) begin
                pair[i] <= 0;
            end
            for (int i=0; i <= 7; i++) begin
                product[i] <= 0;
            end       
            for (int i=0; i <= 3; i++) begin
                sum_level_1[i] <= 0;
            end
            for (int i=0; i <= 1; i++) begin
                sum_level_2[i] <= 0;
            end                             
        end       
  
        else begin
            delayed_valid <= sample_valid;
            product_valid <= delayed_valid;
            sum_level_1_valid <= product_valid;
            sum_level_2_valid <= sum_level_1_valid;
            final_sum_valid <= sum_level_2_valid;
            
            if (sample_valid) begin
                for (i=0; i < TAPS-1; i++) begin
                    sample_delay[i+1] <= sample_delay[i];
                end
                sample_delay[0] <= sample_in;                 
            end       
                    
            if (delayed_valid) begin
            // product stage
                for (j=0; j < 7; j++) begin
                    pair[j] = $signed({sample_delay[j][15], sample_delay[j]}) + 
                    $signed({sample_delay[14-j][15], sample_delay[14-j]}); // avoids overflow
                    product[j] <= pair[j] * coefficients[j];
                end
                product[7] <= sample_delay[7] * coefficients[7];
            end    
            if (product_valid) begin
            // first addition stage
                for (j = 0; j < 4; j++) begin
                    sum_level_1[j] <= $signed({product[j][32], product[j]}) + $signed({product[7-j][32], product[7-j]});                
                end  
            end
            
            if (sum_level_1_valid) begin
            // second addition stage
                for (j = 0; j < 2; j++) begin
                    sum_level_2[j] <= $signed({sum_level_1[j][33], sum_level_1[j]}) + $signed({sum_level_1[3-j][33], sum_level_1[3-j]});                
                end                      
            end
            
            if (sum_level_2_valid) begin
            // final addition stage
                final_sum <= $signed({sum_level_2[0][34], sum_level_2[0]}) + $signed({sum_level_2[1][34], sum_level_2[1]});
            end
            
            if (final_sum_valid) begin
            // output stage
                temp_shift = final_sum >>> 15;
                if (temp_shift > 32767)
                    sample_out <= 32767;
                else if (temp_shift < -32768)
                    sample_out <= -32768;
                else
                    sample_out <= temp_shift; 
            end
            output_valid <= final_sum_valid;
         end
    end
    
endmodule
