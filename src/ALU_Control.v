`include "Const.v"

module ALU_Control(input [1:0] ALUOp_i,
                   input [9:0] Funct_i,
                   output reg [3:0] ALUCtl_o);

wire [2:0] funct3;
wire [6:0] funct7;

assign {funct7, funct3} = Funct_i;

always @* begin  // latch-free design
    ALUCtl_o = `ALU_CTL_ADD;

    case (ALUOp_i)
        `ALU_OP_REG: begin
            if (funct7[0]) begin
                // RV32M extension
                case (funct3)
                    3'b000: ALUCtl_o = `ALU_CTL_MUL;  // mul
                endcase
            end
            else begin
                case (funct3)
                    3'b000: begin
                        if (funct7[5]) 
                            ALUCtl_o = `ALU_CTL_SUB;  // sub
                        else
                            ALUCtl_o = `ALU_CTL_ADD;  // add
                    end
                    3'b001: ALUCtl_o = `ALU_CTL_SLL;  // sll
                    3'b100: ALUCtl_o = `ALU_CTL_XOR;  // xor
                    3'b111: ALUCtl_o = `ALU_CTL_AND;  // and
                endcase
            end
        end

        `ALU_OP_IMM: begin
            case (funct3)
                3'b000: ALUCtl_o = `ALU_CTL_ADD;  // addi
                3'b101: begin
                    if (funct7[5])
                        ALUCtl_o = `ALU_CTL_SRA;  // srai
                    else
                        ALUCtl_o = `ALU_CTL_SRL;  // srli
                end
            endcase
        end

        `ALU_OP_LOAD_STORE: begin
            ALUCtl_o = `ALU_CTL_ADD;  // lw, sw
        end

        `ALU_OP_BRANCH: begin
            if (funct3 == 3'b110 || funct3 == 3'b111)
                ALUCtl_o = `ALU_CTL_SUBU;  // bltu, bgeu
            else
                ALUCtl_o = `ALU_CTL_SUB;  // beq, bne, blt, bge
        end
    endcase
end

endmodule