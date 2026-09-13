`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_fir_driver extends uvm_driver #(axi_fir_item);
    
    `uvm_component_utils(axi_fir_driver)
    
    virtual axi_fir_if vif;
    
    function new(
        input string name = "axi_fir_driver",
        input uvm_component parent = null 
    );
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase); // gets axi if connection before transaction begins
        super.build_phase(phase);
        
        // stores axi_fir_if handle in vif -> allows connection between driver and if
        if (!uvm_config_db #(virtual axi_fir_if)::get(
            this,
            "",
            "vif",
            vif
        )) begin
            `uvm_fatal("NO_VIF", "axi_fir_if was not provided to the driver")
        end
    endfunction
    
    task run_phase(uvm_phase phase); // perform transactions over simulation time
        axi_fir_item request;
        
        forever begin
            seq_item_port.get_next_item(request); // get avaiable request from sequencer. store its handle in request
            
            if(request.is_write)
                drive_write(request);
            else
                drive_read(request);
                
            seq_item_port.item_done(); 
        end
    endtask
    
    task drive_write(axi_fir_item request);
    
        vif.driver_cb.AWADDR <= request.address;
        vif.driver_cb.AWVALID <= 1;
        
        do begin
            @(vif.driver_cb);
        end while (!vif.driver_cb.AWREADY);    
        
        vif.driver_cb.AWVALID <= 0;
        vif.driver_cb.WDATA <= request.write_data;
        vif.driver_cb.WSTRB <= request.write_strobe;
        vif.driver_cb.WVALID <= 1;
        
        do begin
            @(vif.driver_cb);
        end while (!vif.driver_cb.WREADY);
        
        vif.driver_cb.WVALID <= 0;
        vif.driver_cb.BREADY <= 1;
        
        do begin
            @(vif.driver_cb);
        end while (!vif.driver_cb.BVALID);
        
        request.response = vif.driver_cb.BRESP; // bookkeeping
        vif.driver_cb.BREADY <= 0;
    endtask

endclass
