// instruction fetch
`include "GlobalDefine.vh"
module tinyrisc_IF (
  input clk,
  input rst_n,
  input [`ADDR_WIDTH - 1 : 0] pc_in,
  input pc_en,
  input pc_branch,
  output [`ADDR_WIDTH - 1 : 0] pc_out
);

wire [`ADDR_WIDTH - 1 : 0] pc_next;

assign pc_next = (pc_branch) ? pc_in : pc_out + 4;

DffNegRstEn #(`ADDR_WIDTH) pc_reg_u (clk, rst_n, pc_en, pc_next, pc_out);

endmodule
