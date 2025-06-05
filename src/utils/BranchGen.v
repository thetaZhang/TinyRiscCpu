// branch in ID
`include "GlobalDefine.vh"
module BranchGen(
  input [`ADDR_WIDTH - 1 : 0] pc_in,
  input [`DATA_WIDTH - 1 : 0] rs1_data_in,
  input [`DATA_WIDTH - 1 : 0] rs2_data_in,
  input [`DATA_WIDTH - 1 : 0] imm_in,
  input [`PC_SEL_WIDTH - 1 : 0] pc_sel_in,
  input [`ALU_OP_WIDTH - 1 : 0] pc_alu_op_in,
  input                         pc_alu_zero_preset_in,

  output is_branch_out,
  output [`ADDR_WIDTH - 1 : 0] branch_target_out,
  output [`ALU_OP_WIDTH - 1 : 0] pc_alu_op_out,
  output [`DATA_WIDTH - 1 : 0] rs1_data_out,
  output [`DATA_WIDTH - 1 : 0] rs2_data_out,
  output [`DATA_WIDTH - 1 : 0] imm_out
);


wire [`DATA_WIDTH - 1 : 0] data_in_2;
wire                       in_2_inv;
wire [`DATA_WIDTH - 1 : 0] res_lt;
wire [`DATA_WIDTH - 1 : 0] res_ltu;
wire [`DATA_WIDTH - 1 : 0] res_alu;
wire                       carry;
wire                       overflow;
wire                       zero;
wire [`DATA_WIDTH - 1 : 0] data_out;
wire [`DATA_WIDTH - 1 : 0] rs2_data;

assign rs2_data = (pc_sel_in == `PC_JUMP_R) ? imm_in : rs2_data_in;

assign in_2_inv = (pc_alu_op_in == `ALU_LT) || (pc_alu_op_in == `ALU_LTU) || (pc_alu_op_in == `ALU_SUB);
assign data_in_2 = (in_2_inv) ? (~rs2_data + 1'b1) : rs2_data;
assign {carry, res_alu} = rs1_data_in + data_in_2;
assign overflow = (rs1_data_in[`DATA_WIDTH - 1] == data_in_2[`DATA_WIDTH - 1]) && (res_alu[`DATA_WIDTH - 1] != rs1_data_in[`DATA_WIDTH - 1]);
assign res_lt = (rs2_data_in == {1'b1,{(`DATA_WIDTH - 1){1'b0}}}) ? 1'b0 :
                (~overflow) ? res_alu[`DATA_WIDTH - 1] : rs1_data_in[`DATA_WIDTH - 1];
assign res_ltu = (|rs2_data_in) && (~carry);

assign data_out = (pc_alu_op_in == `ALU_ADD) ? res_alu :
                 (pc_alu_op_in == `ALU_SUB) ? res_alu :
                 (pc_alu_op_in == `ALU_LT)  ? res_lt :
                 (pc_alu_op_in == `ALU_LTU) ? res_ltu : {(`DATA_WIDTH){1'b0}};

assign zero = ~(|data_out);

assign is_branch_out = (pc_sel_in == `PC_JUMP) ||
                      (pc_sel_in == `PC_JUMP_R) ||
                      ((pc_sel_in == `PC_BRANCH) && (zero == pc_alu_zero_preset_in));

assign branch_target_out = (pc_sel_in == `PC_JUMP_R) ? data_out : $signed(imm_in) + pc_in;

assign pc_alu_op_out = (pc_sel_in == `PC_BRANCH) ? `ALU_NONE :
                       (pc_sel_in == `PC_JUMP) ? `ALU_ADD :
                       (pc_sel_in == `PC_JUMP_R) ? `ALU_ADD : pc_alu_op_in;

assign rs1_data_out = (pc_sel_in == `PC_BRANCH) ? {(`DATA_WIDTH){1'b0}}:
                      (pc_sel_in == `PC_JUMP) ? pc_in :
                      (pc_sel_in == `PC_JUMP_R) ? pc_in : rs1_data_in;

assign rs2_data_out = (pc_sel_in == `PC_BRANCH) ? {(`DATA_WIDTH){1'b0}}:
                      (pc_sel_in == `PC_JUMP) ? {(`DATA_WIDTH){1'b0}} :
                      (pc_sel_in == `PC_JUMP_R) ? {(`DATA_WIDTH){1'b0}} : rs2_data_in;

assign imm_out = (pc_sel_in == `PC_BRANCH) ? {(`DATA_WIDTH){1'b0}} :
                 (pc_sel_in == `PC_JUMP) ? 32'h4 :
                 (pc_sel_in == `PC_JUMP_R) ? 32'h4 : imm_in;

endmodule