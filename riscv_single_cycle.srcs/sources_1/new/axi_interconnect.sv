`timescale 1ns / 1ps

module axi_interconnect(
    input clk,
    input reset,
    
    // input: master (AXI master) -> slave (interconnect)
    input logic [31:0] ARADDR,
    input logic ARVALID,
    input logic RREADY,
    
    input logic [31:0] AWADDR,
    input logic AWVALID,
    input logic [31:0] WDATA,
    input logic [3:0] WSTRB,
    input logic WVALID,
    input logic BREADY,
    
    // AXI slave -> interconnect
    
    input logic memory_ARREADY,
    input logic memory_AWREADY,
    input logic [31:0] memory_RDATA,
    input logic memory_RVALID,
    input logic [1:0] memory_RRESP,
    input logic memory_WREADY,
    input logic [1:0] memory_BRESP,
    input logic memory_BVALID,
    input logic gpio_ARREADY,
    input logic gpio_AWREADY,
    input logic [31:0] gpio_RDATA,
    input logic gpio_RVALID,
    input logic [1:0] gpio_RRESP,
    input logic gpio_WREADY,
    input logic [1:0] gpio_BRESP,
    input logic gpio_BVALID,
    
    // output: slave (interconnect) -> master (AXI master)
    output logic ARREADY,
    output logic [31:0] RDATA,
    output logic [1:0] RRESP,
    output logic RVALID,
    
    output logic AWREADY,
    output logic WREADY,
    output logic [1:0] BRESP,
    output logic BVALID,
    
    // interconnect -> AXI slave
    output logic [31:0] memory_ARADDR,
    output logic [31:0] memory_AWADDR,
    output logic [31:0] gpio_ARADDR,
    output logic [31:0] gpio_AWADDR,
    output logic memory_ARVALID,
    output logic memory_AWVALID,
    output logic memory_RREADY,
    output logic gpio_ARVALID,
    output logic gpio_AWVALID,
    output logic gpio_RREADY,
    output logic [31:0] memory_WDATA,
    output logic [3:0] memory_WSTRB,
    output logic memory_WVALID,
    output logic memory_BREADY,
    output logic [31:0] gpio_WDATA,
    output logic [3:0] gpio_WSTRB,
    output logic gpio_WVALID,
    output logic gpio_BREADY
    );
    
    // select flags
    
    logic memory_read_select;
    logic gpio_read_select;
    
    logic memory_write_select;
    logic gpio_write_select;
    
    // read transaction tracker
    
    typedef enum logic [1:0] {
        READ_NONE,
        READ_MEMORY,
        READ_GPIO
    } read_owner_t;
    
    read_owner_t read_owner;
    
    // write transaction tracker
    
    typedef enum logic [1:0] {
        WRITE_NONE,
        WRITE_MEMORY,
        WRITE_GPIO
    } write_owner_t;
    
    write_owner_t write_owner;
    
    // pick the peripheral + provide VALID to slave
    
    always_comb begin
        memory_read_select  = 0;
        gpio_read_select    = 0;
        memory_write_select = 0;
        gpio_write_select   = 0;
        memory_ARVALID = 0;
        gpio_ARVALID   = 0;
        memory_AWVALID = 0;
        gpio_AWVALID   = 0;    
        memory_ARADDR = 32'd0;
        memory_AWADDR = 32'd0;
        gpio_ARADDR = 32'd0;
        gpio_AWADDR = 32'd0;           
    
        if (ARADDR[31:16] == 16'h0000) begin
            memory_read_select = 1;
            memory_ARADDR = ARADDR;
            memory_ARVALID = ARVALID;
        end
        if (AWADDR[31:16] == 16'h0000) begin
            memory_write_select = 1;
            memory_AWADDR = AWADDR;
            memory_AWVALID = AWVALID;
        end
        
        if (ARADDR[31:12] == 20'h10000) begin
            gpio_read_select = 1;
            gpio_ARADDR   = ARADDR;
            gpio_ARVALID = ARVALID;
        end
        
        if (AWADDR[31:12] == 20'h10000) begin
            gpio_write_select = 1;
            gpio_AWADDR   = AWADDR;
            gpio_AWVALID = AWVALID;
        end
    end
    
    always_comb begin
        AWREADY = 0;
        ARREADY = 0;
        RDATA = 0;
        RVALID = 0;
        RRESP = 0;
        memory_RREADY = 0;
        gpio_RREADY = 0;
        memory_WDATA = 0;
        memory_WSTRB = 0;
        memory_WVALID = 0;
        gpio_WDATA = 0;
        gpio_WSTRB = 0;
        gpio_WVALID = 0;
        WREADY = 0;
        BRESP = 0;
        BVALID = 0;
        memory_BREADY = 0;
        gpio_BREADY = 0;
    
        // sends READY address back to master
    
        if (memory_read_select) begin
            ARREADY = memory_ARREADY;
        end    
        if (memory_write_select) begin
            AWREADY = memory_AWREADY;
        end
        if (gpio_read_select) begin
            ARREADY = gpio_ARREADY;     
        end
        if (gpio_write_select) begin
            AWREADY = gpio_AWREADY;
        end
        
        // read data
        
        if (read_owner == READ_MEMORY) begin
            // slave sends data
            RDATA = memory_RDATA;
            RVALID = memory_RVALID;
            RRESP = memory_RRESP;   
            // master validates data
            memory_RREADY = RREADY;         
        end
        
        if (read_owner == READ_GPIO) begin
            RDATA = gpio_RDATA;
            RVALID = gpio_RVALID;
            RRESP = gpio_RRESP;
            gpio_RREADY = RREADY;
        end         
        
        // write data + validation 
        
        if (write_owner == WRITE_MEMORY) begin
            memory_WDATA = WDATA;
            memory_WSTRB = WSTRB;
            memory_WVALID = WVALID;
            WREADY = memory_WREADY;
            BRESP = memory_BRESP;
            BVALID = memory_BVALID;
            memory_BREADY = BREADY;
        end        
        
        if (write_owner == WRITE_GPIO) begin
            gpio_WDATA = WDATA;
            gpio_WSTRB = WSTRB;
            gpio_WVALID = WVALID;
            WREADY = gpio_WREADY;         
            BRESP = gpio_BRESP;
            BVALID = gpio_BVALID;
            gpio_BREADY = BREADY;               
        end
        
    end
    
    // Keeps track of owner (owner = peripheral responsible for sending data to master)
    
    always_ff @(posedge clk) begin
        if (reset) begin
            read_owner <= READ_NONE;
        end
        
        else if (RVALID && RREADY) begin // transfer of read data is done
            read_owner <= READ_NONE;
        end
        
        else if (memory_read_select && ARVALID && ARREADY) begin
            read_owner <= READ_MEMORY;    
        end    
        
        else if (gpio_read_select && ARVALID && ARREADY) begin
            read_owner <= READ_GPIO;
        end
    end
    
        always_ff @(posedge clk) begin
        if (reset) begin
            write_owner <= WRITE_NONE;
        end
        
        else if (BVALID && BREADY) begin
            write_owner <= WRITE_NONE;
        end

        else if (memory_write_select && AWVALID && AWREADY) begin
            write_owner <= WRITE_MEMORY;
        end
        
        else if (gpio_write_select && AWVALID && AWREADY) begin
            write_owner <= WRITE_GPIO;
        end
    end
    
endmodule
