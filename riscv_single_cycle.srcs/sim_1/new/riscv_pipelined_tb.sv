`timescale 1ns / 1ps

module riscv_pipelined_tb();

    integer i;
    integer errors;

    logic clk;
    logic reset;
    
    logic [31:0] predicted_registers [1:21];
    
    riscv_pipelined dut ( .clk(clk), .reset(reset) );
    
    initial begin
        clk = 0;
        reset = 1;
        errors = 0;
        
        predicted_registers[1]  = 32'd5;
        predicted_registers[2]  = 32'd12;
        predicted_registers[3]  = 32'd17;
        predicted_registers[4]  = 32'd17;
        predicted_registers[5]  = 32'd22;
        predicted_registers[6]  = 32'd0;
        predicted_registers[7]  = 32'd0;
        predicted_registers[8]  = 32'd0;
        predicted_registers[9]  = 32'd0;
        predicted_registers[10] = 32'd52;
        predicted_registers[11] = 32'd0;
        predicted_registers[12] = 32'd0;
        predicted_registers[13] = 32'd0;
        predicted_registers[14] = 32'd80;
        predicted_registers[15] = 32'd72;
        predicted_registers[16] = 32'd0;
        predicted_registers[17] = 32'd0;
        predicted_registers[18] = 32'd53;
        predicted_registers[19] = 32'd125;
        predicted_registers[20] = 32'd125;
        predicted_registers[21] = 32'd130;
        
        for ( i = 1; i <= 31; i++ ) begin
            dut.rf_inst.register_array[i] = 32'd0;   
        end
        
        @(negedge clk);
        reset = 0;
        
        repeat (50) begin
            @(posedge clk);
        end
        
        #2;
        
        for (i = 1; i <= 21; i++) begin
            if (dut.rf_inst.register_array[i] !== predicted_registers[i]) begin
                $error("Register %0d FAILED: actual=%0d expected=%0d", i, dut.rf_inst.register_array[i], predicted_registers[i]);
                errors = errors + 1;
            end
        end
        
        if (errors == 0) begin
            $display("-------------------------------");
            $display("ALL PIPELINE TESTS PASSED");
            $display("21/21 REGISTERS MATCHED");
            $display("-------------------------------");
            $finish;
        end
        else begin
            $error("PIPELINE TEST FAILED: %0d MISMATCHES", errors);
        end
        
        $finish;
    end
    
    always @(posedge clk) begin
        $display("dut.dm_inst.busy = %0d dut.dm_inst.counter = %0d dut.completed_transactionM = %0d  mem_readM = %0d dut.mem_writeM = %0d is_memory_stall = %0d", 
        dut.dm_inst.busy, dut.dm_inst.counter, dut.completed_transactionM, dut.mem_readM, dut.mem_writeM, dut.is_memory_stall);
    end

    
    always begin
        #5;
        clk = ~clk;
    end

endmodule
