`include "Const.v"

module Control(input [6:0] Opcode_i,
               input NoOp_i,
               output reg [1:0] ALUOp_o,
               output reg ALUSrc_o,
               output reg RegWrite_o,
               output reg MemToReg_o,
               output reg MemRead_o,
               output reg MemWrite_o,
               output reg Branch_o);

always @* begin
    ALUOp_o = `ALU_OP_REG;
    ALUSrc_o = `ALU_SRC_REG;
    RegWrite_o = 1'b0;
    MemToReg_o = 1'b0;
    MemRead_o = 1'b0;
    MemWrite_o = 1'b0;
    Branch_o = 1'b0;

    if (NoOp_i) begin
        // Flush the pipeline stage if hazard is detected

        // ALUOp_o = `ALU_OP_REG;
        // ALUSrc_o = `ALU_SRC_REG;
        RegWrite_o = 1'b0;
        // MemToReg_o = 1'b0;
        MemRead_o = 1'b0;
        MemWrite_o = 1'b0;
        // Branch_o = 1'b0;
    end
    case (Opcode_i)
        `OPCODE_OP: begin
            ALUOp_o = `ALU_OP_REG;
            ALUSrc_o = `ALU_SRC_REG;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
        end

        `OPCODE_OP_IMM: begin
            ALUOp_o = `ALU_OP_IMM;
            ALUSrc_o = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b0;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
        end

        `OPCODE_LOAD: begin
            ALUOp_o = `ALU_OP_IMM;
            ALUSrc_o = `ALU_SRC_IMM;
            RegWrite_o = 1'b1;
            MemToReg_o = 1'b1;
            MemRead_o = 1'b1;
            MemWrite_o = 1'b0;
            Branch_o = 1'b0;
        end

        `OPCODE_STORE: begin
            ALUOp_o = `ALU_OP_LOAD_STORE;
            ALUSrc_o = `ALU_SRC_IMM;
            RegWrite_o = 1'b0;
            // MemToReg_o = 1'bx;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b1;
            Branch_o = 1'b0;
        end

        `OPCODE_BRANCH: begin
            // ALUOp_o = `ALU_OP_BRANCH;
            // ALUSrc_o = `ALU_SRC_REG;
            RegWrite_o = 1'b0;
            // MemToReg_o = 1'bx;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            Branch_o = 1'b1;
        end
    endcase
end

endmodule
