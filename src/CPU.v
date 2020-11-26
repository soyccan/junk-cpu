module CPU(input clk_i,
           input rst_i,
           input start_i);

wire [31:0] inst;

wire [31:0] pc_i;
wire [31:0] pc_o;

wire [31:0] rs1_o;
wire [31:0] rs2_o;

wire [31:0] alu_op2_i;
wire [31:0] imm_val;
wire [31:0] alu_o;

wire ALUSrc;
wire RegWrite;

wire [1:0] ALUOp;
wire [3:0] ALUCtl;

assign pc_i = pc_o + 4;

PC PC(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .start_i(start_i),
    .pc_i(pc_i),
    .pc_o(pc_o)
);

Instruction_Memory Instruction_Memory(
    .addr_i(pc_o),
    .instr_o(inst)
);

Control Control(
    .Opcode_i(inst[6:0]),
    .ALUOp_o(ALUOp),
    .ALUSrc_o(ALUSrc),
    .RegWrite_o(RegWrite)
);

Registers Registers(
    .clk_i(clk_i),
    .RS1addr_i(inst[19:15]),
    .RS2addr_i(inst[24:20]),
    .RDaddr_i(inst[11:7]),
    .RDdata_i(alu_o),
    .RegWrite_i(RegWrite),
    .RS1data_o(rs1_o),
    .RS2data_o(rs2_o)
);

ALU_Control ALU_Control(
    .ALUOp_i(ALUOp),
    .Funct_i({inst[31:25], inst[14:12]}),
    .ALUCtl_o(ALUCtl)
);

Sign_Extend Sign_Extend(
    .Addr12_i(inst[31:20]),
    .Addr32_o(imm_val)
);

assign alu_op2_i = ALUSrc ? imm_val : rs2_o;

ALU ALU(
    .ALUCtl_i(ALUCtl),
    .Op1_i(rs1_o),
    .Op2_i(alu_op2_i),
    .Res_o(alu_o),
    .Zero_o()
);

endmodule
