// instruction decode
`include "GlobalDefine.vh"
module tinyrisc_ID (
    input clk,
    input rst_n,

    input [`INST_WIDTH - 1 : 0] inst_in,

    output [`DATA_WIDTH - 1 : 0] imm_out,
    output [`DATA_WIDTH - 1 : 0] rs1_data_out,
    output [`DATA_WIDTH - 1 : 0] rs2_data_out,
    input  [`DATA_WIDTH - 1 : 0] rd_data_in,

    output [`ALU_OP_WIDTH - 1 : 0] alu_op_out,
    output [`PC_SEL_WIDTH - 1 : 0] pc_sel_out,
    output                         alu_src_out,
    output                         data_we_out,
    output                         data_ce_out,
    output                         mem_to_reg_out,
    output                         alu_zero_preset

);

  wire [`REG_ADDR_WIDTH - 1 : 0] rs1_addr;
  wire [`REG_ADDR_WIDTH - 1 : 0] rs2_addr;
  wire [`REG_ADDR_WIDTH - 1 : 0] rd_addr;
  wire                           reg_we;
  wire                           mem_read;
  wire                           mem_write;

  ImmGen #(
      .INST_WIDTH(`INST_WIDTH),
      .IMM_WIDTH (`DATA_WIDTH)
  ) immgen_u (
      .inst_in(inst_in),
      .imm_out(imm_out)
  );


  InstDecoder #(
      .INST_WIDTH(`INST_WIDTH),
      .REG_ADDR_WIDTH(`REG_ADDR_WIDTH)
  ) inst_decoder_u (
      .inst_in (inst_in),
      .rs1_addr(rs1_addr),
      .rs2_addr(rs2_addr),
      .rd_addr (rd_addr)
  );

  RegFile #(
      .ADDR_WIDTH(`REG_ADDR_WIDTH),
      .DATA_WIDTH(`DATA_WIDTH)
  ) regfile_u (
      .clk  (clk),
      .rst_n(rst_n),

      .reg_we_in(reg_we),
      .addr_wr  (rd_addr),
      .data_wr  (rd_data_in),

      .addr_rd_1(rs1_addr),
      .data_rd_1(rs1_data_out),

      .addr_rd_2(rs2_addr),
      .data_rd_2(rs2_data_out)
  );

  Controler #(
      .INST_WIDTH  (`INST_WIDTH),
      .ALU_OP_WIDTH(`ALU_OP_WIDTH),
      .PC_SEL_WIDTH(`PC_SEL_WIDTH)
  ) controler_u (
      .inst_in(inst_in),

      .is_mem_read    (mem_read),
      .is_mem_write   (mem_write),
      .alu_op         (alu_op_out),
      .PC_sel         (pc_sel_out),
      .alu_src        (alu_src_out),
      .alu_zero_preset(alu_zero_preset),
      .is_reg_write   (reg_we),
      .is_mem_to_reg  (mem_to_reg_out)
  );

  assign data_we_out = mem_write;
  assign data_ce_out = mem_read | mem_write;

endmodule
