# RV32I Single-Cycle Processor

A 32-bit single-cycle RISC-V processor implemented in SystemVerilog and verified using self-checking testbenches in Vivado.

## Features

- RV32I arithmetic and logical instructions
- Immediate arithmetic instructions
- LUI and AUIPC
- Word loads and stores
- BEQ, BNE, BLT, BGE, BLTU, and BGEU
- JAL and JALR
- Register file with x0 hardwired to zero
- Separate instruction and data memories
- Self-checking module and integrated processor testbenches

## Architecture

The processor contains:

- Program counter
- Instruction memory
- Main control decoder
- ALU decoder
- Register file
- Immediate generator
- ALU
- Data memory
- Branch and jump control logic
- Register writeback selection

## Verification

The integrated SystemVerilog testbench verifies:

- Instruction fetch
- Main and ALU decoding
- Register operand extraction
- Immediate generation
- ALU execution
- Loads and stores
- Register writeback
- Taken and not-taken branches
- JAL and JALR
- Reset behavior

All integrated self-checking tests pass.

## FPGA Results

Target device: XC7Z020CLG400-1

- Verified clock frequency: 90.9 MHz
- Clock period: 11 ns
- Setup WNS: +0.193 ns
- Setup TNS: 0.000 ns
- Hold slack: +0.364 ns
- Failing endpoints: 0
- Post-implementation LUTs: 643
- Slice registers: 32
- LUTs used as memory: 172

## Tools

- SystemVerilog
- AMD Vivado 2025.2
- Vivado Simulator
