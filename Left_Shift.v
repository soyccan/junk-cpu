module Left_Shift(input signed		[31:0]	immed_i,
				  output reg signed	[31:0]	shift_o);

always @* begin
	shift_o = immed_i << 1;
end

endmodule