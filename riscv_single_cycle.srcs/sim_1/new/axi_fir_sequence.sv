`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_fir_sequence extends uvm_sequence #(axi_fir_item);
    
    `uvm_object_utils(axi_fir_sequence)
    
    function new(input string name = "axi_fir_sequence");
        super.new(name);
    endfunction
    
    virtual task body();
    
        axi_fir_item request;
        request = axi_fir_item::type_id::create("request");
        
        start_item(request); // waits for sequencer permission to send item
        
        if (!request.randomize()) begin
            `uvm_fatal("RANDOMIZE_FAILED", "axi_fir_item randomization failed")
        end
        
        finish_item(request); // sends item to driver and waits for completion
            
    endtask

endclass
