`include "Const.v"

module CPU(input  Clk_i,
           input  Rst_i,
           input  Start_i,
           input  [255:0] mem_data_i,
           input  mem_ack_i,
           output [255:0] mem_data_o,
           output [31:0]  mem_addr_o,
           output mem_enable_o,
           output mem_write_o);

wire Stall_hazard;
wire Stall_dcache;
wire Stall = Stall_hazard || Stall_dcache;


wire [31:0] IF_PC;
wire [31:0] IF_PCNext;
wire [31:0] IF_Inst;


wire ID_NoOp;
wire ID_PCWrite;
wire ID_Flush;
wire ID_Branch;
wire ID_RegWrite;
wire ID_MemToReg;
wire ID_MemRead;
wire ID_MemWrite;
wire ID_ALUSrc;
wire [1:0] ID_ALUOp;

reg [31:0] ID_Inst;
reg [31:0] ID_PC;
wire [6:0] ID_OpCode;
wire [9:0] ID_Funct;
wire [4:0] ID_Rd;
wire [4:0] ID_Rs1;
wire [4:0] ID_Rs2;
wire [31:0] ID_Rs1Data;
wire [31:0] ID_Rs2Data;
wire [31:0] ID_Imm;
wire [31:0] ID_BranchTarget;
wire ID_BranchCond;  // whether branch condition holds



reg EX_RegWrite;
reg EX_MemToReg;
reg EX_MemRead;
reg EX_MemWrite;
reg EX_ALUSrc;
reg [1:0] EX_ALUOp;

wire [1:0] Forward_A;
wire [1:0] Forward_B;

reg [9:0] EX_Funct;
reg [4:0] EX_Rs1;
reg [4:0] EX_Rs2;
reg [4:0] EX_Rd;
reg [31:0] EX_Rs1Data;
reg [31:0] EX_Rs2Data;
reg [31:0] EX_Imm;

wire [31:0] EX_ALUOp1;
wire [31:0] EX_ALUOp2;
wire [31:0] EX_Rs2_fwd;
wire [31:0] EX_ALURes;
wire [3:0] EX_ALUCtl;


reg MEM_RegWrite;
reg MEM_MemToReg;
reg MEM_MemRead;
reg MEM_MemWrite;

reg [4:0] MEM_Rd;

wire [31:0] MEM_DataFromMem;
reg [31:0] MEM_ALURes;
reg [31:0] MEM_DataToMem;


reg WB_RegWrite;
reg WB_MemToReg;

reg [4:0] WB_Rd;

wire [31:0] WB_WriteBackData;
reg [31:0] WB_DataFromMem;
reg [31:0] WB_ALURes;



////////////////
/// IF Stage ///
////////////////
assign IF_PCNext = ID_Flush ? ID_BranchTarget : (IF_PC + 4);

PC PC(
    .Clk_i(Clk_i),
    .Rst_i(Rst_i),
    .Start_i(Start_i),
    .PCWrite_i(ID_PCWrite),
    .stall_i(Stall),
    .pc_i(IF_PCNext),
    .pc_o(IF_PC)
);

Instruction_Memory Instruction_Memory(
    .addr_i(IF_PC),
    .instr_o(IF_Inst)
);


////////////////
/// ID Stage ///
////////////////
Comparator Comparator(
    .Rs1_i(ID_Rs1Data),
    .Rs2_i(ID_Rs2Data),
    .Funct3_i(ID_Funct[2:0]),
    .Res_o(ID_BranchCond)
);

assign ID_Flush = ID_Branch && ID_BranchCond;
assign ID_BranchTarget = ID_Imm + ID_PC;

// TODO: Valid instructions start with 11
// An empty entity in instruction memory is replaced with no-op
// assign ID_OpCode = ID_Inst[1:0] == 2'b11 ? ID_Inst[6:0] : 7'h13;
assign ID_OpCode = ID_Inst[6:0];

assign ID_Funct = {ID_Inst[31:25], ID_Inst[14:12]};
assign ID_Rd = ID_Inst[11:7];
assign ID_Rs1 = ID_Inst[19:15];
assign ID_Rs2 = ID_Inst[24:20];

// IF/ID Register
always @(posedge Clk_i) begin
    if (Rst_i) begin
        ID_PC   <= 32'h0;
        ID_Inst <= 32'h13; // nop
    end
    else if (Stall) begin
        ID_PC   <= ID_PC;
        ID_Inst <= ID_Inst;
    end
    else if (ID_Flush) begin
        ID_PC   <= 32'h0;
        ID_Inst <= 32'h13; // nop
    end
    else begin
        ID_PC   <= IF_PC;
        ID_Inst <= IF_Inst;
    end
end

Control Control(
    .OpCode_i(ID_OpCode),
    // .NoOp_i(ID_NoOp),
    .RegWrite_o(ID_RegWrite),
    .MemToReg_o(ID_MemToReg),
    .MemRead_o(ID_MemRead),
    .MemWrite_o(ID_MemWrite),
    .ALUOp_o(ID_ALUOp),
    .ALUSrc_o(ID_ALUSrc),
    .Branch_o(ID_Branch)
);

HazaRd_Detection_Unit HazaRd_Detection_Unit(
    .MemRead_i(EX_MemRead),
    .Rd_i(EX_Rd),
    .OpCode_i(ID_OpCode),
    .Rs1_i(ID_Rs1),
    .Rs2_i(ID_Rs2),
    // .NoOp_o(ID_NoOp),
    .Stall_o(Stall_hazard),
    .PCWrite_o(ID_PCWrite)
);

Forward Forward(
    .EX_Rs1_i(EX_Rs1),
    .EX_Rs2_i(EX_Rs2),
    .MEM_Rd_i(MEM_Rd),
    .WB_Rd_i(WB_Rd),
    .MEM_RegWrite_i(MEM_RegWrite),
    .WB_RegWrite_i(WB_RegWrite),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B)
);


Imm_Gen Imm_Gen(
    .Inst_i(ID_Inst),
    .Imm_o(ID_Imm)
);

Registers Registers(
    .Clk_i(Clk_i),
    .RegWrite_i(WB_RegWrite),
    .Rdaddr_i(WB_Rd),
    .Rs1addr_i(ID_Rs1),
    .Rs2addr_i(ID_Rs2),
    .Rddata_i(WB_WriteBackData),
    .Rs1data_o(ID_Rs1Data),
    .Rs2data_o(ID_Rs2Data)
);



////////////////
/// EX Stage ///
////////////////

// ID/EX Register
always @(posedge Clk_i) begin
    if (Rst_i) begin
        EX_RegWrite <= 0;
        EX_MemToReg <= 0;
        EX_MemRead  <= 0;
        EX_MemWrite <= 0;
        EX_ALUOp    <= 0;
        EX_ALUSrc   <= 0;
        EX_Rs1Data <= 0;
        EX_Rs2Data <= 0;
        EX_Imm      <= 0;
        EX_Funct    <= 0;
        EX_Rs1      <= 0;
        EX_Rs2      <= 0;
        EX_Rd       <= 0;
    end
    else if (!Stall_dcache) begin
        EX_RegWrite <= ID_RegWrite;
        EX_MemToReg <= ID_MemToReg;
        EX_MemRead  <= ID_MemRead;
        EX_MemWrite <= ID_MemWrite;
        EX_ALUOp    <= ID_ALUOp;
        EX_ALUSrc   <= ID_ALUSrc;
        EX_Rs1Data <= ID_Rs1Data;
        EX_Rs2Data <= ID_Rs2Data;
        EX_Imm      <= ID_Imm;
        EX_Funct    <= ID_Funct;
        EX_Rs1      <= ID_Rs1;
        EX_Rs2      <= ID_Rs2;
        EX_Rd       <= ID_Rd;
    end
end

ALU_Control ALU_Control(
    .ALUOp_i(EX_ALUOp),
    .Funct_i(EX_Funct),
    .ALUCtl_o(EX_ALUCtl)
);

assign EX_ALUOp1 = Forward_A == `FW_REG ? EX_Rs1Data :
                    Forward_A == `FW_WB  ? WB_WriteBackData :
                    Forward_A == `FW_MEM ? MEM_ALURes : 32'hz;

assign EX_ALUOp2 = EX_ALUSrc ? EX_Imm : EX_Rs2_fwd;

assign EX_Rs2_fwd = Forward_B == `FW_REG ? EX_Rs2Data :
                    Forward_B == `FW_WB  ? WB_WriteBackData :
                    Forward_B == `FW_MEM ? MEM_ALURes : 32'hz;

ALU ALU(
    .ALUCtl_i(EX_ALUCtl),
    .Op1_i(EX_ALUOp1),
    .Op2_i(EX_ALUOp2),
    .Res_o(EX_ALURes)
);



/////////////////
/// MEM Stage ///
/////////////////

// EX/MEM Register
always @(posedge Clk_i) begin
    if (Rst_i) begin
        MEM_RegWrite    <= 0;
        MEM_MemToReg    <= 0;
        MEM_MemRead     <= 0;
        MEM_MemWrite    <= 0;
        MEM_ALURes     <= 0;
        MEM_DataToMem <= 0;
        MEM_Rd          <= 0;
    end
    else if (!Stall_dcache) begin
        MEM_RegWrite    <= EX_RegWrite;
        MEM_MemToReg    <= EX_MemToReg;
        MEM_MemRead     <= EX_MemRead;
        MEM_MemWrite    <= EX_MemWrite;
        MEM_ALURes     <= EX_ALURes;
        MEM_DataToMem <= EX_Rs2_fwd;
        MEM_Rd          <= EX_Rd;
    end
end

dcache_controller dcache(
    .Clk_i(Clk_i),
    .Rst_i(Rst_i),

    .mem_data_i(mem_data_i),
    .mem_ack_i(mem_ack_i),
    .mem_data_o(mem_data_o),
    .mem_addr_o(mem_addr_o),
    .mem_enable_o(mem_enable_o),
    .mem_write_o(mem_write_o),

    .cpu_MemRead_i(MEM_MemRead),
    .cpu_MemWrite_i(MEM_MemWrite),
    .cpu_addr_i(MEM_ALURes),
    .cpu_data_i(MEM_DataToMem),
    .cpu_data_o(MEM_DataFromMem),
    .cpu_stall_o(Stall_dcache)
);



///////////////
// WB Stage ///
///////////////

// MEM/WB Register
always @(posedge Clk_i) begin
    if (Rst_i) begin
        WB_RegWrite    <= 0;
        WB_MemToReg    <= 0;
        WB_ALURes     <= 0;
        WB_DataFromMem <= 0;
        WB_Rd          <= 0;
    end
    else if (!Stall_dcache) begin
        WB_RegWrite    <= MEM_RegWrite;
        WB_MemToReg    <= MEM_MemToReg;
        WB_ALURes     <= MEM_ALURes;
        WB_DataFromMem <= MEM_DataFromMem;
        WB_Rd          <= MEM_Rd;
    end
end

assign WB_WriteBackData = WB_MemToReg ? WB_DataFromMem : WB_ALURes;


endmodule
