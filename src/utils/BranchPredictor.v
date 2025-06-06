// branch predictor
`include "GlobalDefine.vh"
module BranchPredictor #(
  parameter ADDR_WIDTH = 32,
  parameter BHT_SIZE = 1024,
  parameter BHT_ADDR_WIDTH = $clog2(BHT_SIZE),
  parameter BTB_SIZE = 1024,
  parameter BTB_ADDR_WIDTH = $clog2(BTB_SIZE)
)(
  input clk,
  input rst_n,

  input [ADDR_WIDTH - 1 : 0] pc_query_in,
  input [`PC_SEL_WIDTH - 1 : 0] pc_query_sel_in,
  input [ADDR_WIDTH - 1 : 0] pc_update_in,
  input [`PC_SEL_WIDTH - 1 : 0] pc_update_sel_in,
  input is_taken_update_in,
  input [ADDR_WIDTH - 1 : 0] target_update_in,

  output [ADDR_WIDTH - 1 : 0]pc_next_out,
  output is_taken_next_out,
  output btb_hit_out
);

wire bht_update_en;
wire btb_update_en;

wire [1 : 0] bht[0 : BHT_SIZE - 1];

wire [BHT_ADDR_WIDTH - 1 : 0] bht_query_entry;
wire [BHT_ADDR_WIDTH - 1 : 0] bht_update_entry;

wire [ADDR_WIDTH - 1 : 0] btb_target[0 : BTB_SIZE - 1];
wire [ADDR_WIDTH - BTB_ADDR_WIDTH - 1 : 0] btb_tag[0 : BTB_SIZE - 1];
wire btb_valid[0 : BTB_SIZE - 1];

wire [BTB_ADDR_WIDTH - 1 : 0] btb_query_entry;
wire [BTB_ADDR_WIDTH - 1 : 0] btb_update_entry;
wire [ADDR_WIDTH - BTB_ADDR_WIDTH - 1 : 0] btb_update_tag;


assign bht_update_en = (pc_update_sel_in == `PC_BRANCH);
assign bht_query_entry = pc_query_in[BHT_ADDR_WIDTH - 1 + 2 : 2];
assign bht_update_entry = pc_update_in[BHT_ADDR_WIDTH - 1 + 2 : 2];

assign btb_update_en = (pc_update_sel_in == `PC_BRANCH) || (pc_update_sel_in == `PC_JUMP);
assign btb_query_entry = pc_query_in[BTB_ADDR_WIDTH - 1 + 2 : 2];
assign btb_update_entry = pc_update_in[BTB_ADDR_WIDTH - 1 + 2 : 2];
assign btb_update_tag = pc_update_in[ADDR_WIDTH - 1 : BTB_ADDR_WIDTH];

// BHT
// BHT update
genvar i;
generate
  for (i = 0; i < BHT_SIZE; i = i + 1) begin : gen_bht
    wire [1 : 0] bht_next;
    assign bht_next = (bht_update_entry != i) ? bht[i]:
                      (is_taken_update_in) ? ((bht[i] == 2'b11) ? 2'b11 : bht[i] + 2'b01):
                                             ((bht[i] == 2'b00) ? 2'b00 : bht[i] - 2'b01);
    DffNegRstEn #(2) bht_reg_u (clk, rst_n, bht_update_en, bht_next, bht[i]);
  end
endgenerate

// BHT query
// noy predict Jalr, if Jalr, set not taken
assign is_taken_next_out = (pc_query_sel_in == `PC_JUMP) ? 1'b1 :
                           (pc_query_sel_in == `PC_JUMP_R) ? 1'b1 :
                           (pc_query_sel_in == `PC_BRANCH) ? (bht[bht_query_entry] >= 2'b10) :
                           (pc_query_sel_in == `PC_PLUS4) ? 1'b0 : 1'b0;


// BTB


generate
  for (i = 0; i < BTB_SIZE; i = i + 1) begin : gen_btb
    wire [ADDR_WIDTH + ADDR_WIDTH - BTB_ADDR_WIDTH : 0] btb_next;
    assign btb_next = (btb_update_entry != i) ? {btb_valid[i], btb_tag[i], btb_target[i]} : {1'b1, btb_update_tag, target_update_in};
    DffNegRstEn #(1 + ADDR_WIDTH - BTB_ADDR_WIDTH + ADDR_WIDTH) btb_target_reg_u (clk, rst_n, btb_update_en, btb_next, {btb_valid[i], btb_tag[i], btb_target[i]});
  end
endgenerate

assign btb_hit_out = (btb_valid[btb_query_entry]) && (btb_tag[btb_query_entry] == btb_update_tag) && (~(pc_query_sel_in == `PC_JUMP_R));

assign pc_next_out = btb_target[btb_query_entry];


endmodule
