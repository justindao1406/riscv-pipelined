`timescale 1ns / 1ps

module axi_timer(
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
    
    output logic ARREADY,
    output logic [31:0] RDATA,
    output logic [1:0] RRESP,
    output logic RVALID,
    
    output logic AWREADY,
    output logic WREADY,
    
    output logic BVALID,
    output logic [1:0] BRESP  
    );
    
    logic [31:0] count;
    logic enable;
    logic [31:0] compare;
    logic compare_match;
    
    logic write_pending;
    logic [31:0] write_addr_reg;  
    
    // write -> CONTROL and COMPARE
    // read -> COUNT and CONTROL and COMPARE and STATUS
    
    // write comb
    
    always_comb begin
        AWREADY = 0;
        WREADY = 0;
        
        if (!write_pending) begin
            AWREADY = 1;
            WREADY = 0;
        end
        
        else if (write_pending && !BVALID) begin
            WREADY = 1;
        end
        
        else if (write_pending && BVALID) begin
            WREADY = 0;
        end  
    end
    
    // write ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            count <= 0;
            enable <= 0;
            compare <= 0;
            compare_match <= 0;
            write_pending <= 0;
            write_addr_reg <= 0;
            BVALID <= 0;
            BRESP <= 0;
        end
        else begin
            if (enable) begin
                count <= count + 1;    
                if ((count + 1) == compare) begin // count + 1 because nonblocking assignment uses old count value
                    compare_match <= 1;
                end
            end
        
            if (AWVALID && AWREADY) begin
                write_pending <= 1;
                write_addr_reg <= AWADDR;
            end
            
            else if (WVALID && WREADY) begin
                if (write_addr_reg[11:0] == 12'h004 && WSTRB[0] == 1) begin // CONTROL
                    if (WDATA[0] == 1) begin // enable
                        enable <= 1;
                    end    
                    else if (WDATA[0] == 0) begin // disable
                        enable <= 0;
                    end
                    if (WDATA[1] == 1) begin // clear
                        count <= 0;
                        compare_match <= 0;
                    end
                end
                else if (write_addr_reg[11:0] == 12'h008 && WSTRB == 4'b1111) begin // COMPARE
                    compare <= WDATA[31:0];    
                end
                BVALID <= 1;
                BRESP <= 2'b00;
            end
            
            else if (BVALID && BREADY) begin
                BVALID <= 0;
                write_pending <= 0;
            end
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
    
    // read ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            RVALID <= 0;
            RDATA <= 32'd0;
            RRESP <= 2'b00;
        end
        else begin
            if (ARVALID && ARREADY) begin
                RVALID <= 1;
                RRESP <= 2'b00;
                RDATA <= 32'd0;
                if (ARADDR[11:0] == 12'h000) begin
                    RDATA <= count;
                end
                else if (ARADDR[11:0] == 12'h004) begin
                    RDATA <= {31'd0, enable}; // bit 1 clear is a command, not a stored state so it cant be read
                end 
                else if (ARADDR[11:0] == 12'h008) begin
                    RDATA <= compare; 
                end      
                else if (ARADDR[11:0] == 12'h00C) begin
                    RDATA <= {31'd0, compare_match}; 
                end                               
            end  
            else if (RVALID && RREADY) begin  
                RVALID <= 0;
            end
        end
    end
    
endmodule
