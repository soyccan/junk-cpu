module Instruction_Memory
(
    input   [31:0]      Addr_i,
    output  [31:0]      Instr_o
);


// Instruction memory
reg     [31:0]     memory  [0:255];

assign  Instr_o = memory[Addr_i>>2];  

endmodule
