// top of the tinyrisc CPU
`include "GlobalDefine.vh"
module tinyrisc_top (
    input                        clk,
    input                        rst_n,
    input  [`INST_WIDTH - 1 : 0] inst_in,
    output [`ADDR_WIDTH - 1 : 0] inst_addr_out,
    output                       inst_ce_out,

    input  [`DATA_WIDTH - 1 : 0] data_rd_in,
    output [`ADDR_WIDTH - 1 : 0] data_addr_out,
    output [`DATA_WIDTH - 1 : 0] data_wr_out,
    output                       data_we_out,
    output                       data_ce_out
);

  wire [  `ADDR_WIDTH - 1 : 0] pc;
  wire [  `ADDR_WIDTH - 1 : 0] pc_next;
  wire [`PC_SEL_WIDTH - 1 : 0] pc_sel;
  wire [`ALU_OP_WIDTH - 1 : 0] alu_op;
  wire                         alu_zero_preset;
  wire [  `DATA_WIDTH - 1 : 0] rs1_data;
  wire [  `DATA_WIDTH - 1 : 0] rs1_data_in;
  wire [  `DATA_WIDTH - 1 : 0] rs2_data;
  wire [  `DATA_WIDTH - 1 : 0] rd_data;
  wire [  `DATA_WIDTH - 1 : 0] imm;
  wire                         alu_src;
  wire [  `DATA_WIDTH - 1 : 0] ex_data_out;
  wire [  `DATA_WIDTH - 1 : 0] mem_data_out;
  wire                         mem_to_reg;


  assign inst_ce_out   = 1'b1;


  // IF

  assign inst_addr_out = pc;

  tinyrisc_IF IF_u (
      .clk   (clk),
      .rst_n (rst_n),
      .pc_in (pc_next),
      .pc_out(pc)
  );


  // ID

  tinyrisc_ID ID_u (
      .clk            (clk),
      .rst_n          (rst_n),
      .inst_in        (inst_in),
      .imm_out        (imm),
      .rs1_data_out   (rs1_data),
      .rs2_data_out   (rs2_data),
      .rd_data_in     (rd_data),
      .alu_op_out     (alu_op),
      .pc_sel_out     (pc_sel),
      .alu_src_out    (alu_src),
      .data_we_out    (data_we_out),
      .data_ce_out    (data_ce_out),
      .mem_to_reg_out (mem_to_reg),
      .alu_zero_preset(alu_zero_preset)
  );
  assign rs1_data_in =((inst_in & `U_TYPE_MASK) == `INST_AUIPC) ?  pc : rs1_data;
  // EX
  tinyrisc_EX EX_u (
      .clk            (clk),
      .rst_n          (rst_n),
      .rs1_data_in    (rs1_data_in),
      .rs2_data_in    (rs2_data),
      .imm_in         (imm),
      .alu_op_in      (alu_op),
      .alu_src_in     (alu_src),
      .alu_zero_preset(alu_zero_preset),
      .ex_data_out    (ex_data_out),
      .pc_sel_in      (pc_sel),
      .pc_in          (pc),
      .pc_out         (pc_next)
  );

  // MEM
  assign data_addr_out = ex_data_out[`ADDR_WIDTH - 1 : 0];
  assign data_wr_out   = rs2_data;
  assign mem_data_out  = data_rd_in;

  // WB
  assign rd_data       = mem_to_reg ? mem_data_out : ex_data_out;


endmodule
