`include "Const.v"

module Forward (
    input [4:0] Rs1_EX_i,
    input [4:0] Rs2_EX_i,

    input [4:0] Rd_MEM_i,
    input [4:0] Rd_WB_i,

    input RegWrite_MEM_i,
    input RegWrite_WB_i,

    output reg [1:0] Forward_A,
    output reg [1:0] Forward_B
);

always @* begin
    // Default: Forward from register file
    Forward_A = `FW_REG;
    Forward_B = `FW_REG;

    // EX hazard
    if (RegWrite_MEM_i
            && Rd_MEM_i != 0
            && Rd_MEM_i == Rs1_EX_i) begin
        Forward_A = `FW_MEM;
    end
    if (RegWrite_MEM_i
            && Rd_MEM_i != 0
            && Rd_MEM_i == Rs2_EX_i) begin
        Forward_B = `FW_MEM;
    end

    // MEM hazard
    if (RegWrite_WB_i
            && Rd_WB_i != 0
            && Rd_WB_i == Rs1_EX_i
            && Forward_A != `FW_MEM) begin
        Forward_A = `FW_WB;
    end
    if (RegWrite_WB_i
            && Rd_WB_i != 0
            && Rd_WB_i == Rs2_EX_i
            && Forward_B != `FW_MEM) begin
        Forward_B = `FW_WB;
    end
end

endmodule