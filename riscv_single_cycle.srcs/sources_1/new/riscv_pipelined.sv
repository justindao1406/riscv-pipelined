`timescale 1ns / 1ps

module riscv_pipelined(
    input logic clk,
    input logic reset,
    input logic completed_transaction, 
    input logic [31:0] load_data_response,
    output logic [31:0] store_data_request,
    output logic mem_request,
    output logic mem_read_or_write, // 0 -> read, 1 -> write
    output logic [31:0] mem_address,
    output logic [31:0] debug_pc,
    output logic [31:0] debug_write_data
    );
    
    logic is_load_stall;
    logic is_flush;
    
    logic is_memory_stall; // stalls CPU while memory transaction is still happening
    
    // ---------------------------------------- FETCH ----------------------------------------
    
    // ~~~~~ pc -> instruction memory ~~~~~
    
    logic [31:0] next_pcF;
    logic [31:0] pcF;
    logic [31:0] instructionF;
    logic [31:0] pc_plus_4F;
    
    assign pc_plus_4F = pcF + 32'd4;
    
    pc pc_inst 
    ( .clk(clk), .reset(reset), .next_pc(next_pcF), .is_load_stall(is_load_stall), .is_memory_stall(is_memory_stall), .current_pc(pcF) );
    
    instruction_memory im_inst ( .current_pc(pcF), .instruction(instructionF) );
    
    
    // ---------------------------------------- DECODE ----------------------------------------  
    
    
    // ~~~~~ instruction memory -> main decoder ~~~~~
    
    logic [31:0] pcD;
    logic [31:0] instructionD;
    logic [31:0] pc_plus_4D;
    
    always_ff @(posedge clk) begin
        if (reset) begin
            pcD <= 32'd0;
            instructionD <= 32'd0;
            pc_plus_4D <= 32'd0;
        end
        else if (is_memory_stall) begin
            pcD <= pcD;
            instructionD <= instructionD;
            pc_plus_4D <= pc_plus_4D;               
        end
        else if (is_flush) begin
            pcD <= 32'd0;
            instructionD <= 32'd0;
            pc_plus_4D <= 32'd0;
        end
        else if (is_load_stall) begin
            pcD <= pcD;
            instructionD <= instructionD;
            pc_plus_4D <= pc_plus_4D;    
        end
        else begin
            pcD <= pcF;
            instructionD <= instructionF;
            pc_plus_4D <= pc_plus_4F;
        end 
    end
    
    logic [6:0] opcodeD;
    logic reg_writeD;
    logic mem_writeD;
    logic mem_readD;
    logic [1:0] alu_src_aD;
    logic alu_src_bD;
    logic [1:0] result_srcD;
    logic [2:0] imm_selD;
    logic branchD;
    logic [1:0] jumpD;
    logic [1:0] alu_opD;
    
    assign opcodeD = instructionD[6:0];
    
    main_decoder md_inst 
    ( .opcode(opcodeD), .reg_write(reg_writeD), .mem_write(mem_writeD), .mem_read(mem_readD),
    .alu_src_a(alu_src_aD), .alu_src_b(alu_src_bD), .result_src(result_srcD),
    .imm_sel(imm_selD), .branch(branchD), .jump(jumpD), .alu_op(alu_opD) );
    
    // ~~~~~ main decoder (alu_op) + instruction (the rest) -> alu decoder ~~~~~
    
    logic [2:0] funct3D;
    logic funct7_bit5D;
    logic opcode_bit5D; // distinguises R type and I type
    logic [3:0] alu_ctrlD;
    
    assign funct3D = instructionD[14:12];
    assign funct7_bit5D = instructionD[30];
    assign opcode_bit5D = instructionD[5];
    
    alu_decoder ad_inst
    ( .alu_op(alu_opD), .funct3(funct3D), .funct7_bit5(funct7_bit5D),
    .opcode_bit5(opcode_bit5D), .alu_ctrl(alu_ctrlD) );
    
    // ~~~~~ main decoder -> register file ~~~~~
    
     logic [4:0] rd_addrD; // or rd's address
     logic [4:0] rs1_addrD;
     logic [4:0] rs2_addrD;
     logic [31:0] write_dataW; 
     logic [31:0] rs1_dataD;
     logic [31:0] rs2_dataD; 
     
     assign rd_addrD = instructionD[11:7];
     assign rs1_addrD = instructionD[19:15];
     assign rs2_addrD = instructionD[24:20];
     
     logic [4:0] rd_addrW; // Came from write back
     logic reg_writeW; // Came from write back
     
     register_file rf_inst
     ( .clk(clk), .write_enable(reg_writeW && !reset && !is_memory_stall), .write_addr(rd_addrW), .write_data(write_dataW), 
     .rs1_addr(rs1_addrD), .rs2_addr(rs2_addrD), .rs1_data(rs1_dataD), .rs2_data(rs2_dataD) );
     
     // ~~~~~ main decoder -> immediate generator ~~~~~
     
     logic [31:0] immediateD;
     
     immediate_generator ig_inst
     ( .instr(instructionD), .format_sel(imm_selD), .immediate(immediateD) );
     
     
     // ---------------------------------------- EXECUTE ----------------------------------------
     
     
     // Used in execute (and/or later stages too)
     
     logic [31:0] pcE;
     logic [31:0] pc_plus_4E;
     logic [31:0] rs1_dataE;
     logic [31:0] rs2_dataE; 
     logic [31:0] immediateE;
     logic [3:0] alu_ctrlE;    
     logic [1:0] alu_src_aE;
     logic alu_src_bE;
     logic branchE; 
     logic [1:0] jumpE;
     logic [2:0] funct3E;
       
     // Used for memory 
     
     logic mem_writeE;
     logic mem_readE;
     
     // Used for write back
     
     logic [1:0] result_srcE;
     logic [4:0] rd_addrE; 
     logic reg_writeE;
     
     // Used for forwarding (comparing rs1/rs2 (E) addr w/ rd (M/W) addr
     
     logic [4:0] rs1_addrE;
     logic [4:0] rs2_addrE;
     
     // LOAD-STALL logic
     
     logic is_loadE;
     always_comb begin
        if (result_srcE == 2'b01) begin
            is_loadE = 1;
        end
        else begin
            is_loadE = 0;
        end
     end
     
     // LOAD STALL LOGIC
     
     always_comb begin
         if (is_loadE == 1 && (rd_addrE == rs1_addrD || rd_addrE == rs2_addrD) && reg_writeE == 1 && rd_addrE != 32'd0) begin
            is_load_stall = 1;
         end
         else begin
            is_load_stall = 0;
         end
     end
     
     always_ff @(posedge clk) begin
        if (reset) begin
            pcE <= 0;
            pc_plus_4E <= 0;
            rs1_dataE <= 0;
            rs2_dataE <= 0;
            immediateE <= 0;
            alu_ctrlE <= 0;
            alu_src_aE <= 0;
            alu_src_bE <= 0;
            branchE <= 0;
            jumpE <= 0;
            funct3E <= 0;
            mem_writeE <= 0;
            mem_readE <= 0;
            result_srcE <= 0;
            rd_addrE <= 0;
            reg_writeE <= 0;
            rs1_addrE <= 0;
            rs2_addrE <= 0;   
        end 
        
        else if (is_memory_stall) begin
            pcE <= pcE;
            pc_plus_4E <= pc_plus_4E;
            rs1_dataE <= rs1_dataE;          
            rs2_dataE <= rs2_dataE;   
            immediateE <= immediateE;
            alu_ctrlE <= alu_ctrlE;
            alu_src_aE <= alu_src_aE;
            alu_src_bE <= alu_src_bE;
            branchE <= branchE;
            jumpE <= jumpE;
            funct3E <= funct3E;
            mem_writeE <= mem_writeE;
            mem_readE <= mem_readE;
            result_srcE <= result_srcE;
            rd_addrE <= rd_addrE;
            reg_writeE <= reg_writeE;
            rs1_addrE <= rs1_addrE;
            rs2_addrE <= rs2_addrE;
        end
        
        else if (is_load_stall || is_flush) begin
            pcE <= 0;
            pc_plus_4E <= 0;
            rs1_dataE <= 0;
            rs2_dataE <= 0;
            immediateE <= 0;
            alu_ctrlE <= 0;
            alu_src_aE <= 0;
            alu_src_bE <= 0;
            branchE <= 0;
            jumpE <= 0;
            funct3E <= 0;
            mem_writeE <= 0;
            mem_readE <= 0;
            result_srcE <= 0;
            rd_addrE <= 0;
            reg_writeE <= 0;
            rs1_addrE <= 0;
            rs2_addrE <= 0;
        end
        
        else begin
            pcE <= pcD;
            pc_plus_4E <= pc_plus_4D;
            rs1_dataE <= rs1_dataD;          
            rs2_dataE <= rs2_dataD;   
            immediateE <= immediateD;
            alu_ctrlE <= alu_ctrlD;
            alu_src_aE <= alu_src_aD;
            alu_src_bE <= alu_src_bD;
            branchE <= branchD;
            jumpE <= jumpD;
            funct3E <= funct3D;
            mem_writeE <= mem_writeD;
            mem_readE <= mem_readD;
            result_srcE <= result_srcD;
            rd_addrE <= rd_addrD;
            reg_writeE <= reg_writeD;
            rs1_addrE <= rs1_addrD;
            rs2_addrE <= rs2_addrD;
        end
    end
     
     // ~~~~~ register file + alu decoer -> alu ~~~~~
     
     logic [31:0] alu_resE;
     
     logic [31:0] op1_inputE;
     logic [31:0] op2_inputE;
     
     logic [31:0] forwarded_rs1E; // forwarding logic
     logic [31:0] forwarded_rs2E; // forwarding logic
     
     always_comb begin
        case (alu_src_aE)
            2'b00: op1_inputE = forwarded_rs1E;
            2'b01: op1_inputE = pcE;
            2'b10: op1_inputE = 32'd0;
            default: op1_inputE = 32'd0;
        endcase
     end
     
     always_comb begin
        case (alu_src_bE)
            1'b0: op2_inputE = forwarded_rs2E;
            1'b1: op2_inputE = immediateE;
            default: op2_inputE = 32'd0;
        endcase
     end
     
     alu alu_inst
     ( .op1(op1_inputE), .op2(op2_inputE), .alu_ctrl(alu_ctrlE), .alu_res(alu_resE) );
     
     // ~~~~~ pc + branch + jal/jalr logic ~~~~~
     
     logic take_branchE;
     logic [31:0] branch_targetE; // if comparison successful, address of appropriate label
     
     logic [31:0] jal_targetE;
     logic [31:0] jalr_targetE;
     
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
     
        take_branchE = 0;
        branch_targetE = pcE + immediateE;
        next_pcF = pc_plus_4F;
        
        jal_targetE = pcE + immediateE;
        jalr_targetE = (forwarded_rs1E + immediateE) & 32'hFFFFFFFE;
     
        if (branchE) begin
            case (funct3E)
            
                BEQ: begin
                    if (forwarded_rs1E == forwarded_rs2E) begin
                        take_branchE = 1;
                    end
                    else take_branchE = 0;
                end
                
                BNE: begin
                    if (forwarded_rs1E != forwarded_rs2E) begin
                        take_branchE = 1;
                    end
                    else take_branchE = 0;
                end
                
                BLTU: begin
                    if (forwarded_rs1E < forwarded_rs2E) begin
                        take_branchE = 1;
                    end
                    else take_branchE = 0;
                end
                
                BGEU: begin
                    if (forwarded_rs2E <= forwarded_rs1E) begin
                        take_branchE = 1;
                    end
                    else take_branchE = 0;
                end
                
                BLT: begin
                    if ($signed(forwarded_rs1E) < $signed(forwarded_rs2E) ) begin
                        take_branchE = 1;
                    end
                    else take_branchE = 0;
                end
                
                BGE: begin
                    if ($signed(forwarded_rs2E) <= $signed(forwarded_rs1E) ) begin
                        take_branchE = 1;
                    end
                    else take_branchE = 0;
                end
                
                default: take_branchE = 0;
            endcase
        end
        
        if (take_branchE) begin
            next_pcF = branch_targetE;
        end
        case (jumpE)
            no_jump: ;
            jal: next_pcF = jal_targetE;
            jalr: next_pcF = jalr_targetE;
            default: ;
        endcase
        
     end
     
     // FLUSHING LOGIC (JUMP / BRANCH)
     
     always_comb begin
        if (jumpE == jal || jumpE == jalr || take_branchE == 1) begin
            is_flush = 1;
        end
        else begin
            is_flush = 0;
        end
     end
     
     
     // ---------------------------------------- MEMORY ---------------------------------------- 
     
     
     logic [31:0] pcM;
     logic [31:0] pc_plus_4M;
     logic [31:0] rs2_dataM;
     logic [31:0] alu_resM;
     logic mem_writeM;   
     logic mem_readM;
     
     logic request_indicatorM; // 1 if CPU requests either a load or a store
     logic transaction_pendingM;
     
     // For write back
      
     logic [1:0] result_srcM;
     logic [4:0] rd_addrM; 
     logic reg_writeM;
     
     always_ff @(posedge clk) begin
        if (reset) begin
            pcM <= 0;
            pc_plus_4M <= 0;
            rs2_dataM <= 0;
            alu_resM <= 0;
            mem_writeM <= 0;
            mem_readM <= 0;
            result_srcM <= 0;
            rd_addrM <= 0;
            reg_writeM <= 0;
        end
        else if (is_memory_stall) begin
            pcM <= pcM;
            pc_plus_4M <= pc_plus_4M;
            rs2_dataM <= rs2_dataM;
            alu_resM <= alu_resM;
            mem_writeM <= mem_writeM;
            mem_readM <= mem_readM;
            result_srcM <= result_srcM;
            rd_addrM <= rd_addrM;
            reg_writeM <= reg_writeM;            
        end
        else begin
            pcM <= pcE;
            pc_plus_4M <= pc_plus_4E;
            rs2_dataM <= forwarded_rs2E;
            alu_resM <= alu_resE;
            mem_writeM <= mem_writeE;
            mem_readM <= mem_readE;
            result_srcM <= result_srcE;
            rd_addrM <= rd_addrE;
            reg_writeM <= reg_writeE;
        end
     end
     
     // Note: Load remains combinational 
     // mem_readM identifies loads and mem_writeM identifies stores
     
     // REQUEST SENT LOGIC
     
     always_comb begin
        if ((mem_writeM || mem_readM) && !transaction_pendingM) begin
            request_indicatorM = 1;
        end
        else begin
            request_indicatorM = 0;
        end
     end
     
     // TRANSACTION PENDING LOGIC
     
     always_ff @(posedge clk) begin
        if (reset) begin
            transaction_pendingM <= 0;
        end
        else if (completed_transaction) begin
            transaction_pendingM <= 0;
        end
        else if (request_indicatorM) begin
            transaction_pendingM <= 1; // stays latched on until transaction is over
        end
     end
     
     // STALL (FROM REQUEST) LOGIC
     
     always_comb begin
        if (completed_transaction) begin
            is_memory_stall = 0;
        end
        else if (request_indicatorM || transaction_pendingM) begin
            is_memory_stall = 1;
        end
        else begin
            is_memory_stall = 0;
        end
     end
     
     // TEMP
     
     assign mem_request = request_indicatorM;
     assign mem_read_or_write = mem_writeM;
     assign mem_address = alu_resM;
     assign store_data_request = rs2_dataM;
     
     // ---------------------------------------- WRITE BACK ---------------------------------------- 
     
     logic [31:0] pcW;
     logic [31:0] pc_plus_4W;
     logic [31:0] data_outW;
     logic [31:0] alu_resW;
     logic [1:0] result_srcW;
     
     // rd_addrW and reg_writeW defined in Decode
     
     always_ff @(posedge clk) begin
         if (reset) begin
            pcW <= 0;
            pc_plus_4W <= 0;
            data_outW <= 0;
            alu_resW <= 0;
            result_srcW <= 0;
            rd_addrW <= 0;
            reg_writeW <= 0;
         end
         else if (is_memory_stall) begin
            pcW <= pcW;
            pc_plus_4W <= pc_plus_4W;
            data_outW <= data_outW;
            alu_resW <= alu_resW;
            result_srcW <= result_srcW;
            rd_addrW <= rd_addrW;
            reg_writeW <= reg_writeW; 
         end
         else begin
            pcW <= pcM;
            pc_plus_4W <= pc_plus_4M;
            data_outW <= load_data_response;
            alu_resW <= alu_resM;
            result_srcW <= result_srcM;
            rd_addrW <= rd_addrM;
            reg_writeW <= reg_writeM;
         end
     end
     
     // ~~~~~ data memory + alu res + pc -> register write data ~~~~~
     
     always_comb begin
        case (result_srcW)
            2'b00: write_dataW = alu_resW;
            2'b01: write_dataW = data_outW;
            2'b10: write_dataW = pc_plus_4W;
            default: write_dataW = 32'd0;
        endcase
     end
     
     // FORWARDING LOGIC
     
     always_comb begin
        forwarded_rs1E = rs1_dataE;
        forwarded_rs2E = rs2_dataE;
        
        // rs1
     
        if (rs1_addrE == rd_addrM && reg_writeM == 1 && rd_addrM != 5'd0) begin
            forwarded_rs1E = alu_resM;
        end
        
        else if (rs1_addrE == rd_addrW && reg_writeW == 1 && rd_addrW != 5'd0) begin
            forwarded_rs1E = write_dataW;
        end
        
        // rs2
        
        if (rs2_addrE == rd_addrM && reg_writeM == 1 && rd_addrM != 5'd0) begin
            forwarded_rs2E = alu_resM;
        end
        
        else if (rs2_addrE == rd_addrW && reg_writeW == 1 && rd_addrW != 5'd0) begin
            forwarded_rs2E = write_dataW;
        end
    end
    
    assign debug_pc = pcW;
    assign debug_write_data = write_dataW;
     
endmodule
