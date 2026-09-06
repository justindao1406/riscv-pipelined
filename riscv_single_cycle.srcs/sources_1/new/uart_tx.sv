`timescale 1ns / 1ps

module uart_tx(
    input logic clk,
    input logic reset,
    input logic tx_start,
    input logic [7:0] tx_data,
    
    output logic tx,
    output logic tx_busy
    );
    
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } tx_state_t;
    
    tx_state_t current_state;
    tx_state_t next_state;
    
    // 115 200 baud w/ FPGA clock of 100 MHz
    // baud : 1 / 115 200 = 8.68 microseconds
    // 1 FPGA clock: 1 / 100 MHz = 10 nanoseconds
    
    // 8.68 micro / 10 nano = 868 clock cycles per UART bit
    
    logic [9:0] baud_counter; // counts FPGA clock cycle
    logic [2:0] bit_index; // tracks data bit being sent
    logic [7:0] tx_data_reg; // stores byte
    
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    always_comb begin
        next_state = current_state;
        
        case (current_state) 
            IDLE: begin
                if (tx_start == 1) begin
                    next_state = START;
                end
            end
            
            START: begin
                if (baud_counter == 10'd867) begin // must stay for one full baud period before move to next bit
                    next_state = DATA;
                end
            end
            
            DATA: begin
                if (bit_index == 3'd7 && baud_counter == 10'd867) begin
                    next_state = STOP;
                end
            end
            
            STOP: begin
                if (baud_counter == 10'd867) begin 
                    next_state = IDLE;
                end
            end
                
        endcase
    end
    
    always_comb begin
        tx = 0;
        tx_busy = 0;
        
        case (current_state) 
            IDLE: begin
                tx = 1;
                tx_busy = 0;    
            end
            
            START: begin
                tx = 0;
                tx_busy = 1;
            end
            
            DATA: begin
                tx = tx_data_reg[bit_index];
                tx_busy = 1;
            end
            
            STOP: begin
                tx = 1;
                tx_busy = 1;    
            end
            
        endcase
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            baud_counter <= 0;
            bit_index <= 0;
            tx_data_reg <= 0;
        end
        else begin
            case (current_state)
                IDLE: begin
                    baud_counter <= 0;
                    bit_index <= 0;
                    if (tx_start) begin
                        tx_data_reg <= tx_data;
                    end
                end
                
                START: begin
                    bit_index <= 0;
                    if (baud_counter == 10'd867) begin
                        baud_counter <= 0;
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                DATA: begin
                    if (baud_counter == 10'd867) begin
                        baud_counter <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 3'd1;
                        end
                        else begin // prevent wraparound
                            bit_index <= 3'd7;
                        end
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
                STOP: begin
                    bit_index <= 0;
                    if (baud_counter == 10'd867) begin
                        baud_counter <= 0;
                    end
                    else begin
                        baud_counter <= baud_counter + 1;
                    end                    
                end
                
            endcase
        end
    end    
    
endmodule
