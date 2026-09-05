`timescale 1ns / 1ps

module axi_gpio(
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
    
    input logic [3:0] gpio_in,
    
    output logic ARREADY,
    output logic [31:0] RDATA,
    output logic [1:0] RRESP,
    output logic RVALID,
    
    output logic AWREADY,
    output logic WREADY,
    
    output logic BVALID,
    output logic [1:0] BRESP,
    
    output logic [3:0] gpio_out
    );
    
    logic write_pending;
    
    logic [3:0] gpio_out_reg; // internal storage for gpio_out bc signals (WDATA) may change
    logic [31:0] write_addr_reg;
    
    // write comb
    
    always_comb begin
        gpio_out = gpio_out_reg;
        AWREADY = 0;
        WREADY = 0;
        
        if (!write_pending) begin // idle phase
            AWREADY = 1;
            WREADY = 0;
        end
        else if (write_pending && !BVALID) begin // Write data phase: waiting for W data
            WREADY = 1;
        end
        else if (write_pending && BVALID) begin // B phase
            AWREADY = 0;
            WREADY = 0;
        end
    end
    
    // read comb
    
    always_comb begin
        ARREADY = 0;
    
        if (!RVALID) begin
            ARREADY = 1;
        end
        else if (RVALID) begin
            ARREADY = 0;
        end
    end
    
    // write ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            gpio_out_reg <= 4'b0000;
            write_pending <= 0;
            write_addr_reg <= 0;
            BVALID <= 0;
            BRESP <= 2'b00;
        end
        
        else if (AWVALID && AWREADY) begin
            write_pending <= 1;
            write_addr_reg <= AWADDR;
        end
        
        else if (WVALID && WREADY) begin
            if (write_addr_reg[11:0] == 12'h000 && WSTRB[0] == 1) begin
                gpio_out_reg <= WDATA[3:0];
            end
            BVALID <= 1;
            BRESP <= 2'b00;
        end
        
        else if (BVALID && BREADY) begin
            write_pending <= 0;
            BVALID <= 0;
        end
    end
    
    // read ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            RVALID <= 0;
            RDATA <= 4'd0;
            RRESP <= 2'b00;
        end
        
        else if (ARVALID && ARREADY) begin
            RVALID <= 1;
            RRESP <= 2'b00;
            if (ARADDR[11:0] == 12'h004) begin
                RDATA <= {28'd0, gpio_in};
            end
            else if (ARADDR[11:0] == 12'h000) begin
                RDATA <= {28'd0, gpio_out_reg}; // read the previous write that's been stored in gpio_out_reg
            end
        end
        
        else if (RVALID && RREADY) begin
            RVALID <= 0;
        end
        
    end
    
endmodule
