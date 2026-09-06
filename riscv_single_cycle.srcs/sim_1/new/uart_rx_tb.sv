`timescale 1ns / 1ps

module uart_rx_tb();

    logic clk;
    logic reset;
    logic rx;

    logic [7:0] rx_data;
    logic rx_valid;

    uart_rx dut ( .clk(clk), .reset(reset), .rx(rx), .rx_data(rx_data), .rx_valid(rx_valid) );
    
    initial begin
        clk = 0;
        reset = 1;
        rx = 1;
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        
        // data we want to transmit:  10000010
        reset = 0;
        rx = 0;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 1;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 0;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 0; 
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 0;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 0;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 0;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 1;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 0;
        
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        rx = 1;
        
        wait (rx_valid == 1) begin
            if (rx_data == 8'h41) begin
                $display("TEST PASSED: rx_data is the proper value");
            end
            else begin
                $error("TEST FAILED: rx_data is NOT the proper value");
            end
        end
        
        @(posedge clk);
        #1;
        if (rx_valid == 0) begin
            $display("TEST PASSED: rx_valid successfully went back to 0");
        end
        else begin
            $error("TEST FAILED: rx_valud DID NOT go back to 0");
        end
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule