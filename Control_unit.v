module OpDecoder (
    input wire [6:0] opcode,
    output reg takeBranch,
    output reg selectResult,
    output reg writeMem,
    output reg aluInputSel,
    output reg [1:0] immediateSel,
    output reg enableRegWrite,
    output reg [1:0] aluOpCode
);
    // Define unique names for the instruction opcodes
    localparam OPCODE_LOAD   = 7'b0000011,
               OPCODE_STORE  = 7'b0100011,
               OPCODE_RTYPE  = 7'b0110011,
               OPCODE_ITYPE  = 7'b0010011,
               OPCODE_BRANCH = 7'b1100011;
    always @(*) begin
        case(opcode)
            OPCODE_LOAD: begin
                enableRegWrite = 1;
                immediateSel   = 2'b00;
                aluInputSel    = 1;
                writeMem       = 0;
                selectResult   = 1;
                takeBranch     = 0;
                aluOpCode      = 2'b00;
            end
            OPCODE_STORE: begin
                enableRegWrite = 0;
                immediateSel   = 2'b01;
                aluInputSel    = 1;
                writeMem       = 1;
                selectResult   = 0;
                takeBranch     = 0;
                aluOpCode      = 2'b00;
            end
            OPCODE_RTYPE: begin
                enableRegWrite = 1;
                immediateSel   = 2'b00;
                aluInputSel    = 0;
                writeMem       = 0;
                selectResult   = 0;
                takeBranch     = 0;
                aluOpCode      = 2'b10;
            end
            OPCODE_ITYPE: begin
                enableRegWrite = 1;
                immediateSel   = 2'b00;
                aluInputSel    = 1;
                writeMem       = 0;
                selectResult   = 0;
                takeBranch     = 0;
                aluOpCode      = 2'b10;
            end
            OPCODE_BRANCH: begin
                enableRegWrite = 0;
                immediateSel   = 2'b10;
                aluInputSel    = 0;
                writeMem       = 0;
                selectResult   = 0;
                takeBranch     = 1;
                aluOpCode      = 2'b01;
            end
            default: begin
                enableRegWrite = 0;
                immediateSel   = 2'b00;
                aluInputSel    = 0;
                writeMem       = 0;
                selectResult   = 0;
                takeBranch     = 0;
                aluOpCode      = 2'b00;
            end
        endcase
    end
endmodule

module AluControlUnit (
    input wire bit5,
    input wire [2:0] funct3bits,
    input wire funct7bit,
    input wire [1:0] aluOpSignal,
    output reg [2:0] aluSelect
);
    always @(*) begin
        case(aluOpSignal)
            2'b00: aluSelect = 3'b000;
            2'b01: begin
                case(funct3bits)
                    3'b000, 3'b001, 3'b100: aluSelect = 3'b010;
                    default: aluSelect = 3'b000;
                endcase
            end
            2'b10: begin
                case(funct3bits)
                    3'b000: begin
                        if({bit5,funct7bit} == 2'b11)
                            aluSelect = 3'b010;
                        else
                            aluSelect = 3'b000;
                    end
                    3'b001: aluSelect = 3'b001;
                    3'b100: aluSelect = 3'b100;
                    3'b101: aluSelect = 3'b101;
                    3'b110: aluSelect = 3'b110;
                    3'b111: aluSelect = 3'b111;
                    default: aluSelect = 3'b000;
                endcase
            end
            default: aluSelect = 3'b000;
        endcase
    end
endmodule

module PcDecisionMux (
    input wire branchSignal,
    input wire zeroFlag,
    input wire signFlag,
    input wire [2:0] funct3mux,
    output reg pcDecision
);
    always @(*) begin
        case(funct3mux)
            3'b000: pcDecision = branchSignal & zeroFlag;
            3'b001: pcDecision = branchSignal & ~zeroFlag;
            3'b100: pcDecision = branchSignal & signFlag;
            default: pcDecision = 0;
        endcase
    end
endmodule

module MasterControl (
    input wire zeroVal,
    input wire signVal,
    input wire [6:0] opcodeVal,
    input wire [2:0] func3val,
    input wire func7val,
    output wire resultSelector,
    output wire memWriter,
    output wire aluSourceSel,
    output wire [1:0] immediateSelector,
    output wire regWriter,
    output wire [2:0] aluCtrlOut,
    output wire pcSourceOut
);
    wire branchCtrl;
    wire [1:0] aluOpCtrl;

    OpDecoder controlMain (
        .opcode(opcodeVal),
        .takeBranch(branchCtrl),
        .selectResult(resultSelector),
        .writeMem(memWriter),
        .aluInputSel(aluSourceSel),
        .immediateSel(immediateSelector),
        .enableRegWrite(regWriter),
        .aluOpCode(aluOpCtrl)
    );

    AluControlUnit controlAlu (
        .aluOpSignal(aluOpCtrl),
        .bit5(opcodeVal[5]),
        .funct3bits(func3val),
        .funct7bit(func7val),
        .aluSelect(aluCtrlOut)
    );

    PcDecisionMux branchMux (
        .branchSignal(branchCtrl),
        .zeroFlag(zeroVal),
        .signFlag(signVal),
        .funct3mux(func3val),
        .pcDecision(pcSourceOut)
    );
endmodule
