module Equal(input signed [31:0] Rs1_i,
			 input signed [31:0] Rs2_i,
			 output reg          equal_o);
always @* begin
	if(Rs1_i == Rs2_i) begin
		equal_o = 1'b1;
	end
	else begin
		equal_o = 1'b0;
	end
end

endmodule