// Stall unit
`include "GlobalDefine.vh"

module tinyrisc_Stalling(
    input [`REG_ADDR_WIDTH - 1 : 0] id_ex_rd_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] ex_mem_rd_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] if_id_rs1_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] if_id_rs2_addr_in,
    input                           id_ex_data_we_in,
    input                           id_ex_data_ce_in,
    input                           id_ex_reg_we_in,
    input                           ex_mem_data_we_in,
    input                           ex_mem_data_ce_in,
    input                           ex_mem_reg_we_in,
    input [`PC_SEL_WIDTH - 1 : 0]   if_id_pc_sel_in,

    output                          stall_out

);

wire id_ex_mem_read;
wire ex_mem_mem_read;
wire is_branch;

assign is_branch = (if_id_pc_sel_in == `PC_BRANCH) ||
                   (if_id_pc_sel_in == `PC_JUMP) ||
                   (if_id_pc_sel_in == `PC_JUMP_R);

assign id_ex_mem_read = (~id_ex_data_we_in && id_ex_data_ce_in);
assign ex_mem_mem_read = (~ex_mem_data_we_in && ex_mem_data_ce_in);

assign stall_out = ((id_ex_reg_we_in) &&
                   (id_ex_mem_read || is_branch) &&
                   ((id_ex_rd_addr_in == if_id_rs1_addr_in) ||
                    (id_ex_rd_addr_in == if_id_rs2_addr_in))) ||
                   ((ex_mem_reg_we_in) &&
                   (ex_mem_mem_read && is_branch) &&
                   ((ex_mem_rd_addr_in == if_id_rs1_addr_in) ||
                    (ex_mem_rd_addr_in == if_id_rs2_addr_in)));

endmodule
