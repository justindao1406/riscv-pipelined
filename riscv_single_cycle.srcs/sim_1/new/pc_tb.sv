`timescale 1ns / 1ps

module pc_tb();

    logic clk;
    logic reset;
    logic [31:0] next_pc;
    logic [31:0] current_pc;
    
    pc dut ( .clk(clk), .reset(reset), .next_pc(next_pc), .current_pc(current_pc) );
    
    initial begin
        reset = 0;
        clk = 0;
        next_pc = 32'd0;
        
        // TEST 1
    
        reset = 1;
        next_pc = 32'd100;
        
        @(posedge clk);
        #1;
        
        if (current_pc !== 32'd0) begin
            $error("TEST FAILED: current_pc is %0d", current_pc);
        end
        else begin
            $display("TEST PASSED: current_pc is %0d", current_pc);
        end
        
        // TEST 2
        
        reset = 0;
        next_pc = 32'd4;
        
        @(posedge clk);
        #1;
        
        if (current_pc !== 32'd4) begin
            $error("TEST FAILED: current_pc is %0d", current_pc);
        end
        else begin
            $display("TEST PASSED: current_pc is %0d", current_pc);
        end
        
        // TEST 3
        
        next_pc = 32'd8;
        
        @(posedge clk);
        #1;
        
        if (current_pc !== 32'd8) begin
            $error("TEST FAILED: current_pc is %0d", current_pc);
        end
        else begin
            $display("TEST PASSED: current_pc is %0d", current_pc);
        end
        
        // TEST 4
        
        next_pc = 32'd12;
        
        if (current_pc !== 32'd8) begin
            $error("TEST FAILED: current_pc is %0d before clock edge", current_pc);
        end
        else begin
            $display("TEST PASSED: current_pc is %0d before clock edge", current_pc);
        end 
        
        @(posedge clk);
        #1;
        
        if (current_pc !== 32'd12) begin
            $error("TEST FAILED: current_pc is %0d after clock edge", current_pc);
        end
        else begin
            $display("TEST PASSED: current_pc is %0d after clock edge", current_pc);
        end 
        
        // TEST 5
        
        reset = 1;
        next_pc = 32'd100;
        
        @(posedge clk);
        #1;
        
        if (current_pc !== 32'd0) begin
            $error("TEST FAILED: current_pc is %0d", current_pc);
        end
        else begin
            $display("TEST PASSED: current_pc is %0d", current_pc);
        end
        
        $finish;
    end
    
    always begin
    #5;
    clk = ~clk;
    end
    
endmodule
