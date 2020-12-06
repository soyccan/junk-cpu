module And_Gate(input      branch_i,
				input      equal_i,
				output reg flush_o);

always @* begin
	flush_o = branch_i & equal_i;
end

endmodule