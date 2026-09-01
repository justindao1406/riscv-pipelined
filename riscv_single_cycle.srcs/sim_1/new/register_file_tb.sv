`timescale 1ns / 1ps

module register_file_tb();

    logic clk;
    logic write_enable;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] write_addr;
    logic [31:0] write_data;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    
    register_file dut ( .clk(clk), .write_enable(write_enable), .rs1_addr(rs1_addr),
    .rs2_addr(rs2_addr), .write_addr(write_addr), .write_data(write_data),
    .rs1_data(rs1_data), .rs2_data(rs2_data) );
    
    initial begin
        clk = 0;
        write_enable = 0;
        write_addr = 0;
        write_data = 0;
        rs1_addr = 0;
        rs2_addr = 0;
        
        // TEST 1
        
        write_enable = 1;
        write_addr = 5'd1;
        write_data = 32'd42;
        @(posedge clk);
        #1;
        
        write_enable = 0;
        rs1_addr = 5'd1;
        #1;
        
        if (rs1_data == 32'd42) begin
            $display("TEST PASSED: rs1 is the correct data -> %0d", rs1_data);
        end
        else if (rs1_data !== 32'd42) begin
            $error("TEST FAILED: rs1 is not the correct data -> %0d", rs1_data);
            
        end
        
        // TEST 2
        
        // w/ write_enable still = 0
        // w/ write_addr still = 5'd1
        write_data = 32'd99;
        @(posedge clk);
        #1;
        
        if (rs1_data == 32'd42) begin
            $display("TEST PASSED: rs1 is STILL the correct data -> %0d", rs1_data);
        end
        else if (rs1_data !== 32'd42) begin
            $error("TEST FAILED: rs1 is not the correct data -> %0d", rs1_data);
            
        end
        
        // TEST 3
        
        write_enable = 1;
        write_addr = 5'd5;
        write_data = 32'd55;
        
        @(posedge clk);
        #1;
        
        write_addr = 5'd9;
        write_data = 32'd99;
        @(posedge clk);
        #1;
        
        write_enable = 0;
        rs1_addr = 5'd5;
        rs2_addr = 5'd9;
        
        #1;
        
        if (rs1_data == 32'd55 && rs2_data == 32'd99) begin
            $display("TEST PASSED: rs1 is %0d and rs2 is %0d", rs1_data, rs2_data);
        end
        else if (rs1_data !== 32'd55 || rs2_data !== 32'd99) begin
            $error("TEST FAILED: rs1 is not %0d or rs2 is not %0d", rs1_data, rs2_data);
            
        end
        
        // TEST 4
        
        write_enable = 1;
        write_addr = 5'd0;
        write_data = 32'd1234;
        
        @(posedge clk);
        #1;
        
        rs1_addr = 5'd0;
        rs2_addr = 5'd0;
        
        #1;
        
        if (rs1_data == 32'd0 && rs2_data == 32'd0) begin
            $display("TEST PASSED: rs1 is %0d and rs2 is %0d", rs1_data, rs2_data);
        end
        else if (rs1_data !== 32'd0 || rs2_data !== 32'd0) begin
            $error("TEST FAILED: rs1 is not %0d or rs2 is not %0d", rs1_data, rs2_data);
            
        end
        
        // TEST 5
        
        write_enable = 1;
        write_addr = 5'd5;
        write_data = 32'd22;
        rs1_addr = 5'd5;
        #1;
        
        if (rs1_data !== 32'd55) begin
            $error("TEST FAILED: Register data before clock edge is %0d and should be 55", rs1_data);
        end
        else begin
            $display("TEST PASSED: Register data before clock edge is %0d", rs1_data);
        end 
        
        @(posedge clk);
        #1;
        
        if (rs1_data !== 32'd22) begin
            $error("TEST FAILED: Register data after clock edge is %0d and should be 22", rs1_data);
        end
        else begin
            $display("TEST PASSED: Register data after clock edge is %0d", rs1_data);
        end
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end
    
endmodule
