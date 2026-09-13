`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_fir_sequencer extends uvm_sequencer #(axi_fir_item);

    `uvm_component_utils(axi_fir_sequencer) 
    
    function new(
        input string name = "axi_fir_sequencer",
        input uvm_component parent = null
    );
        super.new(name, parent);
    endfunction

endclass
