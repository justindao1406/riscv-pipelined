`timescale 1ns / 1ps

module riscv_system(
    input logic clk,
    input logic reset,
    input logic [3:0] gpio_in,
    input logic uart_rx_pin,
    output logic [3:0] gpio_out,
    output logic uart_tx_pin,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_write_data
    );
    
    logic completed_transaction;
    logic [31:0] load_data;
    logic [31:0] store_data;
    logic mem_request;
    logic mem_read_or_write;
    logic [31:0] mem_address;
    
    logic [31:0] ARADDR;
    logic ARVALID;
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic RREADY;
    
    logic [31:0] AWADDR;
    logic AWVALID;
    logic AWREADY;
    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;
    logic WREADY;
    logic [1:0] BRESP;
    logic BVALID;
    logic BREADY;
    
    riscv_pipelined cpu_inst 
    ( .clk(clk), .reset(reset), .completed_transaction(completed_transaction), .load_data_response(load_data), 
    .store_data_request(store_data), .mem_request(mem_request), .mem_read_or_write(mem_read_or_write),
    .mem_address(mem_address), .debug_pc(debug_pc), .debug_write_data(debug_write_data) );
    
    axi_lite_master axi_inst 
    ( .clk(clk), .reset(reset), .store_data(store_data), .mem_request(mem_request), .mem_read_or_write(mem_read_or_write), 
    .mem_address(mem_address), .ARREADY(ARREADY), .RDATA(RDATA), .RRESP(RRESP), .RVALID(RVALID), .AWREADY(AWREADY), 
    .WREADY(WREADY), .BRESP(BRESP), .BVALID(BVALID), .load_data(load_data), .completed_transaction(completed_transaction), 
    .ARADDR(ARADDR), .ARVALID(ARVALID), .RREADY(RREADY), .AWADDR(AWADDR), .AWVALID(AWVALID), .WDATA(WDATA), .WSTRB(WSTRB), 
    .WVALID(WVALID), .BREADY(BREADY) );
    
    // MEMORY AXI signals
    
    logic [31:0] memory_ARADDR;
    logic memory_ARVALID;
    logic memory_ARREADY;
    logic [31:0] memory_RDATA;
    logic [1:0] memory_RRESP;
    logic memory_RVALID;
    logic memory_RREADY;
    
    logic [31:0] memory_AWADDR;
    logic memory_AWVALID;
    logic memory_AWREADY;
    logic [31:0] memory_WDATA;
    logic [3:0] memory_WSTRB;
    logic memory_WVALID;
    logic memory_WREADY;
    logic [1:0] memory_BRESP;
    logic memory_BVALID;
    logic memory_BREADY;
    
    
    // GPIO AXI signals
    
    logic [31:0] gpio_ARADDR;
    logic gpio_ARVALID;
    logic gpio_ARREADY;
    logic [31:0] gpio_RDATA;
    logic [1:0] gpio_RRESP;
    logic gpio_RVALID;
    logic gpio_RREADY;
    
    logic [31:0] gpio_AWADDR;
    logic gpio_AWVALID;
    logic gpio_AWREADY;
    logic [31:0] gpio_WDATA;
    logic [3:0] gpio_WSTRB;
    logic gpio_WVALID;
    logic gpio_WREADY;
    logic [1:0] gpio_BRESP;
    logic gpio_BVALID;
    logic gpio_BREADY;
    
    
    // UART AXI signals
    
    logic [31:0] uart_ARADDR;
    logic uart_ARVALID;
    logic uart_ARREADY;
    logic [31:0] uart_RDATA;
    logic [1:0] uart_RRESP;
    logic uart_RVALID;
    logic uart_RREADY;
    
    logic [31:0] uart_AWADDR;
    logic uart_AWVALID;
    logic uart_AWREADY;
    logic [31:0] uart_WDATA;
    logic [3:0] uart_WSTRB;
    logic uart_WVALID;
    logic uart_WREADY;
    logic [1:0] uart_BRESP;
    logic uart_BVALID;
    logic uart_BREADY;
    
    
    // TIMER AXI signals
    
    logic [31:0] timer_ARADDR;
    logic timer_ARVALID;
    logic timer_ARREADY;
    logic [31:0] timer_RDATA;
    logic [1:0] timer_RRESP;
    logic timer_RVALID;
    logic timer_RREADY;
    
    logic [31:0] timer_AWADDR;
    logic timer_AWVALID;
    logic timer_AWREADY;
    logic [31:0] timer_WDATA;
    logic [3:0] timer_WSTRB;
    logic timer_WVALID;
    logic timer_WREADY;
    logic [1:0] timer_BRESP;
    logic timer_BVALID;
    logic timer_BREADY;
    
    // AXI INTERCONNECT
    
    axi_interconnect axi_ic_inst
    ( .clk(clk), .reset(reset), .ARADDR(ARADDR), .ARVALID(ARVALID),
    .RREADY(RREADY), .AWADDR(AWADDR), .AWVALID(AWVALID), .WDATA(WDATA),
    .WSTRB(WSTRB), .WVALID(WVALID), .BREADY(BREADY), .memory_ARREADY(memory_ARREADY),
    .memory_AWREADY(memory_AWREADY), .memory_RDATA(memory_RDATA), .memory_RVALID(memory_RVALID),
    .memory_RRESP(memory_RRESP), .memory_WREADY(memory_WREADY), .memory_BRESP(memory_BRESP),
    .memory_BVALID(memory_BVALID), .gpio_ARREADY(gpio_ARREADY), .gpio_AWREADY(gpio_AWREADY),
    .gpio_RDATA(gpio_RDATA), .gpio_RVALID(gpio_RVALID), .gpio_RRESP(gpio_RRESP),
    .gpio_WREADY(gpio_WREADY), .gpio_BRESP(gpio_BRESP), .gpio_BVALID(gpio_BVALID),
    .uart_ARREADY(uart_ARREADY), .uart_AWREADY(uart_AWREADY), .uart_RDATA(uart_RDATA),
    .uart_RVALID(uart_RVALID), .uart_RRESP(uart_RRESP), .uart_WREADY(uart_WREADY),
    .uart_BRESP(uart_BRESP), .uart_BVALID(uart_BVALID), .timer_ARREADY(timer_ARREADY),
    .timer_AWREADY(timer_AWREADY), .timer_RDATA(timer_RDATA), .timer_RVALID(timer_RVALID),
    .timer_RRESP(timer_RRESP), .timer_WREADY(timer_WREADY), .timer_BRESP(timer_BRESP),
    .timer_BVALID(timer_BVALID), .ARREADY(ARREADY), .RDATA(RDATA),
    .RRESP(RRESP), .RVALID(RVALID), .AWREADY(AWREADY),
    .WREADY(WREADY), .BRESP(BRESP), .BVALID(BVALID),
    .memory_ARADDR(memory_ARADDR), .memory_AWADDR(memory_AWADDR), .gpio_ARADDR(gpio_ARADDR),
    .gpio_AWADDR(gpio_AWADDR), .uart_ARADDR(uart_ARADDR), .uart_AWADDR(uart_AWADDR),
    .timer_ARADDR(timer_ARADDR), .timer_AWADDR(timer_AWADDR), .memory_ARVALID(memory_ARVALID),
    .memory_AWVALID(memory_AWVALID), .memory_RREADY(memory_RREADY), .gpio_ARVALID(gpio_ARVALID),
    .gpio_AWVALID(gpio_AWVALID), .gpio_RREADY(gpio_RREADY), .uart_ARVALID(uart_ARVALID),
    .uart_AWVALID(uart_AWVALID), .uart_RREADY(uart_RREADY), .timer_ARVALID(timer_ARVALID),
    .timer_AWVALID(timer_AWVALID), .timer_RREADY(timer_RREADY), .memory_WDATA(memory_WDATA),
    .memory_WSTRB(memory_WSTRB), .memory_WVALID(memory_WVALID), .memory_BREADY(memory_BREADY),
    .gpio_WDATA(gpio_WDATA), .gpio_WSTRB(gpio_WSTRB), .gpio_WVALID(gpio_WVALID),
    .gpio_BREADY(gpio_BREADY), .uart_WDATA(uart_WDATA), .uart_WSTRB(uart_WSTRB),
    .uart_WVALID(uart_WVALID), .uart_BREADY(uart_BREADY), .timer_WDATA(timer_WDATA),
    .timer_WSTRB(timer_WSTRB), .timer_WVALID(timer_WVALID), .timer_BREADY(timer_BREADY) );
    
    // AXI BRAM
    
    axi_bram axi_bram_inst
    ( .clk(clk), .reset(reset), .ARADDR(memory_ARADDR), .ARVALID(memory_ARVALID),
    .RREADY(memory_RREADY), .AWADDR(memory_AWADDR), .AWVALID(memory_AWVALID),
    .WDATA(memory_WDATA), .WSTRB(memory_WSTRB), .WVALID(memory_WVALID),
    .BREADY(memory_BREADY), .ARREADY(memory_ARREADY), .RDATA(memory_RDATA),
    .RRESP(memory_RRESP), .RVALID(memory_RVALID), .AWREADY(memory_AWREADY),
    .WREADY(memory_WREADY), .BVALID(memory_BVALID), .BRESP(memory_BRESP) );
    
    // AXI GPIO
    
    axi_gpio axi_gpio_inst
    ( .clk(clk), .reset(reset), .ARADDR(gpio_ARADDR), .ARVALID(gpio_ARVALID),
    .RREADY(gpio_RREADY), .AWADDR(gpio_AWADDR), .AWVALID(gpio_AWVALID),
    .WDATA(gpio_WDATA), .WSTRB(gpio_WSTRB), .WVALID(gpio_WVALID),
    .BREADY(gpio_BREADY), .gpio_in(gpio_in), .ARREADY(gpio_ARREADY),
    .RDATA(gpio_RDATA), .RRESP(gpio_RRESP), .RVALID(gpio_RVALID),
    .AWREADY(gpio_AWREADY), .WREADY(gpio_WREADY), .BVALID(gpio_BVALID),
    .BRESP(gpio_BRESP), .gpio_out(gpio_out) );
    
    // AXI UART
    
    axi_uart axi_uart_inst
    ( .clk(clk), .reset(reset), .ARADDR(uart_ARADDR), .ARVALID(uart_ARVALID),
    .RREADY(uart_RREADY), .AWADDR(uart_AWADDR), .AWVALID(uart_AWVALID),
    .WDATA(uart_WDATA), .WSTRB(uart_WSTRB), .WVALID(uart_WVALID),
    .BREADY(uart_BREADY), .uart_rx_pin(uart_rx_pin), .ARREADY(uart_ARREADY),
    .RDATA(uart_RDATA), .RRESP(uart_RRESP), .RVALID(uart_RVALID),
    .AWREADY(uart_AWREADY), .WREADY(uart_WREADY), .BVALID(uart_BVALID),
    .BRESP(uart_BRESP), .uart_tx_pin(uart_tx_pin) );
    
    // AXI TIMER
    
    axi_timer axi_timer_inst
    ( .clk(clk), .reset(reset), .ARADDR(timer_ARADDR), .ARVALID(timer_ARVALID),
    .RREADY(timer_RREADY), .AWADDR(timer_AWADDR), .AWVALID(timer_AWVALID),
    .WDATA(timer_WDATA), .WSTRB(timer_WSTRB), .WVALID(timer_WVALID),
    .BREADY(timer_BREADY), .ARREADY(timer_ARREADY), .RDATA(timer_RDATA),
    .RRESP(timer_RRESP), .RVALID(timer_RVALID), .AWREADY(timer_AWREADY),
    .WREADY(timer_WREADY), .BVALID(timer_BVALID), .BRESP(timer_BRESP) );
    
endmodule
