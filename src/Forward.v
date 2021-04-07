`include "Const.v"

module Forward (
    input [4:0] EX_Rs1_i,
    input [4:0] EX_Rs2_i,

    input [4:0] MEM_Rd_i,
    input MEM_RegWrite_i,

    input [4:0] WB_Rd_i,
    input WB_RegWrite_i,

    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B
);

always @* begin
    // Default: Forward from register file
    Forward_A = `FW_REG;
    Forward_B = `FW_REG;

    // Forward from MEM stage
    if (MEM_RegWrite_i
            && MEM_Rd_i != 0
            && MEM_Rd_i == EX_Rs1_i) begin
        Forward_A = `FW_MEM;
    end
    if (MEM_RegWrite_i
            && MEM_Rd_i != 0
            && MEM_Rd_i == EX_Rs2_i) begin
        Forward_B = `FW_MEM;
    end

    // Forward from WB stage, provided that not forwarding from MEM stage
    if (WB_RegWrite_i
            && WB_Rd_i != 0
            && WB_Rd_i == EX_Rs1_i
            && Forward_A != `FW_MEM) begin
        Forward_A = `FW_WB;
    end
    if (WB_RegWrite_i
            && WB_Rd_i != 0
            && WB_Rd_i == EX_Rs2_i
            && Forward_B != `FW_MEM) begin
        Forward_B = `FW_WB;
    end
end

endmodule