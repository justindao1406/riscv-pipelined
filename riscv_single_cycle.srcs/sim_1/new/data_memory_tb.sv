`timescale 1ns / 1ps

module data_memory_tb();

    logic clk;
    logic write_enable;
    logic [31:0] address;
    logic [31:0] data_in;
    logic [31:0] data_out;
    
    data_memory dut ( .clk(clk), .write_enable(write_enable), .address(address), .data_in(data_in), .data_out(data_out) );
    
    initial begin
        clk = 0;
        write_enable = 0;
        address = 0;
        data_in = 0;
        dut.memory_array[0] = 32'd10;
        dut.memory_array[3] = 32'd55;
        dut.memory_array[5] = 32'd11;
        dut.memory_array[9] = 32'd77;
        dut.memory_array[255] = 32'h12345678;
    end
    
    task automatic check_dm(
        input logic test_write_enable,
        input logic [31:0] test_address,
        input logic [31:0] predicted_res
    );
        begin
            write_enable = test_write_enable;
            address = test_address;
            #1;
            
            if (data_out !== predicted_res) begin
                $error("TEST FAILED: The data out %0d does not match the predicted data %0d", data_out, predicted_res);
            end
            else begin
                $display("TEST PASSED: data out = %0d", data_out);
            end     
            
        end
    endtask
    
    initial begin
        #1;
        
        // TEST 1
        
        check_dm(0, 32'd12, 32'd55);
        
        // TEST 2
        
        write_enable = 1;
        address = 32'd20;
        data_in = 32'd42;
        
        @(posedge clk);
        #1;
        
        check_dm(0, 32'd20, 32'd42);
        
        // TEST 3
        
        write_enable = 0;
        address = 32'd20;
        data_in = 32'd99;
        
        @(posedge clk);
        #1;
        
        check_dm(0, 32'd20, 32'd42);
        
        // TEST 4
        
        write_enable = 1;
        address = 32'd36;
        data_in = 32'd99;
        
        @(posedge clk);
        #1;
        
        check_dm(0, 32'd20, 32'd42);
        check_dm(0, 32'd36, 32'd99);
        
        // TEST 5
        
        write_enable = 1;
        address = 32'd0;
        data_in = 32'd1234;
        
        @(posedge clk);
        #1;
        
        check_dm(0, 32'd0, 32'd1234);
        
        // TEST 6
        
        write_enable = 1;
        address = 32'd20;
        data_in = 32'd22;
        
        check_dm(1, 32'd20, 32'd42);
        
        @(posedge clk);
        #1;
        
        check_dm(0, 32'd20, 32'd22);
        
        $finish;
    end
    
    always begin 
        #5;
        clk = ~clk;
    end
    
endmodule
