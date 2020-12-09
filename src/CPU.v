`include "Const.v"
module CPU(input clk_i,
           input rst_i,
           input start_i);

wire clk = clk_i;
wire rst = rst_i;
wire start = start_i;


wire [31:0] pc_IF;
wire [31:0] pc_next_IF;
wire [31:0] inst_IF;


wire NoOp_ID;
wire PCWrite_ID;
wire Stall_ID;
wire Flush_ID;
wire Branch_ID;
wire RegWrite_ID;
wire MemToReg_ID;
wire MemRead_ID;
wire MemWrite_ID;
wire ALUSrc_ID;
wire [1:0] ALUOp_ID;

reg [31:0] inst_ID;
reg [31:0] pc_ID;
wire [6:0] opcode_ID;
wire [9:0] funct_ID;
wire [4:0] rd_ID;
wire [4:0] rs1_ID;
wire [4:0] rs2_ID;
wire [31:0] rs1_data_ID;
wire [31:0] rs2_data_ID;
wire [31:0] imm_ID;
wire [31:0] branch_target_ID;



reg RegWrite_EX;
reg MemToReg_EX;
reg MemRead_EX;
reg MemWrite_EX;
reg ALUSrc_EX;
reg [1:0] ALUOp_EX;

wire [1:0] Forward_A;
wire [1:0] Forward_B;

reg [9:0] funct_EX;
reg [4:0] rs1_EX;
reg [4:0] rs2_EX;
reg [4:0] rd_EX;
reg [31:0] rs1_data_EX;
reg [31:0] rs2_data_EX;
reg [31:0] imm_EX;

wire [31:0] alu_op1_EX;
wire [31:0] alu_op2_EX;
wire [31:0] rs2_fwd_EX;
wire [31:0] alu_res_EX;
wire [3:0] alu_ctl_EX;


reg RegWrite_MEM;
reg MemToReg_MEM;
reg MemRead_MEM;
reg MemWrite_MEM;

reg [4:0] rd_MEM;

wire [31:0] data_loaded_MEM;
reg [31:0] alu_res_MEM;
reg [31:0] data_stored_MEM;


reg RegWrite_WB;
reg MemToReg_WB;

reg [4:0] rd_WB;

wire [31:0] write_back_data_WB;
reg [31:0] data_loaded_WB;
reg [31:0] alu_res_WB;



////////////////
/// IF Stage ///
////////////////
assign pc_next_IF = Flush_ID ? branch_target_ID : (pc_IF + 4);

PC PC(
    .clk_i(clk),
    .rst_i(rst),
    .start_i(start),
    .PCWrite_i(PCWrite_ID),
    .pc_i(pc_next_IF),
    .pc_o(pc_IF)
);

Instruction_Memory Instruction_Memory(
    .addr_i(pc_IF),
    .instr_o(inst_IF)
);


////////////////
/// ID Stage ///
////////////////
assign Flush_ID = Branch_ID & (rs1_data_ID == rs2_data_ID);
assign branch_target_ID = (imm_ID << 1) + pc_ID;

// TODO: Valid instructions start with 11
// An empty entity in instruction memory is replaced with no-op
// assign opcode_ID = inst_ID[1:0] == 2'b11 ? inst_ID[6:0] : 7'h13;
assign opcode_ID = inst_ID[6:0];

assign funct_ID = {inst_ID[31:25], inst_ID[14:12]};
assign rd_ID = inst_ID[11:7];
assign rs1_ID = inst_ID[19:15];
assign rs2_ID = inst_ID[24:20];

// IF/ID Register
always @(posedge clk) begin
    if (rst) begin
        pc_ID   <= 32'h0;
        inst_ID <= 32'h13; // nop
    end
    else if (Stall_ID) begin
        pc_ID   <= pc_ID;
        inst_ID <= inst_ID;
    end
    else if (Flush_ID) begin
        pc_ID   <= 32'bx;
        inst_ID <= 32'h13; // nop
    end
    else begin
        pc_ID   <= pc_IF;
        inst_ID <= inst_IF;
    end
end

Control Control(
    .Opcode_i(opcode_ID),
    .NoOp_i(NoOp_ID),
    .RegWrite_o(RegWrite_ID),
    .MemtoReg_o(MemToReg_ID),
    .MemRead_o(MemRead_ID),
    .MemWrite_o(MemWrite_ID),
    .ALUOp_o(ALUOp_ID),
    .ALUSrc_o(ALUSrc_ID),
    .branch_o(Branch_ID)
);

Hazard_Detection_Unit Hazard_Detection_Unit(
    .MemRead_i(MemRead_EX),
    .Rd_i(rd_EX),
    .Opcode_i(opcode_ID),
    .Rs1_i(rs1_ID),
    .Rs2_i(rs2_ID),
    .NoOp_o(NoOp_ID),
    .Stall_o(Stall_ID),
    .PCWrite_o(PCWrite_ID)
);

Forward Forward(
    .EX_rs1(rs1_EX),
    .EX_rs2(rs2_EX),
    .MEM_rd(rd_MEM),
    .WB_rd(rd_WB),
    .MEM_regwrite(RegWrite_MEM),
    .WB_regwrite(RegWrite_WB),
    .Forward_A(Forward_A),
    .Forward_B(Forward_B)
);


Imm_Gen Imm_Gen(
    .Inst_i(inst_ID),
    .Imm_o(imm_ID)
);

Registers Registers(
    .clk_i(clk),
    .RegWrite_i(RegWrite_WB),
    .RDaddr_i(rd_WB),
    .RS1addr_i(rs1_ID),
    .RS2addr_i(rs2_ID),
    .RDdata_i(write_back_data_WB),
    .RS1data_o(rs1_data_ID),
    .RS2data_o(rs2_data_ID)
);



////////////////
/// EX Stage ///
////////////////

// ID/EX Register
always @(posedge clk) begin
    if (rst) begin
        RegWrite_EX <= 0;
        MemToReg_EX <= 0;
        MemRead_EX  <= 0;
        MemWrite_EX <= 0;
        ALUOp_EX    <= 0;
        ALUSrc_EX   <= 0;
        rs1_data_EX <= 0;
        rs2_data_EX <= 0;
        imm_EX      <= 0;
        funct_EX    <= 0;
        rs1_EX      <= 0;
        rs2_EX      <= 0;
        rd_EX       <= 0;
    end
    else begin
        RegWrite_EX <= RegWrite_ID;
        MemToReg_EX <= MemToReg_ID;
        MemRead_EX  <= MemRead_ID;
        MemWrite_EX <= MemWrite_ID;
        ALUOp_EX    <= ALUOp_ID;
        ALUSrc_EX   <= ALUSrc_ID;
        rs1_data_EX <= rs1_data_ID;
        rs2_data_EX <= rs2_data_ID;
        imm_EX      <= imm_ID;
        funct_EX    <= funct_ID;
        rs1_EX      <= rs1_ID;
        rs2_EX      <= rs2_ID;
        rd_EX       <= rd_ID;
    end
end

ALU_Control ALU_Control(
    .ALUOp_i(ALUOp_EX),
    .Funct_i(funct_EX),
    .ALUCtl_o(alu_ctl_EX)
);

assign alu_op1_EX = Forward_A == `FW_Reg_src ? rs1_data_EX :
                    Forward_A == `FW_MEM_src ? write_back_data_WB :
                    Forward_A == `FW_EX_src  ? alu_res_MEM : 32'hxxxxxxxx;

assign alu_op2_EX = ALUSrc_EX ? imm_EX : rs2_fwd_EX;

assign rs2_fwd_EX = Forward_B == `FW_Reg_src ? rs2_data_EX :
                    Forward_B == `FW_MEM_src ? write_back_data_WB :
                    Forward_B == `FW_EX_src  ? alu_res_MEM : 32'hxxxxxxxx;

ALU ALU(
    .ALUCtl_i(alu_ctl_EX),
    .Op1_i(alu_op1_EX),
    .Op2_i(alu_op2_EX),
    .Res_o(alu_res_EX)
);



/////////////////
/// MEM Stage ///
/////////////////

// EX/MEM Register
always @(posedge clk) begin
    if (rst) begin
        RegWrite_MEM    <= 0;
        MemToReg_MEM    <= 0;
        MemRead_MEM     <= 0;
        MemWrite_MEM    <= 0;
        alu_res_MEM     <= 0;
        data_stored_MEM <= 0;
        rd_MEM          <= 0;
    end
    else begin
        RegWrite_MEM    <= RegWrite_EX;
        MemToReg_MEM    <= MemToReg_EX;
        MemRead_MEM     <= MemRead_EX;
        MemWrite_MEM    <= MemWrite_EX;
        alu_res_MEM     <= alu_res_EX;
        data_stored_MEM <= rs2_fwd_EX;
        rd_MEM          <= rd_EX;
    end
end

Data_Memory Data_Memory(
    .clk_i(clk),
    .MemRead_i(MemRead_MEM),
    .MemWrite_i(MemWrite_MEM),
    .addr_i(alu_res_MEM),
    .data_i(data_stored_MEM),
    .data_o(data_loaded_MEM)
);



///////////////
// WB Stage ///
///////////////

// MEM/WB Register
always @(posedge clk) begin
    if (rst) begin
        RegWrite_WB    <= 0;
        MemToReg_WB    <= 0;
        alu_res_WB     <= 0;
        data_loaded_WB <= 0;
        rd_WB          <= 0;
    end
    else begin
        RegWrite_WB    <= RegWrite_MEM;
        MemToReg_WB    <= MemToReg_MEM;
        alu_res_WB     <= alu_res_MEM;
        data_loaded_WB <= data_loaded_MEM;
        rd_WB          <= rd_MEM;
    end
end

assign write_back_data_WB = MemToReg_WB ? data_loaded_WB : alu_res_WB;


endmodule
