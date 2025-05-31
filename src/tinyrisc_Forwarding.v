// forwarding unit
`include "GlobalDefine.vh"
`define EX_HZD_1 (id_ex_pc_sel_in == `PC_PLUS4) && \
                 (ex_mem_reg_we_in) && \
                 (ex_mem_rd_in != 0) && \
                 ((ex_mem_rd_in == id_ex_rs1_addr_in))
`define EX_HZD_2 (id_ex_pc_sel_in == `PC_PLUS4) && \
                 (ex_mem_reg_we_in) && \
                 (ex_mem_rd_in != 0) && \
                 ((ex_mem_rd_in == id_ex_rs2_addr_in))

`define MEM_HZD_1 (id_ex_pc_sel_in == `PC_PLUS4) && \
                  (mem_wb_reg_we_in) && \
                  (mem_wb_rd_in != 0) && \
                  (!(`EX_HZD_1)) && \
                  ((mem_wb_rd_in == id_ex_rs1_addr_in))
`define MEM_HZD_2 (id_ex_pc_sel_in == `PC_PLUS4) && \
                  (mem_wb_reg_we_in) && \
                  (mem_wb_rd_in != 0) && \
                  (!(`EX_HZD_2)) && \
                  ((mem_wb_rd_in == id_ex_rs2_addr_in))

`define MEM_STR_HZD (mem_wb_reg_we_in) && \
                    (mem_wb_rd_in != 0) && \
                    (mem_wb_mem_to_reg_in) && \
                    (ex_mem_data_we_in) && \
                    (ex_mem_data_ce_in) && \
                    ((mem_wb_rd_in == ex_mem_rs2_addr_in))

`define ID_BRC_HZD_1 (if_id_pc_sel_in != `PC_PLUS4) && \
                     (ex_mem_reg_we_in) && \
                     (ex_mem_rd_in != 0) && \
                     ((ex_mem_rd_in == if_id_rs1_addr_in))
`define ID_BRC_HZD_2 (if_id_pc_sel_in != `PC_PLUS4) && \
                     (ex_mem_reg_we_in) && \
                     (ex_mem_rd_in != 0) && \
                     ((ex_mem_rd_in == if_id_rs2_addr_in))

module tinyrisc_Forwarding(
    input [`PC_SEL_WIDTH - 1 : 0]   id_ex_pc_sel_in,
    input [`PC_SEL_WIDTH - 1 : 0]   if_id_pc_sel_in,
    input [`REG_ADDR_WIDTH - 1 : 0] ex_mem_rd_in,
    input [`REG_ADDR_WIDTH - 1 : 0] mem_wb_rd_in,
    input [`REG_ADDR_WIDTH - 1 : 0] if_id_rs1_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] if_id_rs2_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] id_ex_rs1_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] id_ex_rs2_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] ex_mem_rs2_addr_in,
    input                           ex_mem_reg_we_in,
    input                           mem_wb_reg_we_in,
    input                           mem_wb_mem_to_reg_in,
    input                           ex_mem_data_we_in,
    input                           ex_mem_data_ce_in,

    output [`FWD_WIDTH - 1 : 0]    id_rs1_fwd_out,
    output [`FWD_WIDTH - 1 : 0]    id_rs2_fwd_out,
    output [`FWD_WIDTH - 1 : 0]    ex_rs1_fwd_out,
    output [`FWD_WIDTH - 1 : 0]    ex_rs2_fwd_out,
    output [`FWD_WIDTH - 1 : 0]    mem_rs2_fwd_out

);

  assign ex_rs1_fwd_out = (`EX_HZD_1) ? `EX_FWD_MEM :
                          (`MEM_HZD_1) ? `EX_FWD_WB :
                          `FWD_NONE;

  assign ex_rs2_fwd_out = (`EX_HZD_2) ? `EX_FWD_MEM :
                          (`MEM_HZD_2) ? `EX_FWD_WB :
                          `FWD_NONE;

  assign mem_rs2_fwd_out = (`MEM_STR_HZD) ? `MEM_FWD_WB : `MEM_FWD_NONE;

  assign id_rs1_fwd_out = (`ID_BRC_HZD_1) ? `ID_FWD_MEM : `ID_FWD_NONE;
  assign id_rs2_fwd_out = (`ID_BRC_HZD_2) ? `ID_FWD_MEM : `ID_FWD_NONE;

endmodule