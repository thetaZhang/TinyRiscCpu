// main controller

`define R_TYPE_INPUT ((inst_in & `R_TYPE_MASK) == `INST_ADD) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SUB) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_AND) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_OR ) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_XOR) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SLL) || \
                     ((inst_in & `R_TYPE_MASK) == `INST_SRL)

`define I_TYPE_INPUT ((inst_in & `I_TYPE_MASK) == `INST_ADDI) || \
                     ((inst_in & `I_TYPE_MASK) == `INST_LW  )

`define S_TYPE_INPUT ((inst_in & `S_TYPE_MASK) == `INST_SW  )

`define B_TYPE_INPUT ((inst_in & `B_TYPE_MASK) == `INST_BLT) || \
                     ((inst_in & `B_TYPE_MASK) == `INST_BEQ)

`define U_TYPE_INPUT ((inst_in & `U_TYPE_MASK) == `INST_JAL)


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


assign is_mem_read = ((inst_in & `I_TYPE_MASK) == `INST_LW) ? 1'b1 : 1'b0;
assign is_mem_write = ((inst_in & `S_TYPE_MASK) == `INST_SW) ? 1'b1 : 1'b0;

assign is_mem_to_reg = ((inst_in & `I_TYPE_MASK) == `INST_LW) ? 1'b1 : 1'b0;


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
                (`U_TYPE_INPUT) ? `PC_JUMP :
                ((inst_in & `I_TYPE_MASK) == `INST_JALR) ?`PC_JUMP_R : `PC_PLUS4;

assign alu_op = ((inst_in & `R_TYPE_MASK) == `INST_ADD) ? `ALU_ADD :
                ((inst_in & `R_TYPE_MASK) == `INST_SUB) ? `ALU_SUB :
                ((inst_in & `R_TYPE_MASK) == `INST_AND) ? `ALU_AND :
                ((inst_in & `R_TYPE_MASK) == `INST_OR ) ? `ALU_OR  :
                ((inst_in & `R_TYPE_MASK) == `INST_XOR) ? `ALU_XOR :
                ((inst_in & `R_TYPE_MASK) == `INST_SLL) ? `ALU_SLL :
                ((inst_in & `R_TYPE_MASK) == `INST_SRL) ? `ALU_SRL :
                ((inst_in & `I_TYPE_MASK) == `INST_ADDI) ? `ALU_ADD :
                ((inst_in & `I_TYPE_MASK) == `INST_LW) ? `ALU_ADD :
                ((inst_in & `I_TYPE_MASK) == `INST_JALR) ? `ALU_ADD :
                ((inst_in & `B_TYPE_MASK) == `INST_BLT) ? `ALU_LT  :
                ((inst_in & `B_TYPE_MASK) == `INST_BEQ) ? `ALU_SUB :
                ((inst_in & `U_TYPE_MASK) == `INST_JAL) ? `ALU_NONE :
                ((inst_in & `S_TYPE_MASK) == `INST_SW) ? `ALU_ADD : `ALU_NONE;

assign alu_zero_preset = ((inst_in & `B_TYPE_MASK) == `INST_BEQ) ? 1'b1 :
                         ((inst_in & `B_TYPE_MASK) == `INST_BLT) ? 1'b0 : 1'b0;

endmodule
