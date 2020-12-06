//*****************************************
//
//  Note:
//      1. lw放在I type處理(36行)
//      
//      2. sw, lw 都是用ALU加法
//      
//      3. TODO: branch需要做事????
//  
//  Update Date: 2020/12/4
//
//*****************************************

`include "Const.v"
module ALU_Control(input      [1:0] ALUOp_i,
                   input      [9:0] Funct_i,
                   output reg [3:0] ALUCtl_o);

always @* begin  // latch-free design
    case (ALUOp_i)
        `ALU_OP_REG: begin
            case (Funct_i)
                {7'b0000000, 3'b111}: ALUCtl_o = `ALU_CTL_AND;  // mul
                {7'b0000000, 3'b100}: ALUCtl_o = `ALU_CTL_XOR;  // xor
                {7'b0000000, 3'b001}: ALUCtl_o = `ALU_CTL_SLL;  // sll
                {7'b0000000, 3'b000}: ALUCtl_o = `ALU_CTL_ADD;  // add
                {7'b0100000, 3'b000}: ALUCtl_o = `ALU_CTL_SUB;  // sub
                {7'b0000001, 3'b000}: ALUCtl_o = `ALU_CTL_MUL;  // mul
            endcase
        end

        `ALU_OP_IMM: begin
            case (Funct_i[2:0])
                {3'b000}: ALUCtl_o = `ALU_CTL_ADD;  // addi
                {3'b101}: ALUCtl_o = `ALU_CTL_SRA;  // srai
                {3'b010}: ALUCtl_o = `ALU_CTL_ADD;   // lw
            endcase
        end

        `ALU_OP_STORE: begin
            case (Funct_i[2:0])
                {3'b010}: ALUCtl_o = `ALU_CTL_ADD; // sw
            endcase
        end

        `ALU_OP_BRANCH: begin // TODO: branch is needed here?
            case (Funct_i[2:0])
                {3'b000}: ALUCtl_o = ALUCtl_o; // beg
            endcase
        end
    endcase
end

endmodule