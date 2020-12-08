`include "Const.v"

module Imm_Gen(input  [31:0] Inst_i,
               output [31:0] Imm_o);

wire [6:0] opcode = Inst_i[6:0];

assign Imm_o =
    (opcode == `OPCODE_OP_IMM || opcode == `OPCODE_LOAD) ?
            {{20{Inst_i[31]}}, Inst_i[31:20]} :
    opcode == `OPCODE_STORE ?
            {{20{Inst_i[31]}}, Inst_i[31:25], Inst_i[11:7]} :
    opcode == `OPCODE_BRANCH ?
            {{20{Inst_i[31]}}, Inst_i[31], Inst_i[7], Inst_i[30:25], Inst_i[11:8]} :
    32'hxxxxxxxx;

endmodule
