`timescale 1ns / 1ps

module uart_tx_tb();

    logic clk;
    logic reset;
    logic tx_start;
    logic [7:0] tx_data;

    logic tx;
    logic tx_busy;
    
    logic [7:0] expected;

    uart_tx dut ( .clk(clk), .reset(reset), .tx_start(tx_start), .tx_data(tx_data), .tx(tx), .tx_busy(tx_busy) );

    initial begin
        clk = 0;
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;
        
        expected = 8'h41;
        
        repeat (2) begin
            @(posedge clk);
        end
        #1;
        reset = 0;
        #1;
        
        if (tx == 1 && tx_busy == 0) begin
            $display("TEST PASSED: tx and tx_busy proper values when IDLE");
        end
        else begin
            $error("TEST FAILED: tx and tx_busy NOT proper values when IDLE");
        end
        
        tx_start = 1;
        tx_data = 8'h41; // 01000001
        
        @(posedge clk);
        #1;
        
        tx_start = 0;
        tx_data = 8'h00;
        
        if (tx == 0 && tx_busy == 1) begin
            $display("TEST PASSED: tx and tx_busy proper values when START");
        end
        else begin
            $error("TEST FAILED: tx and tx_busy NOT proper values when START");
        end
        
        wait (dut.baud_counter == 10'd867);
        @(posedge clk);
        #1;
        
        for (int i = 0; i < 8; i++) begin
            if (tx == expected[i] && tx_busy) begin
                $display("TEST PASSED: tx matches expected[%0d] = %0d and tx_busy proper value", i, expected[i]);
            end
            else begin
                $error("TEST FAILED: tx DOES NOT match expected[%0d] = %0d OR tx_busy not proper value", i, expected[i]);
            end
            wait (dut.baud_counter == 10'd867);
            @(posedge clk);
            #1;
        end
        
        if (tx == 1 && tx_busy == 1) begin
            $display("TEST PASSED: tx and tx_busy proper values when STOP");
        end
        else begin
            $error("TEST FAILED: tx and tx_busy NOT proper values when STOP");
        end
        
        wait (dut.baud_counter == 10'd867);
        @(posedge clk);
        #1;
        
        if (tx == 1 && tx_busy == 0) begin
            $display("TEST PASSED: tx and tx_busy proper values when IDLE");
        end
        else begin
            $error("TEST FAILED: tx and tx_busy NOT proper values when IDLE");
        end        
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule