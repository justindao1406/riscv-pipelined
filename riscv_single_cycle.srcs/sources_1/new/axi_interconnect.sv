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
    input logic uart_ARREADY,
    input logic uart_AWREADY,
    input logic [31:0] uart_RDATA,
    input logic uart_RVALID,
    input logic [1:0] uart_RRESP,
    input logic uart_WREADY,
    input logic [1:0] uart_BRESP,
    input logic uart_BVALID,
    input logic timer_ARREADY,
    input logic timer_AWREADY,
    input logic [31:0] timer_RDATA,
    input logic timer_RVALID,
    input logic [1:0] timer_RRESP,
    input logic timer_WREADY,
    input logic [1:0] timer_BRESP,
    input logic timer_BVALID,
    input logic fir_ARREADY,
    input logic fir_AWREADY,
    input logic [31:0] fir_RDATA,
    input logic fir_RVALID,
    input logic [1:0] fir_RRESP,
    input logic fir_WREADY,
    input logic [1:0] fir_BRESP,
    input logic fir_BVALID,
    
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
    output logic [31:0] uart_ARADDR,
    output logic [31:0] uart_AWADDR,
    output logic [31:0] timer_ARADDR,
    output logic [31:0] timer_AWADDR,    
    output logic [31:0] fir_ARADDR,
    output logic [31:0] fir_AWADDR,      
    output logic memory_ARVALID,
    output logic memory_AWVALID,
    output logic memory_RREADY,
    output logic gpio_ARVALID,
    output logic gpio_AWVALID,
    output logic gpio_RREADY,
    output logic uart_ARVALID,
    output logic uart_AWVALID,
    output logic uart_RREADY,
    output logic timer_ARVALID,
    output logic timer_AWVALID,
    output logic timer_RREADY,    
    output logic fir_ARVALID,
    output logic fir_AWVALID,
    output logic fir_RREADY,      
    output logic [31:0] memory_WDATA,
    output logic [3:0] memory_WSTRB,
    output logic memory_WVALID,
    output logic memory_BREADY,
    output logic [31:0] gpio_WDATA,
    output logic [3:0] gpio_WSTRB,
    output logic gpio_WVALID,
    output logic gpio_BREADY,
    output logic [31:0] uart_WDATA,
    output logic [3:0] uart_WSTRB,
    output logic uart_WVALID,
    output logic uart_BREADY,
    output logic [31:0] timer_WDATA,
    output logic [3:0] timer_WSTRB,
    output logic timer_WVALID,
    output logic timer_BREADY,    
    output logic [31:0] fir_WDATA,
    output logic [3:0] fir_WSTRB,
    output logic fir_WVALID,
    output logic fir_BREADY       
    );
    
    // select flags
    
    logic memory_read_select;
    logic gpio_read_select;
    logic uart_read_select;
    logic timer_read_select;
    logic fir_read_select;
    
    logic memory_write_select;
    logic gpio_write_select;
    logic uart_write_select;
    logic timer_write_select;
    logic fir_write_select;
    
    // read transaction tracker
    
    typedef enum logic [2:0] {
        READ_NONE,
        READ_MEMORY,
        READ_GPIO,
        READ_UART,
        READ_TIMER,
        READ_FIR
    } read_owner_t;
    
    read_owner_t read_owner;
    
    // write transaction tracker
    
    typedef enum logic [2:0] {
        WRITE_NONE,
        WRITE_MEMORY,
        WRITE_GPIO,
        WRITE_UART,
        WRITE_TIMER,
        WRITE_FIR
    } write_owner_t;
    
    write_owner_t write_owner;
    
    // pick the peripheral + provide VALID to slave
    
    always_comb begin
        memory_read_select = 0;
        gpio_read_select = 0;
        uart_read_select = 0;
        timer_read_select = 0;
        fir_read_select = 0;
        memory_write_select = 0;
        gpio_write_select = 0;
        uart_write_select = 0;
        timer_write_select = 0;
        fir_write_select = 0;
        memory_ARVALID = 0;
        gpio_ARVALID = 0;
        uart_ARVALID = 0;
        timer_ARVALID = 0;
        fir_ARVALID = 0;
        memory_AWVALID = 0;
        gpio_AWVALID = 0;    
        uart_AWVALID = 0;
        timer_AWVALID = 0;
        fir_AWVALID = 0;
        memory_ARADDR = 32'd0;
        memory_AWADDR = 32'd0;
        gpio_ARADDR = 32'd0;
        gpio_AWADDR = 32'd0;   
        uart_ARADDR = 32'd0;
        uart_AWADDR = 32'd0;     
        timer_ARADDR = 32'd0;
        timer_AWADDR = 32'd0;
        fir_ARADDR = 32'd0;
        fir_AWADDR = 32'd0;                             
    
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
        
        if (ARADDR[31:12] == 20'h10001) begin
            uart_read_select = 1;
            uart_ARADDR   = ARADDR;
            uart_ARVALID = ARVALID;
        end   
        
        if (AWADDR[31:12] == 20'h10001) begin
            uart_write_select = 1;
            uart_AWADDR   = AWADDR;
            uart_AWVALID = AWVALID;
        end
        
        if (ARADDR[31:12] == 20'h10002) begin
            timer_read_select = 1;
            timer_ARADDR   = ARADDR;
            timer_ARVALID = ARVALID;
        end   
        
        if (AWADDR[31:12] == 20'h10002) begin
            timer_write_select = 1;
            timer_AWADDR   = AWADDR;
            timer_AWVALID = AWVALID;
        end        
        
        if (ARADDR[31:12] == 20'h10003) begin
            fir_read_select = 1;
            fir_ARADDR   = ARADDR;
            fir_ARVALID = ARVALID;
        end   
        
        if (AWADDR[31:12] == 20'h10003) begin
            fir_write_select = 1;
            fir_AWADDR   = AWADDR;
            fir_AWVALID = AWVALID;
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
        uart_RREADY = 0;
        timer_RREADY = 0;
        fir_RREADY = 0;
        memory_WDATA = 0;
        memory_WSTRB = 0;
        memory_WVALID = 0;
        gpio_WDATA = 0;
        gpio_WSTRB = 0;
        gpio_WVALID = 0;
        uart_WDATA = 0;
        uart_WSTRB = 0;
        uart_WVALID = 0;
        timer_WDATA = 0;
        timer_WSTRB = 0;
        timer_WVALID = 0;        
        fir_WDATA = 0;
        fir_WSTRB = 0;
        fir_WVALID = 0;          
        WREADY = 0;
        BRESP = 0;
        BVALID = 0;
        memory_BREADY = 0;
        gpio_BREADY = 0;
        uart_BREADY = 0;
        timer_BREADY = 0;
        fir_BREADY = 0;        
    
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
        if (uart_read_select) begin
            ARREADY = uart_ARREADY;     
        end
        if (uart_write_select) begin
            AWREADY = uart_AWREADY;
        end
        if (timer_read_select) begin
            ARREADY = timer_ARREADY;     
        end
        if (timer_write_select) begin
            AWREADY = timer_AWREADY;
        end  
        if (fir_read_select) begin
            ARREADY = fir_ARREADY;     
        end
        if (fir_write_select) begin
            AWREADY = fir_AWREADY;
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
        
        if (read_owner == READ_UART) begin
            RDATA = uart_RDATA;
            RVALID = uart_RVALID;
            RRESP = uart_RRESP;
            uart_RREADY = RREADY;
        end        
        
        if (read_owner == READ_TIMER) begin
            RDATA = timer_RDATA;
            RVALID = timer_RVALID;
            RRESP = timer_RRESP;
            timer_RREADY = RREADY;
        end      
        
        if (read_owner == READ_FIR) begin
            RDATA = fir_RDATA;
            RVALID = fir_RVALID;
            RRESP = fir_RRESP;
            fir_RREADY = RREADY;
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
        
        if (write_owner == WRITE_UART) begin
            uart_WDATA = WDATA;
            uart_WSTRB = WSTRB;
            uart_WVALID = WVALID;
            WREADY = uart_WREADY;         
            BRESP = uart_BRESP;
            BVALID = uart_BVALID;
            uart_BREADY = BREADY;               
        end
        
        if (write_owner == WRITE_TIMER) begin
            timer_WDATA = WDATA;
            timer_WSTRB = WSTRB;
            timer_WVALID = WVALID;
            WREADY = timer_WREADY;         
            BRESP = timer_BRESP;
            BVALID = timer_BVALID;
            timer_BREADY = BREADY;               
        end    
        
        if (write_owner == WRITE_FIR) begin
            fir_WDATA = WDATA;
            fir_WSTRB = WSTRB;
            fir_WVALID = WVALID;
            WREADY = fir_WREADY;         
            BRESP = fir_BRESP;
            BVALID = fir_BVALID;
            fir_BREADY = BREADY;               
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
        
        else if (uart_read_select && ARVALID && ARREADY) begin
            read_owner <= READ_UART;
        end
        
        else if (timer_read_select && ARVALID && ARREADY) begin
            read_owner <= READ_TIMER;
        end 
        
        else if (fir_read_select && ARVALID && ARREADY) begin
            read_owner <= READ_FIR;
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
        
        else if (uart_write_select && AWVALID && AWREADY) begin
            write_owner <= WRITE_UART;
        end
        
        else if (timer_write_select && AWVALID && AWREADY) begin
            write_owner <= WRITE_TIMER;
        end
        
        else if (fir_write_select && AWVALID && AWREADY) begin
            write_owner <= WRITE_FIR;
        end        
    end
    
endmodule
