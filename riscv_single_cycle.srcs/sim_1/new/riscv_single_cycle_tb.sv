`timescale 1ns / 1ps

module riscv_single_cycle_tb();

    logic clk;
    logic reset;
    
    riscv_single_cycle dut ( .clk(clk), .reset(reset) );
    
    initial begin
        clk = 0;
        reset = 1;
    
        // dut.im_inst.memory_array[0] = 32'h00500093; // addi x1, x0, 5
        // dut.im_inst.memory_array[1] = 32'h00700113; // addi x2, x0, 7
        // dut.im_inst.memory_array[2] = 32'h002081B3; // add x3, x1, x2
        // dut.im_inst.memory_array[3] = 32'h00001463; // bne x0,x0,+8 
        // dut.im_inst.memory_array[4] = 32'h12345237; // lui x4,0x12345
        // dut.im_inst.memory_array[5] = 32'h00001297; // auipc x5,0x1
        // dut.im_inst.memory_array[6] = 32'h00302023; // sw x3,0(x0)
        // dut.im_inst.memory_array[7] = 32'h00002303; // lw x6,0(x0)
        // dut.im_inst.memory_array[8] = 32'h00000013; // addi x0,x0,0 
        // dut.im_inst.memory_array[9]  = 32'h00618463; // beq x3,x6,+8 
        // dut.im_inst.memory_array[10] = 32'h06300493; // addi x9,x0,99 
        // dut.im_inst.memory_array[11] = 32'h00A00513; // addi x10,x0,10   
        // dut.im_inst.memory_array[12] = 32'h008005EF; // jal x11,+8
        // dut.im_inst.memory_array[13] = 32'h06300613; // addi x12,x0,99
        // dut.im_inst.memory_array[14] = 32'h00D586E7; // jalr x13,13(x11)
        // dut.im_inst.memory_array[15] = 32'h06300713; // addi x14,x0,99
        // dut.im_inst.memory_array[16] = 32'h00F00793; // addi x15,x0,15
        
        dut.rf_inst.register_array[1] = 32'd5;
        dut.rf_inst.register_array[2] = 32'd7;
        dut.rf_inst.register_array[3] = 32'd33;
        dut.rf_inst.register_array[5] = 32'd55;
        dut.rf_inst.register_array[7] = 32'd77;
        dut.rf_inst.register_array[8] = 32'd88;
        dut.rf_inst.register_array[9] = 32'd0;
        dut.rf_inst.register_array[10] = 32'd0;
        dut.rf_inst.register_array[11] = 32'd0;
        dut.rf_inst.register_array[12] = 32'd0;
        dut.rf_inst.register_array[13] = 32'd0;
        dut.rf_inst.register_array[14] = 32'd0;
        dut.rf_inst.register_array[15] = 32'd0;
        
        
    end
    
    task automatic check_fetch (
    input logic [31:0] predicted_cur_pc,
    input logic [31:0] predicted_next_pc,
    input logic [31:0] predicted_instr
    );
        begin
            
            // current pc
            
            if (dut.current_pc !== predicted_cur_pc) begin
                $error("TEST FAILED (fetch): The current pc %0d does not match the predicted pc %0d", dut.current_pc, predicted_cur_pc);
            end
            else begin
                $display("TEST PASSED (fetch): current pc = %0d", dut.current_pc);
            end   
            
            // next pc
            
            if (dut.next_pc !== predicted_next_pc) begin
                $error("TEST FAILED (fetch): The next pc %0d does not match the predicted pc %0d", dut.next_pc, predicted_next_pc);
            end
            else begin
                $display("TEST PASSED (fetch): next pc = %0d", dut.next_pc);
            end  
            
            // instruction
            
            if (dut.instruction !== predicted_instr) begin
                $error("TEST FAILED (fetch): The instruction %08h does not match the predicted instruction %08h", dut.instruction, predicted_instr);
            end
            else begin
                $display("TEST PASSED (fetch): instruction = %08h", dut.instruction);
            end       
        end
    endtask
    
    logic [14:0] md_ctrls;
    
    assign md_ctrls = {
    dut.reg_write,
    dut.mem_write,
    dut.alu_src_a,
    dut.alu_src_b,
    dut.result_src,
    dut.imm_sel,
    dut.branch,
    dut.jump,
    dut.alu_op
    };
    
    task automatic check_decode(
        input logic [14:0] predicted_md_ctrls,
        input logic [3:0] predicted_alu_ctrl            
    ); 
        begin
            
            // main decoder controls
            
            if (md_ctrls !== predicted_md_ctrls) begin
                $error("TEST FAILED (decode): The main decoder %015b does not match the predicted main decoder %015b", md_ctrls, predicted_md_ctrls);
            end
            else begin
                $display("TEST PASSED (decode): current main decoder = %015b", md_ctrls);
            end   
            
            // alu ctrl
            
            if (dut.alu_ctrl !== predicted_alu_ctrl) begin
                $error("TEST FAILED (decode): The alu ctrl %04b does not match the predicted alu ctrl %04b", dut.alu_ctrl, predicted_alu_ctrl);
            end
            else begin
                $display("TEST PASSED (decode): alu ctrl = %04b", dut.alu_ctrl);
            end  
            
        end
    endtask
    
    task automatic check_operand(
        input logic [4:0] predicted_write_addr,
        input logic [4:0] predicted_rs1_addr,
        input logic [4:0] predicted_rs2_addr,
        input logic [31:0] predicted_rs1_data,
        input logic [31:0] predicted_rs2_data,
        input logic [31:0] predicted_immediate
    );
        begin
            
            // write addr
        
            if (dut.write_addr !== predicted_write_addr) begin
                $error("TEST FAILED (operand): The write address %05b does not match the predicted write address %05b", 
                dut.write_addr, predicted_write_addr);
            end
            else begin
                $display("TEST PASSED (operand): write address = %05b", dut.write_addr);
            end  
            
            // rs1 addr
            
            if (dut.rs1_addr !== predicted_rs1_addr) begin
                $error("TEST FAILED (operand): The rs1 address %05b does not match the predicted rs1 address %05b", 
                dut.rs1_addr, predicted_rs1_addr);
            end
            else begin
                $display("TEST PASSED (operand): rs1 address = %05b", dut.rs1_addr);
            end  
            
            // rs2 addr
            
            if (dut.rs2_addr !== predicted_rs2_addr) begin
                $error("TEST FAILED (operand): The rs2 address %05b does not match the predicted rs2 address %05b", 
                dut.rs2_addr, predicted_rs2_addr);
            end
            else begin
                $display("TEST PASSED (operand): rs2 address = %05b", dut.rs2_addr);
            end  
            
            // rs1 data
            
            if (dut.rs1_data !== predicted_rs1_data) begin
                $error("TEST FAILED (operand): The rs1 data %0d does not match the predicted rs1 data %0d", 
                dut.rs1_data, predicted_rs1_data);
            end
            else begin
                $display("TEST PASSED (operand): rs1 data = %0d", dut.rs1_data);
            end  
            
            // rs2 data
            
            if (dut.rs2_data !== predicted_rs2_data) begin
                $error("TEST FAILED (operand): The rs2 data %0d does not match the predicted rs2 data %0d", 
                dut.rs2_data, predicted_rs2_data);
            end
            else begin
                $display("TEST PASSED (operand): rs2 data = %0d", dut.rs2_data);
            end   
            
            // immediate
            
            if (dut.immediate !== predicted_immediate) begin
                $error("TEST FAILED (operand): The immediate %0d does not match the predicted immediate %0d", 
                dut.immediate, predicted_immediate);
            end
            else begin
                $display("TEST PASSED (operand): immediate = %0d", dut.immediate);
            end   
            
        end
    endtask
    
    task automatic check_alu_path(
        input logic [31:0] predicted_op1_input,
        input logic [31:0] predicted_op2_input,
        input logic [31:0] predicted_alu_res
    );
        begin
        
            // op 1
            
            if (dut.op1_input !== predicted_op1_input) begin
                $error("TEST FAILED (alu path): The op1 %08h does not match the predicted op1 %08h", dut.op1_input, predicted_op1_input);
            end
            else begin
                $display("TEST PASSED (alu path): op1 = %08h", dut.op1_input);
            end  
            
            // op 2
            
            if (dut.op2_input !== predicted_op2_input) begin
                $error("TEST FAILED (alu path): The op2 %08h does not match the predicted op2 %08h", dut.op2_input, predicted_op2_input);
            end
            else begin
                $display("TEST PASSED (alu path): op2 = %08h", dut.op2_input);
            end  
            
            // alu res
            
            if (dut.alu_res !== predicted_alu_res) begin
                $error("TEST FAILED (alu path): The alu res %08h does not match the predicted alu res %08h", dut.alu_res, predicted_alu_res);
            end
            else begin
                $display("TEST PASSED (alu path): alu res = %08h", dut.alu_res);
            end
        end
    endtask
    
    task automatic check_data_path(
        input logic [31:0] predicted_data_out
    );
        begin
        
            // data out
            
            if (dut.data_out !== predicted_data_out) begin
                $error("TEST FAILED (data path): The data out %08h does not match the predicted data out %08h", dut.data_out, predicted_data_out);
            end
            else begin
                $display("TEST PASSED (data path): data out = %08h", dut.data_out);
            end
        end    
        
    endtask
    
    task automatic check_reg_write(
        input logic [31:0] predicted_write_data
    );
        begin
        
            // write data
            if (dut.write_data !== predicted_write_data) begin
                $error("TEST FAILED (reg write): The write data %08h does not match the predicted write data %08h", 
                dut.write_data, predicted_write_data);
            end
            else begin
                $display("TEST PASSED (reg write): write data = %08h", dut.write_data);
            end
        end
    
    endtask
    
    task automatic check_branch(
        input logic predicted_take_branch,
        input logic [31:0] predicted_branch_target
    );
        begin
        
            // take branch
            
            if (dut.take_branch !== predicted_take_branch) begin
                $error("TEST FAILED (branch): The take branch %0d does not match the predicted take branch %0d", 
                dut.take_branch, predicted_take_branch);
            end
            else begin
                $display("TEST PASSED (branch): take branch = %0d", dut.take_branch);
            end
            
            // branch target
            
            if (dut.branch_target !== predicted_branch_target) begin
                $error("TEST FAILED (branch): The branch target %08h does not match the predicted branch target %08h", 
                dut.branch_target, predicted_branch_target);
            end
            else begin
                $display("TEST PASSED (branch): branch target = %08h", dut.branch_target);
            end
        
        end
    endtask
    
    task automatic check_jump(
        input logic [31:0] predicted_jal_target,
        input logic [31:0] predicted_jalr_target
    );
        begin
        
            //jal
            
            if (dut.jal_target !== predicted_jal_target) begin
                $error("TEST FAILED (jump): The jal target %08h does not match the predicted jal target %08h", 
                dut.jal_target, predicted_jal_target);
            end
            else begin
                $display("TEST PASSED (jump): jal target = %08h", dut.jal_target);
            end
            
            // jalr
            
            if (dut.jalr_target !== predicted_jalr_target) begin
                $error("TEST FAILED (jump): The jalr target %08h does not match the predicted jalr target %08h", 
                dut.jalr_target, predicted_jalr_target);
            end
            else begin
                $display("TEST PASSED (jump): jalr target = %08h", dut.jalr_target);
            end
            
        end
    endtask
    
    initial begin
        #1; 
        
        // TEST 1
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd0, 32'd4, 32'h00500093);
        check_decode(15'b1_0_00_1_00_000_0_00_10, 4'b0000);
        check_operand(5'd1, 5'd0, 5'd5, 32'd0, 32'd55, 32'd5);
        check_alu_path(32'd0, 32'd5, 32'd5);
        check_reg_write(32'h00000005);
        check_jump(32'h00000005, 32'h00000004);
        
        // TEST 2
        
        reset = 0;
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd4, 32'd8, 32'h00700113);
        check_decode(15'b1_0_00_1_00_000_0_00_10, 4'b0000);
        check_operand(5'd2, 5'd0, 5'd7, 32'd0, 32'd77, 32'd7);
        check_alu_path(32'd0, 32'd7, 32'd7);
        check_reg_write(32'h00000007);
        check_jump(32'h0000000B, 32'h00000006);
        
        // TEST 3
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd8, 32'd12, 32'h002081B3);
        check_decode(15'b1_0_00_0_00_000_0_00_10, 4'b0000);
        check_operand(5'd3, 5'd1, 5'd2, 32'd5, 32'd7, 32'd2);
        check_alu_path(32'd5, 32'd7, 32'd12);
        check_reg_write(32'h0000000C);
        check_jump(32'h0000000A, 32'h00000006);
        
        // TEST 4
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd12, 32'd16, 32'h00001463);
        check_decode(15'b0_0_00_0_00_010_1_00_01, 4'b0001);
        check_operand(5'd8, 5'd0, 5'd0, 32'd0, 32'd0, 32'd8);
        check_alu_path(32'd0, 32'd0, 32'd0);
        check_reg_write(32'd0);
        check_branch(1'b0, 32'd20);
        check_jump(32'h00000014, 32'h00000008);
        
        // TEST 5
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd16, 32'd20, 32'h12345237);
        check_decode(15'b1_0_10_1_00_011_0_00_00, 4'b0000);
        check_operand(5'd4, 5'd8, 5'd3, 32'd88, 32'd12, 32'h12345000);
        check_alu_path(32'd0, 32'h12345000, 32'h12345000);
        check_reg_write(32'h12345000);
        check_jump(32'h12345010, 32'h12345058);
        
        // TEST 6
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd20, 32'd24, 32'h00001297);
        check_decode(15'b1_0_01_1_00_011_0_00_00, 4'b0000);
        check_operand(5'd5, 5'd0, 5'd0, 32'd0, 32'd0, 32'h00001000);
        check_alu_path(32'd20, 32'h00001000, 32'h00001014);
        check_reg_write(32'h00001014);
        check_jump(32'h00001014, 32'h00001000);
        
        // TEST 7 (store x3 [value: 12] into address 0)
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd24, 32'd28, 32'h00302023);
        check_decode(15'b0_1_00_1_00_001_0_00_00, 4'b0000);
        check_operand(5'd0, 5'd0, 5'd3, 32'd0, 32'd12, 32'd0);
        check_alu_path(32'd0, 32'd0, 32'd0);
        check_reg_write(32'd0);
        check_jump(32'h00000018, 32'h00000000);
        
        // TEST 8 (load the stored value 12 from address 0 into x6)
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd28, 32'd32, 32'h00002303);
        check_decode(15'b1_0_00_1_01_000_0_00_00, 4'b0000);
        check_operand(5'd6, 5'd0, 5'd0, 32'd0, 32'd0, 32'd0);
        check_alu_path(32'd0, 32'd0, 32'd0);
        check_data_path(32'd12);
        check_reg_write(32'd12);
        check_jump(32'h0000001C, 32'h00000000);
        
        // TEST 9 (rising clock edge underneath writes value 12 into x6 register file)
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd32, 32'd36, 32'h00000013);
        check_decode(15'b1_0_00_1_00_000_0_00_10, 4'b0000);
        check_operand(5'd0, 5'd0, 5'd0, 32'd0, 32'd0, 32'd0);
        check_alu_path(32'd0, 32'd0, 32'd0);
        check_reg_write(32'd0);
        check_jump(32'h00000020, 32'h00000000);
        
        if (dut.rf_inst.register_array[6] !== 32'd12) begin
            $error(
                "TEST FAILED (load writeback): x6 is %0d but should be 12",
                dut.rf_inst.register_array[6]
            );
        end
        else begin
            $display(
                "TEST PASSED (load writeback): x6 = %0d",
                dut.rf_inst.register_array[6]
            );
        end
        
        // TEST 10
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd36, 32'd44, 32'h00618463);
        check_decode(15'b0_0_00_0_00_010_1_00_01, 4'b0001);
        check_operand(5'd8, 5'd3, 5'd6, 32'd12, 32'd12, 32'd8);
        check_alu_path(32'd12, 32'd12, 32'd0);
        check_reg_write(32'd0);
        check_branch(1'b1, 32'd44);
        check_jump(32'h0000002C, 32'h00000014);
        
        // TEST 11
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd44, 32'd48, 32'h00A00513);
        check_decode(15'b1_0_00_1_00_000_0_00_10, 4'b0000);
        check_operand(5'd10, 5'd0, 5'd10, 32'd0, 32'd0, 32'd10);
        check_alu_path(32'd0, 32'd10, 32'd10);
        check_reg_write(32'd10);
        check_jump(32'h00000036, 32'h0000000A);
        
        if (dut.rf_inst.register_array[9] !== 32'd0) begin
            $error(
                "TEST FAILED (branch skip): x9 is %0d but should remain 0",
                dut.rf_inst.register_array[9]
            );
        end
        else begin
            $display(
                "TEST PASSED (branch skip): x9 remained %0d",
                dut.rf_inst.register_array[9]
            );
        end
        
        // TEST 12 (jal at pc = 48 jumps to pc = 56 and saves 52 into x11)

        @(posedge clk);
        #1;
        
        check_fetch(32'd48, 32'd56, 32'h008005EF);
        check_decode(15'b1_0_00_0_10_100_0_01_00, 4'b0000);
        check_operand(5'd11, 5'd0, 5'd8, 32'd0, 32'd88, 32'd8);
        check_alu_path(32'd0, 32'd88, 32'd88);
        check_reg_write(32'd52);
        check_jump(32'd56, 32'd8);
        
        // TEST 13 (jalr at pc = 56 w/ x11 = 52 and imm = 13 so 52 + 13 = 65 -> 64)
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd56, 32'd64, 32'h00D586E7);
        check_decode(15'b1_0_00_1_10_000_0_10_00, 4'b0000);
        check_operand(5'd13, 5'd11, 5'd13, 32'd52, 32'd0, 32'd13);
        check_alu_path(32'd52, 32'd13, 32'd65);
        check_reg_write(32'd60);
        check_jump(32'd69, 32'd64);
        
        if (dut.rf_inst.register_array[11] !== 32'd52) begin
            $error(
                "TEST FAILED (JAL link): x11 is %0d but should be 52",
                dut.rf_inst.register_array[11]
            );
        end
        else begin
            $display(
                "TEST PASSED (JAL link): x11 = %0d",
                dut.rf_inst.register_array[11]
            );
        end
        
        if (dut.rf_inst.register_array[12] !== 32'd0) begin
            $error(
                "TEST FAILED (JAL skip): x12 is %0d but should remain 0",
                dut.rf_inst.register_array[12]
            );
        end
        else begin
            $display(
                "TEST PASSED (JAL skip): x12 remained %0d",
                dut.rf_inst.register_array[12]
            );
        end
        
        // TEST 14 
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd64, 32'd68, 32'h00F00793);
        check_decode(15'b1_0_00_1_00_000_0_00_10, 4'b0000);
        check_operand(5'd15, 5'd0, 5'd15, 32'd0, 32'd0, 32'd15);
        check_alu_path(32'd0, 32'd15, 32'd15);
        check_reg_write(32'd15);
        check_jump(32'd79, 32'd14);
        
        if (dut.rf_inst.register_array[13] !== 32'd60) begin
            $error(
                "TEST FAILED (JALR link): x13 is %0d but should be 60",
                dut.rf_inst.register_array[13]
            );
        end
        else begin
            $display(
                "TEST PASSED (JALR link): x13 = %0d",
                dut.rf_inst.register_array[13]
            );
        end
        
        if (dut.rf_inst.register_array[14] !== 32'd0) begin
            $error(
                "TEST FAILED (JALR skip): x14 is %0d but should remain 0",
                dut.rf_inst.register_array[14]
            );
        end
        else begin
            $display(
                "TEST PASSED (JALR skip): x14 remained %0d",
                dut.rf_inst.register_array[14]
            );
        end
        
        // TEST 15
        
        reset = 1;
        
        @(posedge clk);
        #1;
        
        check_fetch(32'd0, 32'd4, 32'h00500093);
        check_decode(15'b1_0_00_1_00_000_0_00_10, 4'b0000);
        check_operand(5'd1, 5'd0, 5'd5, 32'd0, 32'h00001014, 32'd5);
        check_alu_path(32'd0, 32'd5, 32'd5);
        check_reg_write(32'h00000005);
        check_jump(32'h00000005, 32'h00000004);
        
        
        
        $finish;
    end
    
    always begin
        #5;
        clk = ~clk;
    end
    
endmodule
