`include "Const.v"
module Forward (
    input [4:0] EX_rs1,
    input [4:0] EX_rs2,

    input [4:0] MEM_rd,
    input [4:0] WB_rd,

    input MEM_regwrite,
    input WB_regwrite,

    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B
);

always @* begin
    // Default: Forward from register file
    Forward_A = `FW_Reg_src;
    Forward_B = `FW_Reg_src;

    // EX hazard
    if(MEM_regwrite && MEM_rd != 0 && MEM_rd == EX_rs1) begin
        Forward_A = `FW_EX_src;
    end
    if(MEM_regwrite && MEM_rd != 0 && MEM_rd == EX_rs2) begin
        Forward_B = `FW_EX_src;
    end

    // MEM hazard
    if(WB_regwrite && WB_rd != 0 && WB_rd == EX_rs1 && Forward_A != `FW_EX_src) begin
        Forward_A = `FW_MEM_src;
    end
    if(WB_regwrite && WB_rd != 0 && WB_rd == EX_rs2 && Forward_B != `FW_EX_src) begin
        Forward_B = `FW_MEM_src;
    end
end

endmodule