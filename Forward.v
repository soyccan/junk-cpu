`include "Const.v"
module Forward (
    input [31:0] EX_rs1,
    input [31:0] EX_rs2,

    input [31:0] MEM_rd,
    input [31:0] WB_rd,

    input MEM_regwrite,
    input WB_regwrite,

    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B
);

always @* begin
    // Default: Forward from register file
    Forward_A = `Reg_src;
    Forward_B = `Reg_src;

    // EX hazard
    if(MEM_regwrite and MEM_rd != 0 and MEM_rd == EX_rs1) begin
        Forward_A = `EX_src;
    end
    if(MEM_regwrite and MEM_rd != 0 and MEM_rd == EX_rs2) begin
        Forward_B = `EX_src;
    end

    // MEM hazard
    if(WB_regwrite and WB_rd != 0 and WB_rd == EX_rs1 and Forward_A != `EX_src) begin
        Forward_A = `MEM_src;
    end
    if(WB_regwrite and WB_rd != 0 and WB_rd == EX_rs2 and Forward_A != `EX_src) begin
        Forward_B = `MEM_src;
    end
end

endmodule