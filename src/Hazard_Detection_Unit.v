//*****************************************
//
//	Note:
//		1. 裡面的1代表yes的意思，0代表no，例如 Stall_o = 1 代表Stall
//		
//		2. 已處理lw的control Hazard
//		
//		3. TODO: flush????
//	
//	Update Date: 2020/12/4
//
//*****************************************

`include "Const.v"
module Hazard_Detection_Unit(input             MemRead_i,
							 input	     [4:0] Rd_i,
							 input		 [4:0] Rs1_i,
							 input		 [4:0] Rs2_i,
							 output reg        NoOp_o,
							 output reg        Stall_o,
							 output reg        PCWrite_o);
always @* begin
	if((MemRead_i == 1'b1) && ((Rd_i == Rs1_i) || (Rd_i == Rs2_i))) begin // lw Control Hazard
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