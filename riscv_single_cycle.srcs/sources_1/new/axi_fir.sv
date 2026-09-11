`timescale 1ns / 1ps

module axi_fir(
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
    
    logic signed [15:0] fir_sample_in;  // captures WDATA and is input for FIR inst
    logic signed [15:0] fir_sample_out; // calculated result directly from the FIR inst
    
    logic signed [15:0] fir_sample_out_reg; // saves fir_sample_out for RDATA
    logic result_available;
    
    logic fir_sample_valid; // axi_fir tells fir to accept sample
    logic fir_output_valid; // fir tells axi_fir that fir_sample_out contains a result
    
    logic write_pending;
    logic [31:0] write_addr_reg;  
    
    fir_filter_q15_top fir_inst ( .clk(clk), .reset(reset), .sample_in(fir_sample_in), 
    .sample_valid(fir_sample_valid), .sample_out(fir_sample_out), .output_valid(fir_output_valid) );
    
    // write comb
    
    always_comb begin
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
    
    // write ff
    
    always_ff @(posedge clk) begin
        if (reset) begin
            fir_sample_in <= 16'd0;
            fir_sample_valid <= 0;
            write_pending <= 0;
            write_addr_reg <= 0;
            BVALID <= 0;
            BRESP <= 2'b00;
        end
        else begin
            fir_sample_valid <= 0;
            
            if (AWVALID && AWREADY) begin
                write_pending <= 1;
                write_addr_reg <= AWADDR;
            end
            
            else if (WVALID && WREADY) begin // writes input
                if (write_addr_reg[11:0] == 12'h000 && WSTRB[0] == 1 && WSTRB[1] == 1) begin
                    fir_sample_in <= WDATA[15:0];
                    fir_sample_valid <= 1;
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
            result_available <= 0;
            fir_sample_out_reg <= 16'd0;
            RVALID <= 0;
            RDATA <= 32'd0;
            RRESP <= 2'b00;
        end
        
        else begin
            if (ARVALID && ARREADY) begin
                RVALID <= 1;
                RRESP <= 2'b00;
                RDATA <= 32'd0;
                if (ARADDR[11:0] == 12'h004) begin // reads output
                    RDATA <= {{16{fir_sample_out_reg[15]}}, fir_sample_out_reg};
                    result_available <= 0;
                end
                else if (ARADDR[11:0] == 12'h008) begin // reads status
                    RDATA <= {31'd0, result_available};
                end
            end
            
            else if (RVALID && RREADY) begin
                RVALID <= 0;
            end
            
            if (fir_output_valid) begin
                fir_sample_out_reg <= fir_sample_out;
                result_available <= 1;
            end
        end
    end
    
endmodule
