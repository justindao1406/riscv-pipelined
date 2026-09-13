`timescale 1ns / 1ps

interface axi_fir_if(input logic clk);

    logic reset;
    
    logic [31:0] ARADDR;
    logic ARVALID;
    logic RREADY;
    logic [31:0] AWADDR;
    logic AWVALID;
    logic [31:0] WDATA;
    logic [3:0] WSTRB;
    logic WVALID;
    logic BREADY;
    
    logic ARREADY;
    logic [31:0] RDATA;
    logic [1:0] RRESP;
    logic RVALID;
    logic AWREADY;
    logic WREADY;
    logic BVALID;
    logic [1:0] BRESP;
    
    clocking driver_cb @(posedge clk); // acts as the master
        default input #1step output #0;
        
        input reset;
        
        input ARREADY;
        input RDATA;
        input RRESP;
        input RVALID;
        input AWREADY;
        input WREADY;
        input BVALID;
        input BRESP;
    
        output ARADDR;
        output ARVALID;
        output RREADY;
        output AWADDR;
        output AWVALID;
        output WDATA;
        output WSTRB;
        output WVALID;
        output BREADY;    
        
    endclocking
    
    clocking monitor_cb @(posedge clk); // observes every AXI signal
    
        default input #1step;
        
        input reset;
        
        input ARREADY;
        input RDATA;
        input RRESP;
        input RVALID;
        input AWREADY;
        input WREADY;
        input BVALID;
        input BRESP;
    
        input ARADDR;
        input ARVALID;
        input RREADY;
        input AWADDR;
        input AWVALID;
        input WDATA;
        input WSTRB;
        input WVALID;
        input BREADY;        
    
    endclocking

endinterface
