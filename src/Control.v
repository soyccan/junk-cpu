`include "Const.v"
module Control(input  [6:0] Opcode_i,
               input  NoOp_i,
               output RegWrite_o,
               output MemToReg_o,
               output MemRead_o,
               output MemWrite_o,
               output [1:0] ALUOp_o,
               output ALUSrc_o,
               output Branch_o);

// TODO: MemRead should not be don't care?
assign {RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o, ALUSrc_o, Branch_o} =
        NoOp_i                     ? 6'b000000 :
        Opcode_i == `OPCODE_OP     ? 6'b100000 :
        Opcode_i == `OPCODE_IMM    ? 6'b100010 :
        Opcode_i == `OPCODE_LOAD   ? 6'b111010 :
        Opcode_i == `OPCODE_STORE  ? 6'b0x0110 :
        Opcode_i == `OPCODE_BRANCH ? 6'b0x0001 :
        6'bxxxxxx;

assign ALUOp_o =
        NoOp_i                     ? 2'bxx       :
        Opcode_i == `OPCODE_OP     ? `ALU_OP_REG :
        Opcode_i == `OPCODE_IMM    ? `ALU_OP_IMM :
        Opcode_i == `OPCODE_LOAD   ? `ALU_OP_IMM :
        Opcode_i == `OPCODE_STORE  ? `ALU_OP_STR :
        Opcode_i == `OPCODE_BRANCH ? `ALU_OP_REG :
        2'bxx;

endmodule
