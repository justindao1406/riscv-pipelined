`timescale 1ns / 1ps

module immediate_generator(
    input logic [31:0] instr, 
    input logic [2:0] format_sel, 
    output logic [31:0] immediate
    );
    
    localparam [2:0]
    i_type = 3'd0,
    s_type = 3'd1,
    b_type = 3'd2,
    u_type = 3'd3,
    j_type = 3'd4;
    
    always_comb begin
        case (format_sel)
            i_type: immediate = $signed(instr[31:20]) ;
            s_type: immediate = $signed({instr[31:25], instr[11:7]}) ;
            b_type: immediate = {{20{$signed(instr[31])}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            u_type: immediate = {instr[31:12], 12'b0};
            j_type: immediate = {{12{$signed(instr[31])}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: immediate = 32'd0;
        endcase
    end
    
endmodule
