`include "Const.v"

module Hazard_Detection_Unit(input       EX_MemRead_i,
                             input [4:0] EX_Rd_i,
                             input [6:0] ID_Opcode_i,
                             input [4:0] ID_Rs1_i,
                             input [4:0] ID_Rs2_i,
                             output reg  NoOp_o,
                             output reg  Stall_o,
                             output reg  PCWrite_o);

// For some instruction type, rs2 field may not be used
wire rs2_valid;

assign rs2_valid = ID_Opcode_i != `OPCODE_OP_IMM
                || ID_Opcode_i != `OPCODE_OP_IMM32
                || ID_Opcode_i != `OPCODE_LOAD
                || ID_Opcode_i != `OPCODE_LOAD_FP
                || ID_Opcode_i != `OPCODE_LUI
                || ID_Opcode_i != `OPCODE_JALR
                || ID_Opcode_i != `OPCODE_JAL;

always @* begin
    if (EX_MemRead_i 
            && (EX_Rd_i == ID_Rs1_i || (rs2_valid && EX_Rd_i == ID_Rs2_i))
            && EX_Rd_i != 0) begin 
        // load-use hazard
        // Note: In case an immediate instruction in in ID stage,
        // the rs2 is invalid, and false hazard may be unnecessarily detected
        NoOp_o = 1'b1;
        Stall_o = 1'b1;
        PCWrite_o = 1'b0;
    end
    
    else begin // Exception
        NoOp_o = 1'b0;
        Stall_o = 1'b0;
        PCWrite_o = 1'b1;
    end
end

endmodule