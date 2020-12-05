//*****************************************
//
//  Note:
//    1. NoOp
//    
//    2. TODO: branch除branch_o之外的signal要理????
//  
//  Update Date: 2020/12/4
//
//*****************************************
`include "Const.v"
module Control(input      [6:0] Opcode_i,
			         input            NoOp_i,
               output reg [1:0] ALUOp_o,
               output reg       ALUSrc_o,
               output reg       RegWrite_o,
               output reg       MemtoReg_o,
               output reg       MemRead_o,
               output reg       MemWrite_o,
               output reg       branch_o);

always @* begin
  case (NoOp_i)
    1'b0: begin
      case (Opcode_i)
          7'b0110011: begin //R-type arithmetic
          	ALUOp_o = `ALU_OP_REG;
          	ALUSrc_o = 1'b0;
          	RegWrite_o = 1'b1;
          	MemtoReg_o = 1'b0;
          	MemRead_o = 1'b0;
          	MemWrite_o = 1'b0;
          	branch_o = 1'b0;
          end
          
          7'b0010011: begin //I-type arithmetic
          	ALUOp_o = `ALU_OP_IMM;
          	ALUSrc_o = 1'b1;
          	RegWrite_o = 1'b1;
          	MemtoReg_o = 1'b0;
          	MemRead_o = 1'b0;
          	MemWrite_o = 1'b0;
          	branch_o = 1'b0;
          end 
          
          7'b0000011: begin // lw instruction
          	ALUOp_o = `ALU_OP_IMM;
          	ALUSrc_o = 1'b1;
            RegWrite_o = 1'b1;
            MemtoReg_o = 1'b1;
            MemRead_o = 1'b1;
            MemWrite_o = 1'b0;
            branch_o = 1'b0;
          end 
          
          7'b0100011: begin // S-type
            ALUOp_o = `ALU_OP_STORE;
            ALUSrc_o = 1'b1;
            RegWrite_o = 1'b0;
            //MemtoReg_o = 1'b1;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b1;
            branch_o = 1'b0;
          end
          
          7'b1100011: begin // SB-type  TODO: except for branch_o, others needed?
            ALUOp_o = `ALU_OP_BRANCH;
            ALUSrc_o = 1'b0;
            RegWrite_o = 1'b0;
            //MemtoReg_o = 1'b1;
            MemRead_o = 1'b0;
            MemWrite_o = 1'b0;
            branch_o = 1'b1;
          end 
      endcase
    end

    1'b1: begin// NoOp = 1  
      ALUSrc_o = 1'b0;
      RegWrite_o = 1'b0;
      MemRead_o = 1'b0;
      MemWrite_o = 1'b0;
      branch_o = 1'b0;
      //do nothing?
    end  
  endcase  
end

endmodule