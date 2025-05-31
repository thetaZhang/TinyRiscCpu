// instruction decode
`include "GlobalDefine.vh"
module tinyrisc_ID (
    input clk,
    input rst_n,

    input [`INST_WIDTH - 1 : 0] inst_in,
    input [`ADDR_WIDTH - 1 : 0] pc_in,
    output [`ADDR_WIDTH - 1 : 0] pc_next_out,
    output                       is_branch_out,

    output [    `DATA_WIDTH - 1 : 0] imm_out,
    output [    `DATA_WIDTH - 1 : 0] rs1_data_out,
    output [    `DATA_WIDTH - 1 : 0] rs2_data_out,
    output [`REG_ADDR_WIDTH - 1 : 0] rs1_addr_out,
    output [`REG_ADDR_WIDTH - 1 : 0] rs2_addr_out,
    input  [    `DATA_WIDTH - 1 : 0] rd_data_in,
    input  [`REG_ADDR_WIDTH - 1 : 0] rd_addr_in,
    input                            reg_we_in,
    output                           reg_we_out,

    output [  `ALU_OP_WIDTH - 1 : 0] alu_op_out,
    //output [  `PC_SEL_WIDTH - 1 : 0] pc_sel_out,
    output [ `ALU_SRC_WIDTH - 1 : 0] alu_src_out,
    output                           data_we_out,
    output                           data_ce_out,
    output [`MEM_MODE_WIDTH - 1 : 0] mem_width_out,
    output                           mem_to_reg_out,
    //output                           alu_zero_preset_out,
    output [`REG_ADDR_WIDTH - 1 : 0] rd_addr_out

);

  wire [`REG_ADDR_WIDTH - 1 : 0] rs1_addr;
  wire [`REG_ADDR_WIDTH - 1 : 0] rs2_addr;
  wire [`DATA_WIDTH - 1 : 0] rs1_data;
  wire [`DATA_WIDTH - 1 : 0] rs2_data;
  wire [`DATA_WIDTH - 1 : 0] imm;
  wire [  `PC_SEL_WIDTH - 1 : 0] pc_sel;
  wire [  `ALU_OP_WIDTH - 1 : 0] alu_op;
  wire                           alu_zero_preset;
  

  wire                           mem_read;
  wire                           mem_write;
  
  assign rs1_addr_out = rs1_addr;
  assign rs2_addr_out = rs2_addr;

  ImmGen #(
      .INST_WIDTH(`INST_WIDTH),
      .IMM_WIDTH (`DATA_WIDTH)
  ) immgen_u (
      .inst_in(inst_in),
      .imm_out(imm)
  );


  InstDecoder #(
      .INST_WIDTH(`INST_WIDTH),
      .REG_ADDR_WIDTH(`REG_ADDR_WIDTH)
  ) inst_decoder_u (
      .inst_in (inst_in),
      .rs1_addr(rs1_addr),
      .rs2_addr(rs2_addr),
      .rd_addr (rd_addr_out)
  );

  RegFile #(
      .ADDR_WIDTH(`REG_ADDR_WIDTH),
      .DATA_WIDTH(`DATA_WIDTH)
  ) regfile_u (
      .clk  (clk),
      .rst_n(rst_n),

      .reg_we_in(reg_we_in),
      .addr_wr  (rd_addr_in),
      .data_wr  (rd_data_in),

      .addr_rd_1(rs1_addr),
      .data_rd_1(rs1_data),

      .addr_rd_2(rs2_addr),
      .data_rd_2(rs2_data)
  );

  Controler #(
      .INST_WIDTH  (`INST_WIDTH),
      .ALU_OP_WIDTH(`ALU_OP_WIDTH),
      .PC_SEL_WIDTH(`PC_SEL_WIDTH)
  ) controler_u (
      .inst_in(inst_in),

      .is_mem_read    (mem_read),
      .is_mem_write   (mem_write),
      .alu_op         (alu_op),
      .PC_sel         (pc_sel),
      .alu_src        (alu_src_out),
      .alu_zero_preset(alu_zero_preset),
      .is_reg_write   (reg_we_out),
      .is_mem_to_reg  (mem_to_reg_out),
      .mem_width      (mem_width_out)
  );

  assign data_we_out = mem_write;
  assign data_ce_out = mem_read | mem_write;


  BranchGen branch_gen_u (
      .pc_in          (pc_in),
      .rs1_data_in    (rs1_data),
      .rs2_data_in    (rs2_data),
      .imm_in         (imm),
      .pc_sel_in      (pc_sel),
      .pc_alu_op_in   (alu_op),
      .pc_alu_zero_preset_in(alu_zero_preset),

      .is_branch_out  (is_branch_out),
      .branch_target_out(pc_next_out),
      .pc_alu_op_out  (alu_op_out),
      .rs1_data_out   (rs1_data_out),
      .rs2_data_out   (rs2_data_out),
      .imm_out        (imm_out)
  );

endmodule
