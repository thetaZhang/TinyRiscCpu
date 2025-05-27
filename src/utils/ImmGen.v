// immediate number generator
module ImmGen #(
    parameter INST_WIDTH = 32,
    parameter IMM_WIDTH = 32
)(
  input  [INST_WIDTH - 1 : 0] inst_in,
  output [IMM_WIDTH - 1 : 0] imm_out
);



wire [IMM_WIDTH - 1 : 0]  I_imm, S_imm, SB_imm, U_imm, UJ_imm;

assign I_imm = {{20{inst_in[31]}}, inst_in[31:20]};
assign S_imm = {{20{inst_in[31]}}, inst_in[31:25], inst_in[11:7]};
assign SB_imm = {{20{inst_in[31]}}, inst_in[7], inst_in[30:25], inst_in[11:8], 1'b0};
assign U_imm = {inst_in[31:12], 12'b0};
assign UJ_imm = {{12{inst_in[31]}}, inst_in[19:12], inst_in[20], inst_in[30:21], 1'b0};

assign imm_out = ((inst_in & `I_TYPE_MASK) == `INST_ADDI ) ? I_imm  :
                 ((inst_in & `I_TYPE_MASK) == `INST_LW   ) ? I_imm  :
                 ((inst_in & `S_TYPE_MASK) == `INST_SW   ) ? S_imm  :
                 ((inst_in & `B_TYPE_MASK) == `INST_BLT  ) ? SB_imm :
                 ((inst_in & `B_TYPE_MASK) == `INST_BEQ  ) ? SB_imm :
                 ((inst_in & `U_TYPE_MASK) == `INST_JAL  ) ? UJ_imm : 32'b0;
endmodule



