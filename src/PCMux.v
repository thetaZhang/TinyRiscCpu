// next PC mux

module PCMux #(
  parameter ADDR_WIDTH = 32,
  parameter DATA_WIDTH = 32
)(
  input [ADDR_WIDTH - 1 : 0] PC_in,
  input PC_src_ctrl, // 0: PC+4, 1: branch target
  input [DATA_WIDTH - 1 : 0] imm_in,
  output [ADDR_WIDTH - 1 : 0] PC_next
);

wire [DATA_WIDTH - 1 : 0] imm_shifted;

assign imm_shifted = imm_in << 1;

assign PC_next = (PC_src_ctrl == 1'b0) ? PC_in + 4 : PC_in + imm_shifted;

endmodule
