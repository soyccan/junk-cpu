`include "Const.v"
module Control(input  [6:0] Opcode_i,
               output RegWrite_o,
               output MemToReg_o,
               output MemRead_o,
               output MemWrite_o,
               output [1:0] ALUOp_o,
               output ALUSrc_o,
               output Branch_o);

// always @* begin
//     case (Opcode_i)
//         7'b0110011: {ALUOp_o, ALUSrc_o, RegWrite_o} = {`ALU_OP_REG, 1'b0, 1'b1};  // R-type arithmetic
//         7'b0010011: {ALUOp_o, ALUSrc_o, RegWrite_o} = {`ALU_OP_IMM, 1'b1, 1'b1};  // I-type arithmetic
//     endcase
// end

endmodule
