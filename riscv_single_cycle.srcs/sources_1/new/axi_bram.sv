`timescale 1ns / 1ps

module axi_bram(
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
    
    // 0x0000 to 0xFFFF = 65 536 byte addresses
    // 65 536 / 4 = 16 384 word locations
    
    logic [31:0] bram [0:16383];
    
    logic write_pending;
    logic [31:0] write_addr_reg;  
    
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
            if (WSTRB[0]) begin
                bram[write_addr_reg[15:2]][7:0] <= WDATA[7:0]; // bram[word_index][bit_range]         
            end    
            if (WSTRB[1]) begin
                bram[write_addr_reg[15:2]][15:8] <= WDATA[15:8];        
            end 
            if (WSTRB[2]) begin
                bram[write_addr_reg[15:2]][23:16] <= WDATA[23:16];        
            end 
            if (WSTRB[3]) begin
                bram[write_addr_reg[15:2]][31:24] <= WDATA[31:24];        
            end   
            BVALID <= 1;
            BRESP <= 2'b00;                                                                  
        end
        
        else if (BVALID && BREADY) begin
            write_pending <= 0;
            BVALID <= 0;
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
        
        else if (ARVALID && ARREADY) begin
            RVALID <= 1;
            RRESP <= 2'b00;
            RDATA <= bram[ARADDR[15:2]];
        end
        
        else if (RVALID && RREADY) begin
            RVALID <= 0;
        end
    end       
    
endmodule
