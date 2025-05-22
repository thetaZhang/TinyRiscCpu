// instruction decoder

module InstDecoder#(
  parameter INST_WIDTH = 32,
  parameter REG_ADDR_WIDTH = 5
)(
    input [INST_WIDTH - 1 : 0] inst_in,
    output [REG_ADDR_WIDTH - 1 : 0] rs1_addr,
    output [REG_ADDR_WIDTH - 1 : 0] rs2_addr,
    output [REG_ADDR_WIDTH - 1 : 0] rd_addr
);

assign rs1_addr = inst_in[19:15];
assign rs2_addr = inst_in[24:20];
assign rd_addr = inst_in[11:7];

endmodule
