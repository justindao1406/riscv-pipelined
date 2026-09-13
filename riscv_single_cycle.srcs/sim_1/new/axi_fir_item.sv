`timescale 1ns / 1ps

import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_fir_item extends uvm_sequence_item;

    // Request fields
    
    rand bit is_write; // 0 for read, 1 for write
    
    rand bit [31:0] address;
    rand bit [31:0] write_data;
    rand bit [3:0] write_strobe;
    
    // Response fields
    
    bit [31:0] read_data;
    bit [1:0] response; // RRESP or BRESP
    
    // constraint
    
    constraint address_c {
        if (is_write)
            soft address == 32'h1000_3000;
        else
            soft address inside {
                32'h1000_3004,
                32'h1000_3008
            };   
    }
    
    constraint write_strobe_c {
        if (is_write)
            soft write_strobe[1:0] == 2'b11;
    }

    `uvm_object_utils(axi_fir_item)
    
    function new(input string name = "axi_fir_item");
        super.new(name);
    endfunction

endclass
