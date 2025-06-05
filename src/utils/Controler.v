// main controller
`include "GlobalDefine.vh"
`define R_TYPE_INPUT ((inst_in & `R_TYPE_MASK) == `INST_ADD) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SUB) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_AND) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_OR ) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_XOR) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SLL) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SRL) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SRA) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SLT) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SLTU)

`define I_TYPE_INPUT ((inst_in & `I_TYPE_MASK) == `INST_ADDI) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_SLTI) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_SLTIU) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_XORI) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_ORI ) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_ANDI) || \
                     ((inst_in & `I_TYPE_SHF_MASK) == `INST_SLLI) || \
                     ((inst_in & `I_TYPE_SHF_MASK) == `INST_SRLI) || \
                     ((inst_in & `I_TYPE_SHF_MASK) == `INST_SRAI) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_LW  ) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_LH  ) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_LB  ) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_LHU ) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_LBU ) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_JALR)

`define I_TYPE_LD_INPUT ((inst_in & `I_TYPE_MASK) == `INST_LW  ) || \
                         ((inst_in & `I_TYPE_MASK) == `INST_LH  ) || \
                         ((inst_in & `I_TYPE_MASK) == `INST_LB  ) || \
                         ((inst_in & `I_TYPE_MASK) == `INST_LHU ) || \
                         ((inst_in & `I_TYPE_MASK) == `INST_LBU )

`define S_TYPE_INPUT ((inst_in & `S_TYPE_MASK) == `INST_SW  ) || \
                     ((inst_in & `S_TYPE_MASK) == `INST_SH  ) || \
                     ((inst_in & `S_TYPE_MASK) == `INST_SB  )

`define B_TYPE_INPUT ((inst_in & `B_TYPE_MASK) == `INST_BLT) || \
                     ((inst_in & `B_TYPE_MASK) == `INST_BEQ) || \
                     ((inst_in & `B_TYPE_MASK) == `INST_BNE) || \
                     ((inst_in & `B_TYPE_MASK) == `INST_BLTU) || \
                     ((inst_in & `B_TYPE_MASK) == `INST_BGE) || \
                     ((inst_in & `B_TYPE_MASK) == `INST_BGEU)

`define U_TYPE_INPUT ((inst_in & `U_TYPE_MASK) == `INST_JAL) || \
                     ((inst_in & `U_TYPE_MASK) == `INST_LUI) || \
                     ((inst_in & `U_TYPE_MASK) == `INST_AUIPC)

module Controler #(
  parameter INST_WIDTH = 32,
  parameter ALU_OP_WIDTH = 4,
  parameter PC_SEL_WIDTH = 2
)(
    input [INST_WIDTH - 1 : 0] inst_in,

    output is_mem_read,
    output is_mem_write,
    output [ALU_OP_WIDTH - 1 : 0] alu_op,
    output [PC_SEL_WIDTH - 1 : 0] PC_sel,
    output alu_src,
    output alu_zero_preset,
    output is_reg_write,
    output is_mem_to_reg
);


  assign is_mem_read = (`I_TYPE_LD_INPUT) ? 1'b1 : 1'b0;
  assign is_mem_write = (`S_TYPE_INPUT) ? 1'b1 : 1'b0;

  assign is_mem_to_reg = (`I_TYPE_LD_INPUT) ? 1'b1 : 1'b0;


assign alu_src = (`R_TYPE_INPUT) ? `ALU_SRC_REG :
                 (`I_TYPE_INPUT) ? `ALU_SRC_IMM :
                 (`S_TYPE_INPUT) ? `ALU_SRC_IMM :
                 (`B_TYPE_INPUT) ? `ALU_SRC_REG :
                 (`U_TYPE_INPUT) ? `ALU_SRC_IMM : `ALU_SRC_REG;

assign is_reg_write = (`R_TYPE_INPUT) ? 1'b1 :
                      (`I_TYPE_INPUT) ? 1'b1 :
                      (`S_TYPE_INPUT) ? 1'b0 :
                      (`B_TYPE_INPUT) ? 1'b0 :
                      (`U_TYPE_INPUT) ? 1'b1 : 1'b0;

  assign PC_sel = (`B_TYPE_INPUT) ? `PC_BRANCH :
                ((inst_in & `U_TYPE_MASK) == `INST_JAL) ? `PC_JUMP :
                ((inst_in & `I_TYPE_MASK) == `INST_JALR) ?`PC_JUMP_R : `PC_PLUS4;

  assign alu_op = ((inst_in & `R_TYPE_MASK) == `INST_ADD) ? `ALU_ADD :
                  ((inst_in & `R_TYPE_MASK) == `INST_SUB) ? `ALU_SUB :
                  ((inst_in & `R_TYPE_MASK) == `INST_AND) ? `ALU_AND :
                  ((inst_in & `R_TYPE_MASK) == `INST_OR ) ? `ALU_OR  :
                  ((inst_in & `R_TYPE_MASK) == `INST_XOR) ? `ALU_XOR :
                  ((inst_in & `R_TYPE_MASK) == `INST_SLL) ? `ALU_SLL :
                  ((inst_in & `R_TYPE_MASK) == `INST_SRL) ? `ALU_SRL :
                  ((inst_in & `R_TYPE_MASK) == `INST_SRA) ? `ALU_SRA :
                  ((inst_in & `R_TYPE_MASK) == `INST_SLT) ? `ALU_LT  :
                  ((inst_in & `R_TYPE_MASK) == `INST_SLTU) ? `ALU_LTU :
                  ((inst_in & `I_TYPE_MASK) == `INST_ADDI) ? `ALU_ADD :
                  ((inst_in & `I_TYPE_MASK) == `INST_SLTI) ? `ALU_LT  :
                  ((inst_in & `I_TYPE_MASK) == `INST_SLTIU) ? `ALU_LTU :
                  ((inst_in & `I_TYPE_MASK) == `INST_XORI) ? `ALU_XOR :
                  ((inst_in & `I_TYPE_MASK) == `INST_ORI ) ? `ALU_OR  :
                  ((inst_in & `I_TYPE_MASK) == `INST_ANDI) ? `ALU_AND :
                  ((inst_in & `I_TYPE_SHF_MASK) == `INST_SLLI) ? `ALU_SLL :
                  ((inst_in & `I_TYPE_SHF_MASK) == `INST_SRLI) ? `ALU_SRL :
                  ((inst_in & `I_TYPE_SHF_MASK) == `INST_SRAI) ? `ALU_SRA :
                  ((inst_in & `I_TYPE_MASK) == `INST_LW) ? `ALU_ADD :
                  ((inst_in & `I_TYPE_MASK) == `INST_LH) ? `ALU_ADD :
                  ((inst_in & `I_TYPE_MASK) == `INST_LB) ? `ALU_ADD :
                  ((inst_in & `I_TYPE_MASK) == `INST_LHU) ? `ALU_ADD :
                  ((inst_in & `I_TYPE_MASK) == `INST_LBU) ? `ALU_ADD :
                  ((inst_in & `I_TYPE_MASK) == `INST_JALR) ? `ALU_ADD :
                  ((inst_in & `S_TYPE_MASK) == `INST_SW) ? `ALU_ADD :
                  ((inst_in & `S_TYPE_MASK) == `INST_SH) ? `ALU_ADD :
                  ((inst_in & `S_TYPE_MASK) == `INST_SB) ? `ALU_ADD :
                  ((inst_in & `B_TYPE_MASK) == `INST_BLT) ? `ALU_LT  :
                  ((inst_in & `B_TYPE_MASK) == `INST_BEQ) ? `ALU_SUB :
                  ((inst_in & `B_TYPE_MASK) == `INST_BNE) ? `ALU_SUB :
                  ((inst_in & `B_TYPE_MASK) == `INST_BLTU) ? `ALU_LTU :
                  ((inst_in & `B_TYPE_MASK) == `INST_BGE) ? `ALU_LT  :
                  ((inst_in & `B_TYPE_MASK) == `INST_BGEU) ? `ALU_LTU :
                  ((inst_in & `U_TYPE_MASK) == `INST_LUI) ? `ALU_NONE :
                  ((inst_in & `U_TYPE_MASK) == `INST_AUIPC) ? `ALU_ADD :
                  ((inst_in & `U_TYPE_MASK) == `INST_JAL) ? `ALU_NONE :`ALU_NONE;

assign alu_zero_preset = ((inst_in & `B_TYPE_MASK) == `INST_BEQ) ? 1'b1 :
                         ((inst_in & `B_TYPE_MASK) == `INST_BLT) ? 1'b0 :
                         ((inst_in & `B_TYPE_MASK) == `INST_BNE) ? 1'b0 :
                         ((inst_in & `B_TYPE_MASK) == `INST_BLTU) ? 1'b0 :
                         ((inst_in & `B_TYPE_MASK) == `INST_BGE) ? 1'b1 :
                         ((inst_in & `B_TYPE_MASK) == `INST_BGEU) ? 1'b1 : 1'b0;
endmodule
