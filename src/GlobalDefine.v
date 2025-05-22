
// opcode mask
`define R_TYPE_MASK 32'hfe00707f
`define I_TYPE_MASK 32'h707f
`define S_TYPE_MASK 32'h707f
`define B_TYPE_MASK 32'h707f
`define U_TYPE_MASK 32'h7f

// opcodes
`define INST_ADD 32'h33
`define INST_ADDI 32'h7013
`define INST_SUB 32'h40000033
`define INST_AND 32'h7033
`define INST_OR 32'h6033
`define INST_XOR 32'h4033
`define INST_BLT 32'h4063
`define INST_BEQ 32'h63
`define INST_JAL 32'h6f
`define INST_SLL 32'h1033
`define INST_SRL 32'h5033
`define INST_LW 32'h2003
`define INST_SW 32'h2023
