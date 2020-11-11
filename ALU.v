`include "Const.v"
module ALU(input      [3:0]  ALUCtl_i,
           input      [31:0] Op1_i,
           input      [31:0] Op2_i,
           output reg [31:0] Res_o,
           output            Zero_o);
// TODO Output should be wire or reg?

wire [4:0] shft_amt = Op2_i[4:0];  // shift amount is only 5 bits

always @* begin
    case (ALUCtl_i)
        // TODO: should use non-blocking here?
        `ALU_CTL_AND:  Res_o = Op1_i & Op2_i;
        `ALU_CTL_OR:   Res_o = Op1_i | Op2_i;
        `ALU_CTL_XOR:  Res_o = Op1_i ^ Op2_i;
        `ALU_CTL_NAND: Res_o = ~(Op1_i & Op2_i);
        `ALU_CTL_NOR:  Res_o = ~(Op1_i | Op2_i);
        `ALU_CTL_ADD:  Res_o = Op1_i + Op2_i;
        `ALU_CTL_SUB:  Res_o = Op1_i - Op2_i;
        `ALU_CTL_MUL:  Res_o = Op1_i * Op2_i;
        `ALU_CTL_DIV:  Res_o = Op1_i / Op2_i;
        `ALU_CTL_SLL:  Res_o = Op1_i << shft_amt;
        `ALU_CTL_SRL:  Res_o = Op1_i >> shft_amt;
        `ALU_CTL_SRA:  Res_o = Op1_i >>> shft_amt;
        // default: Res_o = 32'hzzzzzzzz;
    endcase
end

assign Zero_o = Res_o == 0;

endmodule
