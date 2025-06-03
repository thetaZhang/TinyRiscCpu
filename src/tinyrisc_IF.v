// instruction fetch
`include "GlobalDefine.vh"
module tinyrisc_IF (
  input clk,
  input rst_n,
  input [`ADDR_WIDTH - 1 : 0] pc_in,
  output [`ADDR_WIDTH - 1 : 0] pc_out
);


DffNegRst #(`ADDR_WIDTH) pc_reg_u (clk, rst_n, pc_in, pc_out);

endmodule
