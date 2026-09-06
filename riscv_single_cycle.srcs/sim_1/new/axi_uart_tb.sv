`timescale 1ns / 1ps

module axi_uart_tb();

    logic clk;
    logic reset;

    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;

    logic [31:0] AWADDR;
    logic AWVALID;

    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;

    logic BREADY;

    logic uart_rx_pin;

    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;

    logic AWREADY;
    logic WREADY;

    logic BVALID;
    logic [1:0] BRESP;

    logic uart_tx_pin;
    
    logic [7:0] expected;

    axi_uart dut (
        .clk(clk),
        .reset(reset),

        .ARADDR(ARADDR),
        .ARVALID(ARVALID),
        .RREADY(RREADY),

        .AWADDR(AWADDR),
        .AWVALID(AWVALID),

        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WVALID(WVALID),

        .BREADY(BREADY),

        .uart_rx_pin(uart_rx_pin),

        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),

        .AWREADY(AWREADY),
        .WREADY(WREADY),

        .BVALID(BVALID),
        .BRESP(BRESP),

        .uart_tx_pin(uart_tx_pin)
    );
    
    initial begin
        reset = 1;
        clk = 0;
        ARADDR = 0;
        ARVALID = 0;
        RREADY = 0;
        AWADDR = 0;
        AWVALID = 0;
        WDATA = 0;
        WSTRB = 0;
        WVALID = 0;
        BREADY = 0;
        uart_rx_pin = 1;
        expected = 8'h41;
        
        repeat (2) begin
            @(posedge clk);
        end
        #1; 
        
        reset = 0;
        
        // Test 1 : UART TX
        
        AWADDR = 32'h1000_1000;
        AWVALID = 1;
        
        wait (AWVALID && AWREADY) begin
            if (AWVALID && AWREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end
        
        @(posedge clk);
        #1;
        
        AWVALID = 0;
        WVALID = 1;
        WDATA = 32'h0000_0041;
        WSTRB = 4'b0001;
        
        wait (WVALID && WREADY) begin
            if (WVALID && WREADY) begin
                $display("TEST PASSED: Data successful");
            end
            else begin
                $error("TEST FAILED: Data failed");
            end        
        end      
        
        @(posedge clk);
        #1;
        WVALID = 0;
        
        wait (dut.tx_busy == 1);
        #1;
        
        if (uart_tx_pin == 0) begin
            $display("TEST PASSED: START bit correct");
        end
        else begin
            $error("TEST FAILED: START bit incorrect");
        end
        
        wait (dut.tx_inst.baud_counter == 10'd867);
        @(posedge clk);
        #1;
        
        for (int i = 0; i < 8; i++) begin
            if (uart_tx_pin == expected[i]) begin
                $display("TEST PASSED: TX bit[%0d] = %0d", i, expected[i]);
            end
            else begin
                $error("TEST FAILED: TX bit[%0d] expected %0d, got %0d", i, expected[i], uart_tx_pin);                
            end
            wait (dut.tx_inst.baud_counter == 10'd867);
            @(posedge clk);
            #1;
        end
        
        if (uart_tx_pin == 1 && dut.tx_busy == 1) begin
            $display("TEST PASSED: STOP bit correct");
        end
        else begin
            $error("TEST FAILED: STOP bit incorrect");
        end
        
        wait (dut.tx_inst.baud_counter == 10'd867);
        @(posedge clk);
        #1;
        
        if (uart_tx_pin == 1 && dut.tx_busy == 0) begin
            $display("TEST PASSED: UART TX returned to IDLE");
        end
        else begin
            $error("TEST FAILED: UART TX NOT returned to IDLE");
        end
        
        if (BVALID && BRESP == 2'b00) begin
            $display("TEST PASSED: AXI write response OKAY");
        end
        else begin
            $error("TEST FAILED: AXI write response incorrect");
        end
        
        BREADY = 1;
        
        @(posedge clk);
        #1;
        
        BREADY = 0;
        
        // TEST 2 : UART RX
        
        repeat (2) begin
            @(posedge clk);
        end
        #1; 
        
        // Sending RX 8'h41 first : 1 0 0 0 0 0 1 0
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 1;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 1;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 0;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        uart_rx_pin = 1;
        repeat (868) begin
            @(posedge clk);
        end
        #1;
        
        wait (dut.rx_available);
        #1;
        
        ARADDR = 32'h1000_1004;
        ARVALID = 1;                

        wait (ARVALID && ARREADY) begin
            if (ARVALID && ARREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end        
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'h0000_0041) begin
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for UART read");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for UART read");
        end
        
        RREADY = 1;
        
        @(posedge clk);
        #1;
        
        RREADY = 0;
        
        if (RVALID == 0) begin
            $display("TEST PASSED: RVALID went back to 0 (idle)");
        end
        else begin
            $error("TEST FAILED: RVALID DID NOT go back to 0 (not idle)");
        end
        
        // TEST 3 : UART STATUS
        
        ARADDR = 32'h1000_1008;
        ARVALID = 1;                

        wait (ARVALID && ARREADY) begin
            if (ARVALID && ARREADY) begin
                $display("TEST PASSED: Address successful");
            end
            else begin
                $error("TEST FAILED: Address failed");
            end        
        end        
        
        @(posedge clk);
        #1;
        
        ARVALID = 0;
        
        if (RVALID == 1 && RRESP == 2'b00 && RDATA == 32'd0) begin // 0 because rx_available = 0 and tx_busy = 0
            $display("TEST PASSED: RVALID, RRESP and RDATA are correct for UART STATUS");
        end
        else begin
            $error("TEST FAILED: RVALID, RRESP and RDATA are NOT correct for UART STAUTS");
        end
        
        RREADY = 1;
        
        @(posedge clk);
        #1;
        
        RREADY = 0;
        
        if (RVALID == 0) begin
            $display("TEST PASSED: RVALID went back to 0 (idle)");
        end
        else begin
            $error("TEST FAILED: RVALID DID NOT go back to 0 (not idle)");
        end

        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end

endmodule