`timescale 1ns / 1ps

module riscv_fir_integration_tb();
    // Note: fir_integration.mem must be read for this test to work.
    
    integer i;
    integer errors;

    logic clk;
    logic reset;
    logic [3:0] gpio_in;
    logic [3:0] gpio_out;
    logic uart_rx_pin;
    logic uart_tx_pin;
    logic [31:0] debug_pc;
    logic [31:0] debug_write_data;
    
    logic [31:0] predicted_registers [1:21];
    
    riscv_system dut 
    ( .clk(clk), .reset(reset), .gpio_in(gpio_in), .gpio_out(gpio_out), .uart_rx_pin(uart_rx_pin),
    .uart_tx_pin(uart_tx_pin), .debug_pc(debug_pc), .debug_write_data(debug_write_data) );
    
    
    
    initial begin
        clk = 0;
        reset = 1;
        errors = 0;
        
        gpio_in = 4'b0000;
        uart_rx_pin = 1;
        
        predicted_registers[1]  = 32'h1000_3000;
        predicted_registers[2]  = 32'd1000;
        predicted_registers[3]  = 32'd1;
        predicted_registers[4]  = 32'hFFFF_FFFC;
        predicted_registers[5]  = 32'd0;
        predicted_registers[6]  = 32'd0;
        predicted_registers[7]  = 32'd0;
        predicted_registers[8]  = 32'd0;
        predicted_registers[9]  = 32'd0;
        predicted_registers[10] = 32'd0;
        predicted_registers[11] = 32'd0;
        predicted_registers[12] = 32'd0;
        predicted_registers[13] = 32'd0;
        predicted_registers[14] = 32'd0;
        predicted_registers[15] = 32'd0;
        predicted_registers[16] = 32'd0;
        predicted_registers[17] = 32'd0;
        predicted_registers[18] = 32'd0;
        predicted_registers[19] = 32'd0;
        predicted_registers[20] = 32'd0;
        predicted_registers[21] = 32'd0;
        
        for ( i = 1; i <= 31; i++ ) begin
            dut.cpu_inst.rf_inst.register_array[i] = 32'd0;   
        end
        
        @(negedge clk);
        reset = 0;
        
        repeat(150) begin
            @(posedge clk);
        end
        
        for (i = 1; i <= 21; i++) begin
            if (dut.cpu_inst.rf_inst.register_array[i] !== predicted_registers[i]) begin
                $error("Register %0d FAILED: actual=%08h expected=%08h", i, dut.cpu_inst.rf_inst.register_array[i], predicted_registers[i]);
                errors = errors + 1;
            end
        end
        
        if (errors == 0) begin
            $display("-------------------------------");
            $display("ALL FIR INTEGRATION TESTS PASSED");
            $display("21/21 REGISTERS MATCHED");
            $display("-------------------------------");
            $finish;
        end
        else begin
            $error("FIR INTEGRATION TEST FAILED: %0d MISMATCHES", errors);
        end
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule
