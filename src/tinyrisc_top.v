// top of the tinyrisc CPU
`include "GlobalDefine.vh"
module tinyrisc_top (
    input                        clk,
    input                        rst_n,
    input  [`INST_WIDTH - 1 : 0] inst_in,
    output [`ADDR_WIDTH - 1 : 0] inst_addr_out,
    output                       inst_ce_out,

    input  [`DATA_WIDTH - 1 : 0] data_read_in,
    output [`ADDR_WIDTH - 1 : 0] data_addr_out,
    output [`DATA_WIDTH - 1 : 0] data_write_out,
    output                       data_we_out,
    output                       data_ce_out
);
  // pc, inst
  localparam IF_ID_WIDTH = `INST_WIDTH + `ADDR_WIDTH;

  // rs1, rs2, imm, rs1_addr, rs2_addr, alu_op, alu_zero_preset, alu_src, pc, pc_sel, data_we, data_ce, mem_to_reg, rd_addr, reg_we, mem_width
  localparam ID_EX_WIDTH = `DATA_WIDTH * 3 + `REG_ADDR_WIDTH * 2 + `ALU_OP_WIDTH + 1 + `ALU_SRC_WIDTH + `ADDR_WIDTH + `PC_SEL_WIDTH + 3 + `REG_ADDR_WIDTH + 1 + `MEM_MODE_WIDTH;

  // ex_data_out, rs2_data, data_we, data_ce, mem_to_reg, rd_addr, pc_next, is_branch, reg_we, mem_width
  localparam EX_MEM_WIDTH = `DATA_WIDTH * 2 + 3 + `REG_ADDR_WIDTH + `ADDR_WIDTH + 1 + 1 + `MEM_MODE_WIDTH;


  // ex_data_out, data_rd, mem_to_reg, rd_addr, reg_we
  localparam MEM_WB_WIDTH = `DATA_WIDTH * 2 + 1 + `REG_ADDR_WIDTH + 1;


  // IF variables
  wire [    `ADDR_WIDTH - 1 : 0] pc_if;
  wire [    `ADDR_WIDTH - 1 : 0] pc_next_if;
  wire                           is_branch_if;


  // ID variables
  wire [    `INST_WIDTH - 1 : 0] inst_id;
  wire [    `ADDR_WIDTH - 1 : 0] pc_id;
  wire [  `ALU_OP_WIDTH - 1 : 0] alu_op_id;
  wire                           alu_zero_preset_id;
  wire [    `DATA_WIDTH - 1 : 0] rs1_data_id;
  wire [    `DATA_WIDTH - 1 : 0] rs2_data_id;
  wire [`REG_ADDR_WIDTH - 1 : 0] rs1_addr_id;
  wire [`REG_ADDR_WIDTH - 1 : 0] rs2_addr_id;
  wire [    `DATA_WIDTH - 1 : 0] rd_data_id;
  wire [`REG_ADDR_WIDTH - 1 : 0] rd_addr_id;
  wire [    `DATA_WIDTH - 1 : 0] imm_id;
  wire [ `ALU_SRC_WIDTH - 1 : 0] alu_src_id;
  wire [  `PC_SEL_WIDTH - 1 : 0] pc_sel_id;
  wire                           data_we_id;
  wire                           data_ce_id;
  wire [`MEM_MODE_WIDTH - 1 : 0] mem_width_id;
  wire                           mem_to_id;
  wire                           reg_we_id;

  // EX variables
  wire [    `DATA_WIDTH - 1 : 0] rs1_data_ex;
  wire [    `DATA_WIDTH - 1 : 0] rs2_data_ex;
  wire [    `DATA_WIDTH - 1 : 0] rs1_data_fwded_ex;
  wire [    `DATA_WIDTH - 1 : 0] rs2_data_fwded_ex;
  wire [`REG_ADDR_WIDTH - 1 : 0] rs1_addr_ex;
  wire [`REG_ADDR_WIDTH - 1 : 0] rs2_addr_ex;
  wire [    `DATA_WIDTH - 1 : 0] imm_ex;
  wire [  `ALU_OP_WIDTH - 1 : 0] alu_op_ex;
  wire                           alu_zero_preset_ex;
  wire [ `ALU_SRC_WIDTH - 1 : 0] alu_src_ex;
  wire [  `PC_SEL_WIDTH - 1 : 0] pc_sel_ex;
  wire [    `ADDR_WIDTH - 1 : 0] pc_ex;
  wire [    `ADDR_WIDTH - 1 : 0] pc_next_ex;
  wire                           data_we_ex;
  wire                           data_ce_ex;
  wire [`MEM_MODE_WIDTH - 1 : 0] mem_width_ex;
  wire                           mem_to_reg_ex;
  wire [    `DATA_WIDTH - 1 : 0] ex_data_out;
  wire [`REG_ADDR_WIDTH - 1 : 0] rd_addr_ex;
  wire                           is_branch_ex;
  wire                           reg_we_ex;
  wire [`FWD_WIDTH - 1 : 0]      rs1_fwd_ex;
  wire [`FWD_WIDTH - 1 : 0]      rs2_fwd_ex;


  // MEM variables
  wire [    `DATA_WIDTH - 1 : 0] ex_data_out_mem;
  wire [    `DATA_WIDTH - 1 : 0] rs2_data_mem;
  wire                           data_we_mem;
  wire                           data_ce_mem;
  wire [`MEM_MODE_WIDTH - 1 : 0] mem_width_mem;
  wire                           mem_to_reg_mem;
  wire [    `DATA_WIDTH - 1 : 0] data_rd_mem;
  wire [`REG_ADDR_WIDTH - 1 : 0] rd_addr_mem;
  wire [    `ADDR_WIDTH - 1 : 0] pc_next_mem;
  wire                           is_branch_mem;
  wire                           reg_we_mem;

  // WB variables
  wire [    `DATA_WIDTH - 1 : 0] ex_data_out_wb;
  wire [    `DATA_WIDTH - 1 : 0] data_rd_wb;
  wire                           mem_to_reg_wb;
  wire [`REG_ADDR_WIDTH - 1 : 0] rd_addr_wb;
  wire                           reg_we_wb;


  assign inst_ce_out = 1'b1;

  // IF

  assign inst_addr_out = pc_if;
  assign is_branch_if = is_branch_mem;
  assign pc_next_if = pc_next_mem;

  tinyrisc_IF IF_u (
      .clk      (clk),
      .rst_n    (rst_n),
      .pc_in    (pc_next_if),
      .pc_branch(is_branch_if),
      .pc_out   (pc_if)
  );

  DffNegRst #(IF_ID_WIDTH) if_id_reg_u (
      .clk  (clk),
      .rst_n(rst_n),
      .d    ({inst_in, pc_if}),
      .q    ({inst_id, pc_id})
  );

  // ID

  tinyrisc_ID ID_u (
      .clk            (clk),
      .rst_n          (rst_n),
      .inst_in        (inst_id),
      .imm_out        (imm_id),
      .rs1_data_out   (rs1_data_id),
      .rs2_data_out   (rs2_data_id),
      .rs1_addr_out   (rs1_addr_id),
      .rs2_addr_out   (rs2_addr_id),
      .rd_data_in     (rd_data_id),
      .rd_addr_out    (rd_addr_id),
      .rd_addr_in     (rd_addr_wb),
      .reg_we_in      (reg_we_wb),
      .reg_we_out     (reg_we_id),
      .alu_op_out     (alu_op_id),
      .pc_sel_out     (pc_sel_id),
      .alu_src_out    (alu_src_id),
      .data_we_out    (data_we_id),
      .data_ce_out    (data_ce_id),
      .mem_width_out  (mem_width_id),
      .mem_to_reg_out (mem_to_reg_id),
      .alu_zero_preset(alu_zero_preset_id)
  );

  DffNegRst #(ID_EX_WIDTH) id_ex_reg_u (
      .clk(clk),
      .rst_n(rst_n),
      .d({
        rs1_data_id,
        rs2_data_id,
        rs1_addr_id,
        rs2_addr_id,
        imm_id,
        alu_op_id,
        alu_zero_preset_id,
        alu_src_id,
        pc_id,
        pc_sel_id,
        data_we_id,
        data_ce_id,
        mem_to_reg_id,
        rd_addr_id,
        reg_we_id,
        mem_width_id
      }),
      .q({
        rs1_data_ex,
        rs2_data_ex,
        rs1_addr_ex,
        rs2_addr_ex,
        imm_ex,
        alu_op_ex,
        alu_zero_preset_ex,
        alu_src_ex,
        pc_ex,
        pc_sel_ex,
        data_we_ex,
        data_ce_ex,
        mem_to_reg_ex,
        rd_addr_ex,
        reg_we_ex,
        mem_width_ex
      })
  );

  // EX

  tinyrisc_Forwarding Forwarding_u (
      .ex_mem_rd_in   (rd_addr_mem),
      .mem_wb_rd_in   (rd_addr_wb),
      .id_ex_rs1_addr_in(rs1_addr_ex),
      .id_ex_rs2_addr_in(rs2_addr_ex),
      .ex_mem_reg_we_in(reg_we_mem),
      .mem_wb_reg_we_in(reg_we_wb),

      .ex_rs1_fwd_out(rs1_fwd_ex),
      .ex_rs2_fwd_out(rs2_fwd_ex)
  );

  assign rs1_data_fwded_ex = (rs1_fwd_ex == `EX_FWD_MEM) ? ex_data_out_mem :
                             (rs1_fwd_ex == `EX_FWD_WB) ? rd_data_id : rs1_data_ex;

  assign rs2_data_fwded_ex = (rs2_fwd_ex == `EX_FWD_MEM) ? ex_data_out_mem :
                             (rs2_fwd_ex == `EX_FWD_WB) ? rd_data_id : rs2_data_ex;

  tinyrisc_EX EX_u (
      .clk            (clk),
      .rst_n          (rst_n),
      .rs1_data_in    (rs1_data_fwded_ex),
      .rs2_data_in    (rs2_data_fwded_ex),
      .imm_in         (imm_ex),
      .alu_op_in      (alu_op_ex),
      .alu_src_in     (alu_src_ex),
      .alu_zero_preset(alu_zero_preset_ex),
      .ex_data_out    (ex_data_out),
      .pc_sel_in      (pc_sel_ex),
      .pc_in          (pc_ex),
      .pc_out         (pc_next_ex),
      .is_branch      (is_branch_ex)
  );

  DffNegRst #(EX_MEM_WIDTH) ex_mem_reg_u (
      .clk(clk),
      .rst_n(rst_n),
      .d({
        ex_data_out,
        rs2_data_ex,
        data_we_ex,
        data_ce_ex,
        mem_to_reg_ex,
        rd_addr_ex,
        pc_next_ex,
        is_branch_ex,
        reg_we_ex,
        mem_width_ex
      }),
      .q({
        ex_data_out_mem,
        rs2_data_mem,
        data_we_mem,
        data_ce_mem,
        mem_to_reg_mem,
        rd_addr_mem,
        pc_next_mem,
        is_branch_mem,
        reg_we_mem,
        mem_width_mem
      })
  );


  // MEM
  assign data_addr_out = ex_data_out_mem[`ADDR_WIDTH-1 : 0];
  assign data_write_out = rs2_data_mem;
  assign data_we_out = data_we_mem;
  assign data_ce_out = data_ce_mem;
  assign data_rd_mem = (mem_width_mem == `MEM_WORD) ? data_read_in :
                       (mem_width_mem == `MEM_HALF) ? {{(`DATA_WORD - `DATA_HALF){data_read_in[`DATA_HALF - 1]}}, data_read_in[`DATA_HALF - 1 : 0]} :
                       (mem_width_mem == `MEM_BYTE) ? {{(`DATA_WORD - `DATA_BYTE){data_read_in[`DATA_BYTE - 1]}}, data_read_in[`DATA_BYTE - 1 : 0]} :
                       (mem_width_mem == `MEM_BYTE_U) ? {24'b0, data_read_in[`DATA_BYTE - 1 : 0]} :
                       (mem_width_mem == `MEM_HALF_U) ? {16'b0, data_read_in[`DATA_HALF - 1 : 0]} : data_read_in;

  DffNegRst #(MEM_WB_WIDTH) mem_wb_reg_u (
      .clk  (clk),
      .rst_n(rst_n),
      .d    ({ex_data_out_mem, data_rd_mem, mem_to_reg_mem, rd_addr_mem, reg_we_mem}),
      .q    ({ex_data_out_wb, data_rd_wb, mem_to_reg_wb, rd_addr_wb, reg_we_wb})
  );

  // WB
  assign rd_data_id = mem_to_reg_wb ? data_rd_wb : ex_data_out_wb;

endmodule
