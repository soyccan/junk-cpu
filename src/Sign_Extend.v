module Sign_Extend(input  [11:0] Addr12_i,
                   output [31:0] Addr32_o);

assign Addr32_o = {{20{Addr12_i[11]}}, Addr12_i};

endmodule
