module Top (
    input clk,
    input reset
);
    wire [31:0] PC, Pc_next, instruction;
    wire [31:0] immidiate_extend;
    wire [31:0] In_A, In_B;
    wire [31:0] ALU_result;
    wire [31:0] Read_2, Read_data, result;

    wire zero, sign_flag;
    wire [2:0] ALU_control;
    wire [1:0] Imm_src;
    wire resultSrc, mem_write, ALU_src, reg_write, pc_src;

    // PC Register
    PC pc (
        .write_data(Pc_next),
        .clk(clk),
        .reset(reset),
        .write_en(1'b1),     // always load unless halted (not supported yet)
        .read_data(PC)
    );

    // instructionuction Memory (word-aligned)
     instruction_memory IM (
        .PC(PC),
        .Instruction(instruction)
    );

    // Control Unit
    MasterContro cu (
        .zeroVal(zero),
        .signVal(sign_flag),
        .opcodeVal(instruction[6:0]),
        .func3val(instruction[14:12]),
        .func7val(instruction[30]),
        .resultSelector(resultSrc),
        .memWriter(mem_write),
        .aluSourceSel(ALU_src),
        .immediateSelector(Imm_src),
        .regWriter(reg_write),
        .aluCtrlOut(ALU_control),
        .pcSourceOut(pc_src)
    );

    // Register File
    Register_file RF (
        .clk(clk),
        .reset(reset), // active-low reset
        .write_en(reg_write),
        .read_addr1(instruction[19:15]),
        .read_addr2(instruction[24:20]),
        .write_addr(instruction[11:7]),
        .write_data(result),
        .read_data1(In_A),
        .read_data2(Read_2)
    );

    // Sign Extension
    Sign_Extender SE (
        .instr(instruction),
        .imm_src(Imm_src),
        .imm_ext(immidiate_extend)
    );

    // ALU Source MUX
    Mux2x1 Mx (
        .in1(RD2),
        .in2(immidiate_extend),
        .sel(ALU_src),
        .out(In_B)
    );

    // ALU
    ALU alu (
        .In_A(In_A),
        .In_B(In_B),
        .ALU_control_sig(ALU_control),
        .ALU_result(ALU_result),
        .zero_flag (zero),
        .sign_flag(sign_flag)
    );

    // Data Memory
    data_memory_unit DM (
        .clk(clk),
        .write_enable(mem_write),
        .address(ALU_result),
        .write_data(RD2),
        .read_data(Read_data)
    );

    // result MUX (ALU or Memory)
    Mux2x1 M2 (
        .in1(ALU_result),
        .in2(Read_data),
        .sel(resultSrc),
        .out(result)
    );

    // PC Next Logic (PC + 4 or PC + immidiate_extend)
    PC_Nextlogic PC_NX (
        .sel(pc_src),
        .curr_addr(PC),
        .offset(immidiate_extend),
        .next_addr(Pc_next)
    );

endmodule
