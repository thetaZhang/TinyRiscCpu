// instruction execution
`include "GlobalDefine.vh"
module tinyrisc_EX (
    input clk,
    input rst_n,

    input  [  `DATA_WIDTH - 1 : 0] rs1_data_in,
    input  [  `DATA_WIDTH - 1 : 0] rs2_data_in,
    input  [  `DATA_WIDTH - 1 : 0] imm_in,
    input  [`ALU_OP_WIDTH - 1 : 0] alu_op_in,
    input                          alu_src_in,
    input                          alu_zero_preset,
    output [  `DATA_WIDTH - 1 : 0] ex_data_out,
    input  [`PC_SEL_WIDTH - 1 : 0] pc_sel_in,
    input  [  `ADDR_WIDTH - 1 : 0] pc_in,
    output [  `ADDR_WIDTH - 1 : 0] pc_out
);

  wire [`DATA_WIDTH - 1 : 0] rs2_data;
  wire                       alu_zero;
  wire [`DATA_WIDTH - 1 : 0] alu_data_out;

  wire                       is_branch;
  wire [`DATA_WIDTH - 1 : 0] pc_offset;
  wire [`ADDR_WIDTH - 1 : 0] pc_save;

  //ALU

  assign rs2_data = (alu_src_in == `ALU_SRC_IMM) ? imm_in : rs2_data_in;

  ALU #(
      .DATA_WIDTH(`DATA_WIDTH)
  ) alu_u (
      .op_ctrl  (alu_op_in),
      .data_in_1(rs1_data_in),
      .data_in_2(rs2_data),
      .data_out (alu_data_out),
      .zero     (alu_zero)
  );


  //PC gen
  assign is_branch = (alu_zero == alu_zero_preset);
  assign pc_offset = (pc_sel_in == `PC_JUMP_R) ? alu_data_out : imm_in;

  PCMux #(
      .ADDR_WIDTH(`ADDR_WIDTH),
      .DATA_WIDTH(`DATA_WIDTH)
  ) pc_mux_u (
      .PC_in      (pc_in),
      .PC_src_ctrl(pc_sel_in),  // Assuming alu_op_in[1:0] is used for PC selection
      .is_branch  (is_branch),
      .offset_in  (pc_offset),
      .PC_save_out(pc_save),
      .PC_next    (pc_out)
  );


  // out data to next stage and write back
  assign ex_data_out = (pc_sel_in == `PC_JUMP_R) ? pc_save :
                       (pc_sel_in == `PC_JUMP) ? pc_save : alu_data_out;


endmodule
