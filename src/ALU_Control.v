`include "Const.v"
module ALU_Control(input      [1:0] ALUOp_i,
                   input      [9:0] Funct_i,
                   output reg [3:0] ALUCtl_o);

always @* begin  // latch-free design
    case (ALUOp_i)
        `ALU_OP_REG:
        case (Funct_i)
            {7'b0000000, 3'b111}: ALUCtl_o = `ALU_CTL_AND;  // mul
            {7'b0000000, 3'b100}: ALUCtl_o = `ALU_CTL_XOR;  // xor
            {7'b0000000, 3'b001}: ALUCtl_o = `ALU_CTL_SLL;  // sll
            {7'b0000000, 3'b000}: ALUCtl_o = `ALU_CTL_ADD;  // add
            {7'b0100000, 3'b000}: ALUCtl_o = `ALU_CTL_SUB;  // sub
            {7'b0000001, 3'b000}: ALUCtl_o = `ALU_CTL_MUL;  // mul
        endcase

        `ALU_OP_IMM:
        case (Funct_i[2:0])
            {3'b000}: ALUCtl_o = `ALU_CTL_ADD;  // addi
            {3'b101}: ALUCtl_o = `ALU_CTL_SRA;  // srai
        endcase

        `ALU_OP_STR:
        case (Funct_i[2:0])
            {3'b010}: ALUCtl_o = `ALU_CTL_ADD;  // sw
        endcase
    endcase
end

endmodule

