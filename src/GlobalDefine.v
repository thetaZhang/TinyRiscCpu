// system
`define INST_WIDTH 32
`define ADDR_WIDTH 32
`define DATA_WIDTH 32
`define REG_ADDR_WIDTH 5

// opcode mask
`define R_TYPE_MASK 32'hfe00707f
`define I_TYPE_MASK 32'h707f
`define S_TYPE_MASK 32'h707f
`define B_TYPE_MASK 32'h707f
`define U_TYPE_MASK 32'h7f

// opcodes
`define INST_ADD 32'h33
`define INST_ADDI 32'h13
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
`define INST_JALR 32'h67

// ALU input B src
`define ALU_SRC_IMM 1'b1
`define ALU_SRC_REG 1'b0

//ALUopcodes
`define ALU_OP_WIDTH 4

`define ALU_NONE  4'b0000
`define ALU_ADD   4'b0001
`define ALU_SUB   4'b0010
`define ALU_AND   4'b0011
`define ALU_OR    4'b0100
`define ALU_XOR   4'b0101
`define ALU_SLL   4'b0110
`define ALU_SRL   4'b0111
`define ALU_LT    4'b1000
`define ALU_LTU   4'b1001



// PCselcodes
`define PC_SEL_WIDTH 2

`define PC_PLUS4 2'b00
`define PC_BRANCH 2'b01
`define PC_JUMP 2'b10
`define PC_JUMP_R 2'b11


// test data path
`ifndef TEST_DATA_PATH
  `define TEST_DATA_PATH "test/data/data_mem.txt"
`endif

`ifndef TEST_INST_PATH
  `define TEST_INST_PATH "test/data/machinecode.txt"
`endif
