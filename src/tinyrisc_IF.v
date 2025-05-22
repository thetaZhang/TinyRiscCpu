// instruction fetch

module tinyrisc_IF (
  input clk,
  input rst_n,
  input [`ADDR_WIDTH : 0] pc_in,
  input is_branch,
  output [`ADDR_WIDTH : 0] pc_out
);


wire [`ADDR_WIDTH : 0] pc_reg_in;

assign pc_reg_in = (is_branch) ? pc_in : pc_out + 4;

DffNegRst #(`ADDR_WIDTH) pc_reg_u (clk, rst_n, pc_reg_in, pc_out);

endmodule
