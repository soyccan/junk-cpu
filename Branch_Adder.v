module Branch_Adder(input signed		[31:0]	pc_i,
					input signed		[31:0]	immed_i,
					output reg signed	[31:0]	branch_pc_o);

always @* begin
	branch_pc_o = pc_i + immed_i;
end

endmodule