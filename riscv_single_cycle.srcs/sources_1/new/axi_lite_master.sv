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
    
    input logic AWREADY,
    input logic WREADY,
    input logic [1:0] BRESP,
    input logic BVALID,
    
    // output: AXI -> CPU
    output logic [31:0] load_data, 
    output logic completed_transaction,
    
    // output: master (AXI) -> slave (peripheral)
    output logic [31:0] ARADDR,
    output logic ARVALID,
    output logic RREADY,
    
    output logic [31:0] AWADDR,
    output logic AWVALID,
    output logic [31:0] WDATA,
    output logic [3:0] WSTRB,
    output logic WVALID,
    output logic BREADY
    );
    
    logic address_done;
    logic data_done;
    
    typedef enum logic [2:0] {
        IDLE,
        READ_ADDR,
        READ_DATA,
        WRITE_SEND,
        WRITE_RESPONSE
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
                else if (mem_request && mem_read_or_write) begin
                    next_state = WRITE_SEND;
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
            
            WRITE_SEND: begin
                if (address_done && data_done) begin
                    next_state = WRITE_RESPONSE;
                end
            end
            
            WRITE_RESPONSE: begin
                if (BVALID && BREADY) begin
                    next_state = IDLE;
                end
            end
        
        default: next_state = IDLE;
        endcase    
    end
    
    always_comb begin
        ARADDR = 32'd0;
        ARVALID = 1'd0;
        RREADY = 1'd0;
        AWADDR = 32'd0;
        AWVALID = 1'd0;
        WDATA = 32'd0;
        WSTRB = 4'd0;
        WVALID = 1'd0;
        BREADY = 1'd0;
        
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
            
            WRITE_SEND: begin
                AWADDR = mem_address;
                WDATA = store_data;
                WSTRB = 4'b1111;
                
                AWVALID = 1;
                WVALID = 1;
                
                if (address_done) begin
                    AWVALID = 0;
                end
                if (data_done) begin
                    WVALID = 0;
                end
                
            end
            
            WRITE_RESPONSE: begin
                BREADY = 1'd1;
                if (BVALID && BREADY) begin
                    completed_transaction = 1'd1;  
                end
            end
        
        endcase    
    end
    
    always_ff @(posedge clk) begin
        if (reset) begin
            address_done <= 1'd0;
            data_done <= 1'd0;  
        end
        else begin
            if (AWVALID && AWREADY) begin
                address_done <= 1'd1;
            end 
            if (WVALID && WREADY) begin
                data_done <= 1'd1;
            end
            if (BVALID && BREADY) begin
                address_done <= 1'd0;
                data_done <= 1'd0;
            end   
        end
    end
    
endmodule
    
    

