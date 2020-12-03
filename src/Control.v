`include "Const.v"
module Control(input  [6:0] Opcode_i,
               output RegWrite_o,
               output MemToReg_o,
               output MemRead_o,
               output MemWrite_o,
               output [1:0] ALUOp_o,
               output ALUSrc_o,
               output Branch_o);

assign {RegWrite_o, MemToReg_o, MemRead_o, MemWrite_o, ALUSrc_o, Branch_o} =
        Opcode_i == `OPCODE_OP     ? 6'b10x000 :
        Opcode_i == `OPCODE_IMM    ? 6'b10x010 :
        Opcode_i == `OPCODE_LOAD   ? 6'b111010 :
        Opcode_i == `OPCODE_STORE  ? 6'b0xx110 :
        Opcode_i == `OPCODE_BRANCH ? 6'b0xx001 :
        6'bxxxxxx;

assign ALUOp_o =
        Opcode_i == `OPCODE_OP     ? `ALU_OP_REG :
        Opcode_i == `OPCODE_IMM    ? `ALU_OP_IMM :
        Opcode_i == `OPCODE_LOAD   ? `ALU_OP_IMM :
        Opcode_i == `OPCODE_STORE  ? `ALU_OP_IMM :
        Opcode_i == `OPCODE_BRANCH ? `ALU_OP_REG :
        2'bxx;

endmodule
