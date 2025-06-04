// instruction fetch
`include "GlobalDefine.vh"

`define BHT_SIZE  256
`define BTB_SIZE  256

module tinyrisc_IF (
    input                        clk,
    input                        rst_n,

    input  [`INST_WIDTH - 1 : 0] inst_in,
    input                        pc_en,
    input                        flush_in,

    input  [`ADDR_WIDTH - 1 : 0] pc_update_in,
    input  [`PC_SEL_WIDTH - 1 : 0] pc_update_sel_in,
    input                        is_taken_update_in,
    input  [`ADDR_WIDTH - 1 : 0] target_update_in,

    output [`ADDR_WIDTH - 1 : 0] pc_out,
    output [`ADDR_WIDTH - 1 : 0] pc_next_predicted_out,
    output                       is_branch_predicted_out
);

  wire [  `ADDR_WIDTH - 1 : 0] pc_next;
  wire [  `ADDR_WIDTH - 1 : 0] pc_next_predicted;
  wire [`PC_SEL_WIDTH - 1 : 0] pc_sel;
  wire                         is_branch_predicted;

  wire                         btb_hit;

  assign pc_next_predicted_out = (btb_hit) ? pc_next_predicted : pc_out + 4;
  assign is_branch_predicted_out = is_branch_predicted;

  assign pc_next = (flush_in) ? ((is_taken_update_in) ? target_update_in : pc_update_in + 4) :
                   (pc_sel == `PC_PLUS4) ? pc_out + 4 :
                   (is_branch_predicted && btb_hit) ? pc_next_predicted : pc_out + 4;

  // pre-decode
  assign pc_sel = (inst_in[6 : 0] == 7'b1100011) ? `PC_BRANCH :
                  (inst_in[6 : 0] == 7'b1101111) ? `PC_JUMP :
                  (inst_in[6 : 0] == 7'b1100111) ? `PC_JUMP_R : `PC_PLUS4;

  // branch predictor
  BranchPredictor #(
      .ADDR_WIDTH(`ADDR_WIDTH),
      .BHT_SIZE  (`BHT_SIZE),
      .BTB_SIZE  (`BTB_SIZE)
  ) branch_predictor_u (
      .clk               (clk),
      .rst_n             (rst_n),
      .pc_query_in       (pc_out),
      .pc_query_sel_in   (pc_sel),
      .pc_update_in      (pc_update_in      ),
      .pc_update_sel_in  (pc_update_sel_in  ),
      .is_taken_update_in(is_taken_update_in),
      .target_update_in  (target_update_in  ),
      .pc_next_out       (pc_next_predicted),
      .is_taken_next_out (is_branch_predicted),
      .btb_hit_out       (btb_hit)
  );



  DffNegRstEn #(`ADDR_WIDTH) pc_reg_u (clk, rst_n, pc_en, pc_next, pc_out);

endmodule
