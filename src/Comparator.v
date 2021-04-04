`include "Const.v"

module Comparator(input [31:0] Rs1_i,
                  input [31:0] Rs2_i,
                  input [2:0] Funct3_i,
                  output Res_o);

assign Res_o = Funct3_i == `FUNCT3_EQ  ? (Rs1_i == Rs2_i) :
               Funct3_i == `FUNCT3_NE  ? (Rs1_i != Rs2_i) :
               Funct3_i == `FUNCT3_LT  ? ($signed(Rs1_i) < $signed(Rs2_i))  :
               Funct3_i == `FUNCT3_GE  ? ($signed(Rs1_i) >= $signed(Rs2_i)) :
               Funct3_i == `FUNCT3_LTU ? (Rs1_i < Rs2_i)  :
               Funct3_i == `FUNCT3_GEU ? (Rs1_i >= Rs2_i) :
               1'bz;

endmodule
