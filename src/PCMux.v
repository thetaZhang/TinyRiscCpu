// next PC mux

module PCMux #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input [ADDR_WIDTH - 1 : 0] PC_in,
  input [1 : 0] PC_src_ctrl, // 00: PC+4, 01: branch target; 10: jalr
  input is_branch,
  input [DATA_WIDTH - 1 : 0] offset_in,
  output [ADDR_WIDTH - 1 : 0] PC_next
);

assign PC_next = (PC_src_ctrl == `PC_PLUS4) ? PC_in + 4 :
                 ((PC_src_ctrl == `PC_BRANCH) && is_branch) ? (PC_in + offset_in) :
                 (PC_src_ctrl == `PC_JUMP) ? offset_in : PC_in + 4;

endmodule

