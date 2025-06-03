// next PC mux
`include "GlobalDefine.vh"
module PCMux #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input [ADDR_WIDTH - 1 : 0] PC_in,
  input [1 : 0] PC_src_ctrl, // 00: PC+4, 01: branch target; 10: jalr
  input is_branch,
  input [DATA_WIDTH - 1 : 0] offset_in,
  output [DATA_WIDTH - 1 : 0] PC_save_out,
  output [ADDR_WIDTH - 1 : 0] PC_next
);

wire [ADDR_WIDTH - 1 : 0] PC_plus4;
assign PC_plus4 = PC_in + 4;
assign PC_save_out = PC_plus4;

assign PC_next = (PC_src_ctrl == `PC_PLUS4) ? PC_plus4 :
                 ((PC_src_ctrl == `PC_BRANCH) && is_branch) ? (PC_in + offset_in) :
                 (PC_src_ctrl == `PC_JUMP) ? PC_in + offset_in :
                 (PC_src_ctrl == `PC_JUMP_R) ? offset_in : PC_plus4;

endmodule

