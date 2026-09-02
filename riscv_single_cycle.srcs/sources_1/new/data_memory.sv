`timescale 1ns / 1ps

module data_memory(
    input logic clk,
    input logic reset,
    input logic write_enable,
    input logic request_sent,
    input logic [31:0] address,
    input logic [31:0] data_in, // write data
    output logic [31:0] data_out,  // read data
    output logic completed_transaction
    );
    
    logic [31:0] memory_array [0:255];
    logic [7:0] word_index;
    
    logic busy;
    logic [1:0] counter;
    
    // load
    
    always_comb begin
        word_index = address[9:2];
        data_out = memory_array[word_index];
    end
    
    // store
    
    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory_array[word_index] <= data_in;        
        end
    end
    
    // request logic
    
    always_ff @(posedge clk) begin
        if (reset) begin
            completed_transaction <= 0;
            busy <= 0;
            counter <= 0;
        end
        else if (request_sent && !busy) begin
            busy <= 1;
            counter <= 2'd2;
        end
        else if (busy) begin
            if (counter == 2'd0) begin
                busy <= 0;
                completed_transaction <= 1;
            end
            else begin
                counter <= counter - 2'd1;
            end
        end
        else begin
            completed_transaction <= 0;
        end
    end
    
endmodule
