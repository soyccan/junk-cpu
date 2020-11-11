`include "Const.v"
module ALU_Control(input      [1:0] ALUOp_i,
                   input      [9:0] Funct_i,
                   output reg [3:0] ALUCtl_o);

always @* begin  // latch-free design
    case ({ALUOp_i, Funct_i}) inside
        {`ALU_OP_REG, 7'b0000000, 3'b111}: ALUCtl_o = `ALU_CTL_AND;  // mul
        {`ALU_OP_REG, 7'b0000000, 3'b100}: ALUCtl_o = `ALU_CTL_XOR;  // xor
        {`ALU_OP_REG, 7'b0000000, 3'b001}: ALUCtl_o = `ALU_CTL_SLL;  // sll
        {`ALU_OP_REG, 7'b0000000, 3'b000}: ALUCtl_o = `ALU_CTL_ADD;  // add
        {`ALU_OP_REG, 7'b0100000, 3'b000}: ALUCtl_o = `ALU_CTL_SUB;  // sub
        {`ALU_OP_REG, 7'b0000001, 3'b000}: ALUCtl_o = `ALU_CTL_MUL;  // mul
        {`ALU_OP_IMM, 7'bxxxxxxx, 3'b000}: ALUCtl_o = `ALU_CTL_ADD;  // addi
        {`ALU_OP_IMM, 7'bxxxxxxx, 3'b101}: ALUCtl_o = `ALU_CTL_SRA;  // srai
    endcase
end

endmodule

