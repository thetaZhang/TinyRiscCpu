// Stall unit
`include "GlobalDefine.vh"

module tinyrisc_Stalling(
    input [`REG_ADDR_WIDTH - 1 : 0] id_ex_rd_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] if_id_rs1_addr_in,
    input [`REG_ADDR_WIDTH - 1 : 0] if_id_rs2_addr_in,
    input                           id_ex_data_we_in,
    input                           id_ex_data_ce_in,

    output                          stall_out

);

wire id_ex_mem_read;

assign id_ex_mem_read = (~id_ex_data_we_in && id_ex_data_ce_in);

assign stall_out = id_ex_mem_read &&
                   ((id_ex_rd_addr_in == if_id_rs1_addr_in) ||
                    (id_ex_rd_addr_in == if_id_rs2_addr_in));

endmodule
