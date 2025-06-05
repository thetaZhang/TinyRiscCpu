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

`define I_TYPE_SHF_MASK 32'hfc00707f

// opcodes
// R-type instructions
`define INST_ADD 32'h33
`define INST_SUB 32'h40000033
`define INST_AND 32'h7033
`define INST_OR 32'h6033
`define INST_XOR 32'h4033
`define INST_SLL 32'h1033
`define INST_SRL 32'h5033
`define INST_SRA 32'h40005033
`define INST_SLT 32'h2033
`define INST_SLTU 32'h3033

// I-type instructions
// arithmetic logic
`define INST_ADDI 32'h13
`define INST_SLTI 32'h2013
`define INST_SLTIU 32'h3013
`define INST_XORI 32'h4013
`define INST_ORI 32'h6013
`define INST_ANDI 32'h7013
`define INST_SLLI 32'h1013
`define INST_SRLI 32'h5013
`define INST_SRAI 32'h40005013
// load
`define INST_LW 32'h2003
`define INST_LH 32'h1003
`define INST_LB 32'h0003
`define INST_LHU 32'h5003
`define INST_LBU 32'h4003
// jalr
`define INST_JALR 32'h67

// S-type instructions
`define INST_SW 32'h2023
`define INST_SH 32'h1023
`define INST_SB 32'h0023

// SB-type instructions
`define INST_BLT 32'h4063
`define INST_BEQ 32'h63
`define INST_BNE 32'h1063
`define INST_BLTU 32'h6063
`define INST_BGE 32'h5063
`define INST_BGEU 32'h7063


// U-type instructions
`define INST_LUI 32'h37
`define INST_AUIPC 32'h17

// UJ-type instructions
`define INST_JAL 32'h6f

// ALU input B src
`define ALU_SRC_IMM 1'b0
`define ALU_SRC_REG 1'b1

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
`define ALU_SRA   4'b1010




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
