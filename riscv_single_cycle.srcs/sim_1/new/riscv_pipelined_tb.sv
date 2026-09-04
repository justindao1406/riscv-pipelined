`timescale 1ns / 1ps

module riscv_pipelined_tb();

    integer i;
    integer errors;

    logic clk;
    logic reset;
    logic [31:0] debug_pc;
    logic [31:0] debug_write_data;
    
    logic [31:0] predicted_registers [1:21];
    
    riscv_system dut 
    ( .clk(clk), .reset(reset), 
    .debug_write_data(debug_write_data) );
    
    initial begin
        clk = 0;
        reset = 1;
        errors = 0;
        
        dut.ARREADY = 0;
        dut.RVALID  = 0;
        dut.RDATA   = 0;
        dut.RRESP   = 2'b00;
        
        dut.AWREADY = 0;
        dut.WREADY  = 0;
        dut.BVALID  = 0;
        dut.BRESP   = 2'b00;
        
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
            dut.cpu_inst.rf_inst.register_array[i] = 32'd0;   
        end
        
        @(negedge clk);
        reset = 0;
        
        // --- First load/store pair ---
        
        wait (dut.mem_request && dut.mem_read_or_write);
        
        wait(dut.AWVALID && dut.WVALID) begin
            $display("AWVALID = %0d WVALID = %0d", dut.AWVALID, dut.WVALID);
            dut.AWREADY = 1;
            dut.WREADY = 1;
        end
        
        @(posedge clk);
        #1;
        $display("AWVALID = %0d WVALID = %0d", dut.AWVALID, dut.WVALID);
        
        dut.AWREADY = 0;
        dut.WREADY = 0;
        
        dut.BRESP = 2'b00;
        dut.BVALID = 1;
        
        wait(dut.BREADY);
        #1;
        
        if (dut.completed_transaction) begin
            $display("TEST PASSED: Store has completed transaction");
        end        
        
        @(posedge clk);
        #1;
        
        dut.BVALID = 0;
        
        wait (dut.mem_request && !dut.mem_read_or_write);
        
        wait(dut.ARVALID) begin
            $display("ARVALID = %0d", dut.ARVALID);
            dut.ARREADY = 1;
        end
    
        
        @(posedge clk);
        #1;
        
        dut.ARREADY = 0;
        
        $display("ARVALID = %0d", dut.ARVALID);
        
        dut.RDATA = 32'd17;
        dut.RRESP = 2'b00;
        dut.RVALID = 1;
        
        wait(dut.RREADY);
        #1;
        
        if (dut.completed_transaction) begin
            $display("TEST PASSED: Load has completed transaction");
        end        
        
        @(posedge clk);
        #1;
        
        dut.RVALID = 0;
        
        @(posedge clk);
        
        // Second load/store pair 
        
        wait (dut.mem_request && dut.mem_read_or_write);
        
        wait(dut.AWVALID && dut.WVALID) begin
            $display("AWVALID = %0d WVALID = %0d", dut.AWVALID, dut.WVALID);
            dut.AWREADY = 1;
            dut.WREADY = 1;
        end
        
        @(posedge clk);
        #1;
        $display("AWVALID = %0d WVALID = %0d", dut.AWVALID, dut.WVALID);
        
        dut.AWREADY = 0;
        dut.WREADY = 0;
        
        dut.BRESP = 2'b00;
        dut.BVALID = 1;
        
        wait(dut.BREADY);
        #1;
        
        if (dut.completed_transaction) begin
            $display("TEST PASSED: Store has completed transaction");
        end        
        
        @(posedge clk);
        #1;
        
        dut.BVALID = 0;
        
        wait (dut.mem_request && !dut.mem_read_or_write);
        
        wait(dut.ARVALID) begin
            $display("ARVALID = %0d", dut.ARVALID);
            dut.ARREADY = 1;
        end
    
        
        @(posedge clk);
        #1;
        
        dut.ARREADY = 0;
        
        $display("ARVALID = %0d", dut.ARVALID);
        
        dut.RDATA = 32'd125;
        dut.RRESP = 2'b00;
        dut.RVALID = 1;
        
        wait(dut.RREADY);  
        #1;
        
        if (dut.completed_transaction) begin
            $display("TEST PASSED: Load has completed transaction");
        end        
        
        @(posedge clk);
        #1;
        
        dut.RVALID = 0;
        
        #2;
        
        repeat(50) begin
            @(posedge clk);
        end
        
        for (i = 1; i <= 21; i++) begin
            if (dut.cpu_inst.rf_inst.register_array[i] !== predicted_registers[i]) begin
                $error("Register %0d FAILED: actual=%0d expected=%0d", i, dut.cpu_inst.rf_inst.register_array[i], predicted_registers[i]);
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
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule
