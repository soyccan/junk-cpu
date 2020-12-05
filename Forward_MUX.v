`include "Const.v"
module Forward_MUX
(
    input reg [31:0] Reg_src_i,
    input reg [31:0] EX_src_i,
    input reg [31:0] MEM_src_i,
    input reg [1:0] select_i,
    output reg [31:0] data_o
);

always @(Reg_src_i or EX_src_i or MEM_src_i or select_i) begin
    case (select_i)
        `Reg_src: data_o = Reg_src_i;
        `EX_src: data_o = EX_src_i;
        `MEM_src: data_o = MEM_src_i;
    endcase
end

endmodule