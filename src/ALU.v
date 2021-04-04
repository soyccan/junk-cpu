`include "Const.v"

module ALU(input [3:0] ALUCtl_i,
           input [31:0] Op1_i,
           input [31:0] Op2_i,
           output [31:0] Res_o,
           output Zero_o,
           output Overflow_o);

// shift amount is only 6 bits
wire [5:0] shft_amt;

reg [64:0] result;

assign shft_amt = Op2_i[5:0];

assign Zero_o = (Res_o == 32'b0);

assign {Overflow_o, Res_o} = result;

always @* begin
    case (ALUCtl_i)
        `ALU_CTL_AND:  result = Op1_i & Op2_i;
        `ALU_CTL_OR:   result = Op1_i | Op2_i;
        `ALU_CTL_XOR:  result = Op1_i ^ Op2_i;
        `ALU_CTL_NAND: result = ~(Op1_i & Op2_i);
        `ALU_CTL_NOR:  result = ~(Op1_i | Op2_i);
        `ALU_CTL_ADD:  result = $signed(Op1_i) + $signed(Op2_i);
        `ALU_CTL_SUB:  result = $signed(Op1_i) - $signed(Op2_i);
        `ALU_CTL_ADDU: result = Op1_i + Op2_i;
        `ALU_CTL_SUBU: result = Op1_i - Op2_i;
        `ALU_CTL_MUL:  result = $signed(Op1_i) * $signed(Op2_i);
        `ALU_CTL_DIV:  result = $signed(Op1_i) / $signed(Op2_i);
        `ALU_CTL_SLL:  result = Op1_i << shft_amt;
        `ALU_CTL_SRL:  result = Op1_i >> shft_amt;
        `ALU_CTL_SRA:  result = $signed(Op1_i) >>> shft_amt;
    endcase
end

endmodule
