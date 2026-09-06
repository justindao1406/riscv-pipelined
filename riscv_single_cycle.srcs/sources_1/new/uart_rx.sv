`timescale 1ns / 1ps

module uart_rx(
    input logic clk,
    input logic reset,
    input logic rx, // incoming data
    
    output logic [7:0] rx_data, // byte reconstructed
    output logic rx_valid // = 1 when full byte received
    );
    
    typedef enum logic [1:0] {
        IDLE,
        START,
        DATA,
        STOP
    } rx_state_t;
    
    rx_state_t current_state;
    rx_state_t next_state;
    
    logic [9:0] baud_counter; 
    logic [2:0] bit_index; 
    logic [7:0] rx_data_reg;    
    
    // rx can change anytime (async) and change too close to a clock edge (metastability)
    // rx_sync1 gets rx directly and the potentially metastable value
    // rx_sync2 gets rx_sync1 the next clock cycle in which rx_sync1 has settled to a stable value
    logic rx_sync1;
    logic rx_sync2;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            rx_sync1 <= 1;
            rx_sync2 <= 1;
        end   
        else begin
            rx_sync1 <= rx;
            rx_sync2 <= rx_sync1;    
        end
    end
    
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
                if (rx_sync2 == 0) begin
                    next_state = START;
                end
            end
            
            START: begin
                if (baud_counter == 10'd433 && rx_sync2 == 0) begin
                    next_state = DATA;
                end    
                else if (baud_counter == 10'd433 && rx_sync2 == 1) begin // false start
                    next_state = IDLE;
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
    
    always_ff @(posedge clk) begin
        if (reset) begin
            baud_counter <= 0;
            bit_index <= 0;
            rx_data_reg <= 0;     
            rx_valid <= 0;
            rx_data <= 0;       
        end
        else begin
            case (current_state)
                IDLE: begin
                    baud_counter <= 0;
                    bit_index <= 0;
                    rx_valid <= 0;
                end
                
                START: begin
                    bit_index <= 0;
                    if (baud_counter == 10'd433) begin
                        baud_counter <= 0;
                    end
                    else begin
                        baud_counter <= baud_counter + 10'd1;
                    end
                end
                
                DATA: begin
                    if (baud_counter == 10'd867) begin
                        baud_counter <= 0;
                        rx_data_reg[bit_index] <= rx_sync2;                        
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
                    if (baud_counter == 10'd867) begin
                        baud_counter <= 0;
                        if (rx_sync2 == 1) begin
                            rx_valid <= 1;
                            rx_data <= rx_data_reg;
                        end
                        else begin
                            rx_valid <= 0;
                        end
                    end   
                    else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                
            endcase
        end
    end
    
endmodule
