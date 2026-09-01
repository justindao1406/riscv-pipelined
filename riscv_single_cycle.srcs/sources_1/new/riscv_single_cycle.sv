`timescale 1ns / 1ps

module riscv_single_cycle(
    input logic clk,
    input logic reset,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_write_data
    );
    
    // pc -> instruction memory 
    
    logic [31:0] next_pc;
    logic [31:0] current_pc;
    logic [31:0] instruction;
    
    logic [31:0] pc_plus_4;
    
    assign pc_plus_4 = current_pc + 32'd4;
    
    pc pc_inst ( .clk(clk), .reset(reset), .next_pc(next_pc), .current_pc(current_pc) );
    
    instruction_memory im_inst ( .current_pc(current_pc), .instruction(instruction) );
    
    // instruction memory -> main decoder
    
    logic [6:0] opcode;
    logic reg_write;
    logic mem_write;
    logic [1:0] alu_src_a;
    logic alu_src_b;
    logic [1:0] result_src;
    logic [2:0] imm_sel;
    logic branch;
    logic [1:0] jump;
    logic [1:0] alu_op;
    
    assign opcode = instruction[6:0];
    
    main_decoder md_inst 
    ( .opcode(opcode), .reg_write(reg_write), .mem_write(mem_write),
    .alu_src_a(alu_src_a), .alu_src_b(alu_src_b), .result_src(result_src),
    .imm_sel(imm_sel), .branch(branch), .jump(jump), .alu_op(alu_op) );
    
    // main decoder (alu_op) + instruction (the rest) -> alu decoder
    
    logic [2:0] funct3;
    logic funct7_bit5;
    logic opcode_bit5; // distinguises R type and I type
    logic [3:0] alu_ctrl;
    
    assign funct3 = instruction[14:12];
    assign funct7_bit5 = instruction[30];
    assign opcode_bit5 = instruction[5];
    
    alu_decoder ad_inst
    ( .alu_op(alu_op), .funct3(funct3), .funct7_bit5(funct7_bit5),
    .opcode_bit5(opcode_bit5), .alu_ctrl(alu_ctrl) );
    
    // main decoder -> register file
    
     logic [4:0] write_addr; // or rd's address
     logic [4:0] rs1_addr;
     logic [4:0] rs2_addr;
     logic [31:0] write_data; 
     logic [31:0] rs1_data;
     logic [31:0] rs2_data; 
     
     assign write_addr = instruction[11:7];
     assign rs1_addr = instruction[19:15];
     assign rs2_addr = instruction[24:20];
     
     register_file rf_inst
     ( .clk(clk), .write_enable(reg_write && !reset), .write_addr(write_addr), .rs1_addr(rs1_addr),
     .rs2_addr(rs2_addr), .write_data(write_data), .rs1_data(rs1_data), .rs2_data(rs2_data) );
     
     // main decoder -> immediate generator
     
     logic [31:0] immediate;
     
     immediate_generator ig_inst
     ( .instr(instruction), .format_sel(imm_sel), .immediate(immediate) );
     
     // register file + alu decoer -> alu
     
     logic [31:0] alu_res;
     
     logic [31:0] op1_input;
     logic [31:0] op2_input;
     
     always_comb begin
        case (alu_src_a)
            2'b00: op1_input = rs1_data;
            2'b01: op1_input = current_pc;
            2'b10: op1_input = 32'd0;
            default: op1_input = 32'd0;
        endcase
     end
     
     always_comb begin
        case (alu_src_b)
            1'b0: op2_input = rs2_data;
            1'b1: op2_input = immediate;
            default: op2_input = 32'd0;
        endcase
     end
     
     alu alu_inst
     ( .op1(op1_input), .op2(op2_input), .alu_ctrl(alu_ctrl), .alu_res(alu_res) );
     
     // rs2 data + alu res -> data memory
     
     logic [31:0] data_out;
     
     data_memory dm_inst
     ( .clk(clk), .write_enable(mem_write && !reset), .address(alu_res), 
     .data_in(rs2_data), .data_out(data_out) );
     
     // data memory + alu res + pc -> register write data
     
     always_comb begin
        case (result_src)
            2'b00: write_data = alu_res;
            2'b01: write_data = data_out;
            2'b10: write_data = pc_plus_4;
            default: write_data = 32'd0;
        endcase
     end
     
     // pc + branch + jal/jalr logic
     
     logic take_branch;
     logic [31:0] branch_target; // if comparison successful, address of appropriate label
     
     logic [31:0] jal_target;
     logic [31:0] jalr_target;
     
     localparam [1:0]
     no_jump = 2'b00,
     jal = 2'b01,
     jalr = 2'b10;
     
     localparam[2:0]
     BEQ = 3'b000,
     BNE = 3'b001,
     BLT = 3'b100,
     BGE = 3'b101,
     BLTU = 3'b110,
     BGEU = 3'b111;
     
     always_comb begin
     
        take_branch = 0;
        branch_target = current_pc + immediate;
        next_pc = pc_plus_4;
        
        jal_target = current_pc + immediate;
        jalr_target = (rs1_data + immediate) & 32'hFFFFFFFE;
     
        if (branch) begin
            case (funct3)
            
                BEQ: begin
                    if (rs1_data == rs2_data) begin
                        take_branch = 1;
                    end
                    else take_branch = 0;
                end
                
                BNE: begin
                    if (rs1_data != rs2_data) begin
                        take_branch = 1;
                    end
                    else take_branch = 0;
                end
                
                BLTU: begin
                    if (rs1_data < rs2_data) begin
                        take_branch = 1;
                    end
                    else take_branch = 0;
                end
                
                BGEU: begin
                    if (rs2_data <= rs1_data) begin
                        take_branch = 1;
                    end
                    else take_branch = 0;
                end
                
                BLT: begin
                    if ($signed(rs1_data) < $signed(rs2_data) ) begin
                        take_branch = 1;
                    end
                    else take_branch = 0;
                end
                
                BGE: begin
                    if ($signed(rs2_data) <= $signed(rs1_data) ) begin
                        take_branch = 1;
                    end
                    else take_branch = 0;
                end
                
                default: take_branch = 0;
            endcase
        end
        
        if (take_branch) begin
            next_pc = branch_target;
        end
        case (jump)
            no_jump: ;
            jal: next_pc = jal_target;
            jalr: next_pc = jalr_target;
            default: ;
        endcase
        
     end
     
     assign debug_pc = current_pc;
     assign debug_write_data = write_data;
     
endmodule
