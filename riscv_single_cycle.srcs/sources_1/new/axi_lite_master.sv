`timescale 1ns / 1ps

module axi_lite_master(
    input clk,
    input reset,
    
    // input: CPU -> AXI
    input logic [31:0] store_data, 
    input logic mem_request, 
    input logic mem_read_or_write, // 0 for read (load) and 1 for write (store)
    input logic [31:0] mem_address,
    
    // input: slave (peripheral) -> master (AXI)
    input logic ARREADY, 
    input logic [31:0] RDATA,
    input logic [1:0] RRESP,
    input logic RVALID,
    
    // output: AXI -> CPU
    output logic [31:0] load_data, 
    output logic completed_transaction,
    
    // output: master (AXI) -> slave (peripheral)
    output logic [31:0] ARADDR,
    output logic ARVALID,
    output logic RREADY
    );
    
    typedef enum logic [1:0] {
        IDLE,
        READ_ADDR,
        READ_DATA
    } state_t;
    
    state_t current_state;
    state_t next_state;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            current_state <= IDLE;
        end
        else begin
            current_state <= next_state;
        end
    end
    
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            
            IDLE: begin
                if (mem_request && !mem_read_or_write) begin
                    next_state = READ_ADDR;
                end  
            end
            
            READ_ADDR: begin
                if (ARVALID && ARREADY) begin
                    next_state = READ_DATA;
                end    
            end
            
            READ_DATA: begin
                if (RVALID && RREADY) begin
                    next_state = IDLE;
                end    
            end
        
        endcase    
    end
    
    always_comb begin
        ARADDR = 32'd0;
        ARVALID = 1'd0;
        RREADY = 1'd0;
        
        load_data = 32'd0;
        completed_transaction = 1'd0;
        
        case (current_state)
            
            READ_ADDR: begin
                ARADDR = mem_address;
                ARVALID = 1;        
            end
            
            READ_DATA: begin
                RREADY = 1;
                if (RREADY && RVALID) begin
                    completed_transaction = 1;
                    load_data = RDATA;
                end
            end
        
        endcase    
    end
    
endmodule
    
    

