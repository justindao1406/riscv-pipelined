`timescale 1ns / 1ps

module main_decoder(
    input logic [6:0] opcode,
    output logic reg_write,
    output logic mem_write,
    output logic [1:0] alu_src_a,
    output logic alu_src_b,
    output logic [1:0] result_src,
    output logic [2:0] imm_sel,
    output logic branch,
    output logic [1:0] jump,
    output logic [1:0] alu_op
    );
    
    // OPCODE values
    
    localparam [6:0]
    R_TYPE_ALU = 7'b0110011,
    I_TYPE_ALU = 7'b0010011,
    LOAD = 7'b0000011,
    STORE = 7'b0100011,
    BRANCH = 7'b1100011,
    JAL = 7'b1101111,
    JALR = 7'b1100111,
    LUI = 7'b0110111,
    AUIPC = 7'b0010111;
    
    // alu_src_a : selects alu op1
    
    localparam [1:0]
    rs1_data = 2'b00,
    current_pc = 2'b01,
    const_zero = 2'b10;
    
    // alu_src_b : selects alu op2
    
    localparam [0:0]
    rs2_data = 1'b0,
    gen_imm = 1'b1;
    
    // result_src : selects what's written in rd
    
    localparam [1:0]
    alu_result = 2'b00,
    data_mem = 2'b01,
    pc_incr = 2'b10; // increment by 4
    
    // imm_sel : immediate format
    
    localparam [2:0]
    i_type = 3'd0,
    s_type = 3'd1,
    b_type = 3'd2,
    u_type = 3'd3,
    j_type = 3'd4;
    
    // jump : type of jump
    
    localparam [1:0]
    no_jump = 2'b00,
    jal = 2'b01,
    jalr = 2'b10;
    
    // alu_op : tells alu decoder the exact operation
    
    localparam [1:0]
    force_add = 2'b00, // tells ALU to only add
    compare_branch = 2'b01,
    decode_f3_f7 = 2'b10;
    
    always_comb begin
        reg_write = 0;
        mem_write = 0;
        alu_src_a = rs1_data;
        alu_src_b = rs2_data;
        result_src = alu_result;
        imm_sel = i_type;
        branch = 0;
        jump = no_jump;
        alu_op = force_add;
    
        case (opcode)
        
            R_TYPE_ALU: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = rs1_data;
                alu_src_b = rs2_data;
                result_src = alu_result;
                imm_sel = i_type; // ignore
                branch = 0;
                jump = no_jump;
                alu_op = decode_f3_f7;
            end
            
            I_TYPE_ALU: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = rs1_data;
                alu_src_b = gen_imm;
                result_src = alu_result;
                imm_sel = i_type; 
                branch = 0;
                jump = no_jump;
                alu_op = decode_f3_f7;
            end
            
            LOAD: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = rs1_data;
                alu_src_b = gen_imm;
                result_src = data_mem;
                imm_sel = i_type;
                branch = 0;
                jump = no_jump;
                alu_op = force_add;
            end
            
            STORE: begin
                reg_write = 0;
                mem_write = 1;
                alu_src_a = rs1_data;
                alu_src_b = gen_imm;
                result_src = alu_result; // ignore
                imm_sel = s_type;
                branch = 0;
                jump = no_jump;
                alu_op = force_add;
            end
            
            BRANCH: begin
                reg_write = 0;
                mem_write = 0;
                alu_src_a = rs1_data;
                alu_src_b = rs2_data;
                result_src = alu_result; // ignore
                imm_sel = b_type;
                branch = 1;
                jump = no_jump;
                alu_op = compare_branch;
            end
            
            JAL: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = rs1_data; // ignore
                alu_src_b = rs2_data; // ignore
                result_src = pc_incr; 
                imm_sel = j_type;
                branch = 0;
                jump = jal;
                alu_op = force_add; // ignore 
            end
            
            JALR: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = rs1_data; 
                alu_src_b = gen_imm; 
                result_src = pc_incr; 
                imm_sel = i_type;
                branch = 0;
                jump = jalr;
                alu_op = force_add; 
            end
            
            LUI: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = const_zero; 
                alu_src_b = gen_imm; 
                result_src = alu_result; 
                imm_sel = u_type;
                branch = 0;
                jump = no_jump;
                alu_op = force_add; 
            end
            
            AUIPC: begin
                reg_write = 1;
                mem_write = 0;
                alu_src_a = current_pc; 
                alu_src_b = gen_imm; 
                result_src = alu_result; 
                imm_sel = u_type;
                branch = 0;
                jump = no_jump;
                alu_op = force_add; 
            end
            
            default: begin 
                reg_write = 0;
                mem_write = 0;
                alu_src_a = rs1_data;
                alu_src_b = rs2_data;
                result_src = alu_result;
                imm_sel = i_type;
                branch = 0;
                jump = no_jump;
                alu_op = force_add;
                    end
        endcase
    end
    
endmodule
