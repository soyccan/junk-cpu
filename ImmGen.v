module ImmGen (
    input [11:0] data_i,
    output signed [31:0] data_o
);

assign data_o = {{20{data_i[11]}}, data_i};

endmodule