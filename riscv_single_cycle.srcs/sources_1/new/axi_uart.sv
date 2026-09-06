`timescale 1ns / 1ps

module axi_uart(
    input logic clk,
    input logic reset,
    
    input logic [31:0] ARADDR,
    input logic ARVALID,
    input logic RREADY,
    
    input logic [31:0] AWADDR,
    input logic AWVALID,
    
    input logic [31:0] WDATA,
    input logic [3:0] WSTRB,
    input logic WVALID,
    
    input logic BREADY,
    
    input logic uart_rx_pin, // external device sends TX -> uart_rx_pin -> axi_uart -> CPU reads received byte
    
    output logic ARREADY,
    output logic [31:0] RDATA,
    output logic [1:0] RRESP,
    output logic RVALID,
    
    output logic AWREADY,
    output logic WREADY,
    
    output logic BVALID,
    output logic [1:0] BRESP,
    
    output logic uart_tx_pin // CPU writes byte -> axi_uart -> uart_tx_pin -> external device gets RX    
    );
    
    logic tx_start;
    logic [7:0] tx_data;
    
    logic tx_busy;
    
    logic [7:0] rx_data;
    logic rx_valid;
    
    uart_tx tx_inst ( .clk(clk), .reset(reset), .tx_start(tx_start), .tx_data(tx_data), .tx(uart_tx_pin), .tx_busy(tx_busy) );
    
    uart_rx rx_inst ( .clk(clk), .reset(reset), .rx(uart_rx_pin), .rx_data(rx_data), .rx_valid(rx_valid) );
    
    logic write_pending;
    logic [31:0] write_addr_reg;  
    
    logic [7:0] rx_data_reg;
    logic rx_available;
    
    // write (tx) comb
    
    always_comb begin
        AWREADY = 0;
        WREADY = 0;
        
        if (!write_pending) begin // idle phase
            AWREADY = 1;
            WREADY = 0;
        end
        
        else if (write_pending && !BVALID) begin
            WREADY = 1;
        end
        
        else if (write_pending && BVALID) begin
            WREADY = 0;
            AWREADY = 0;    
        end
        
    end
    
    // write (tx) ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            write_pending <= 0;
            write_addr_reg <= 32'd0;
            BVALID <= 0;
            BRESP <= 2'b00;       
            tx_start <= 0;
            tx_data <= 8'd0;     
        end
        else begin
            tx_start <= 0;
            if (AWVALID && AWREADY) begin
                write_pending <= 1;
                write_addr_reg <= AWADDR;                    
            end
            
            else if (WVALID && WREADY) begin
                if (write_addr_reg[11:0] == 12'h000 && WSTRB[0] == 1 && tx_busy == 0) begin 
                    tx_data <= WDATA[7:0];
                    tx_start <= 1;
                end   
                BVALID <= 1;
                BRESP <= 2'b00;           
            end
            
            else if (BVALID && BREADY) begin
                write_pending <= 0;
                BVALID <= 0;
            end
        end
    end
    
    // read (rx) comb
    
    always_comb begin
        ARREADY = 0;
        
        if (!RVALID) begin
            ARREADY = 1;
        end
        
        else if (RVALID) begin
            ARREADY = 0;
        end
    end
    
    // read (rx) ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            RVALID <= 0;
            RDATA <= 32'd0;
            RRESP <= 2'b00;
            rx_data_reg <= 0;
            rx_available <= 0;
        end
        else begin
            if (ARVALID && ARREADY) begin
                RVALID <= 1;
                RRESP <= 2'b00;
                RDATA <= 32'd0;
                // rx
                if (ARADDR[11:0] == 12'h004) begin
                    RDATA <= {24'd0, rx_data_reg};
                    rx_available <= 0;
                end    
                
                // status
                else if (ARADDR[11:0] == 12'h008) begin
                    RDATA <= {30'd0, rx_available, tx_busy};                    
                end
            end    
            
            else if (RVALID && RREADY) begin
                RVALID <= 0;
            end   
            
            if (rx_valid) begin
                rx_data_reg <= rx_data; // saves it in an internal register
                rx_available <= 1; // notifies CPU that an external device has sent data    
            end            
        end
    end
    
    // only limitation currently is that the a new rx byte will overwrite the previous. Fixed later w/ FIFO
    
endmodule
