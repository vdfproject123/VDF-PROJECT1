module instruction_memory (
    input  [31:0] PC,
    output reg [31:0] Instruction
);
    wire [6:0] Mem_addr; // 7 bits needed for 128 locations
    assign [29:0] Mem_addr = PC[31:2];

    reg [31:0] Instruction_array[31:0];

    initial begin
        
         Instruction_arry[0] = 32'b0000000_00111_00110_000_00101_0110011; // add x5, x6, x7
        Instruction_arry[1] = 32'b0100000_00111_00110_000_00101_0110011; // sub x5, x6, x7
        Instruction_arry[2] = 32'b00000000010100_00110_000_00101_0010011; // addi x5, x6, 20

        // Data Transfer instructions (here 40 for immediate, see below for split)
        Instruction_arry[3] = 32'b000000000101000_00110_010_00101_0000011; // lw x5, 40(x6)
        Instruction_arry[4] = 32'b0000000_00101_00110_010_10100_0100011;   // sw x5, 40(x6)

        // Logical instructions
        Instruction_arry[5]  = 32'b0000000_00111_00110_111_00101_0110011; // and x5, x6, x7
        Instruction_arry[6] = 32'b0000000_00111_00110_110_00101_0110011; // or x5, x6, x7
        Instruction_arry[7] = 32'b0000000_00111_00110_100_00101_0110011; // xor x5, x6, x7
        Instruction_arry[8] = 32'b00000000010100_00110_111_00101_0010011; // andi x5, x6, 20
        Instruction_arry[9] = 32'b00000000010100_00110_110_00101_0010011; // ori x5, x6, 20
        Instruction_arry[10] = 32'b00000000010100_00110_100_00101_0010011; // xori x5, x6, 20

        // Shift instructions
        Instruction_arry[11] = 32'b0000000_00111_00110_001_00101_0110011; // sll x5, x6, x7
        Instruction_arry[12] = 32'b0000000_00111_00110_101_00101_0110011; // srl x5, x6, x7
        Instruction_arry[13] = 32'b0100000_00111_00110_101_00101_0110011; // sra x5, x6, x7
        Instruction_arry[14] = 32'b0000000_00011_00110_001_00101_0010011; // slli x5, x6, 3
        Instruction_arry[15] = 32'b0000000_00011_00110_101_00101_0010011; // srli x5, x6, 3
        Instruction_arry[16] = 32'b0100000_00011_00110_101_00101_0010011; // srai x5, x6, 3

        // Conditional branch (beq x5,x6,100)
        // immediate=100 (binary: 00001100100), per RV32I spec:
        // imm[12]=0 | imm[10:5]=000011 | rs2=00110 | rs1=00101 | funct3=000 | imm[4:1]=0100 | imm[11]=0 | opcode=1100011
        // Fields: [imm[12] imm[10:5] rs2 rs1 funct3 imm[4:1] imm[11] opcode]
        
        Instruction_arry[17] = 32'b0_000011_00110_00101_000_0100_0_1100011; // beq x5, x6, 100

        // bne x5, x6, 100 (same bits, funct3=001)
        Instruction_arry[18] = 32'b0_000011_00110_00101_001_0100_0_1100011; // bne x5, x6, 100

        // Unconditional branch
        // jal x1, 100 (J-type packing, example for small imm)
        // For small offset, use imm=100 (binary: 0000000001100100)
        // jalr x1, 0(x5) (I-type)
        Instruction_arry[19] = 32'b0000000001100100_00001_1101111; // jal x1, 100
        Instruction_arry[20] = 32'b000000000000_00101_000_00001_1100111;   // jalr x1, 0(x5)

        // Zero for remaining
        integer i;
        for (i = 21; i < 32; i = i + 1) Instruction_arry[i] = 32'd0;
    end


    always @(*) begin
        Instruction = Instruction_array[Mem_addr];
    end
endmodule
