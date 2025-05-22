// top of the tinyrisc CPU

module tinyrisc_top (
  input clk,
  input rst_n,
  
  input [`INST_WIDTH : 0] inst_in,
  output [`ADDR_WIDTH : 0] inst_addr_out,
  output inst_ce_out,

  input [`DATA_WIDTH - 1 : 0] data_in,
  output [`ADDR_WIDTH : 0] data_addr_out,
  output [`DATA_WIDTH - 1 : 0] data_out,
  output data_we_out,
  output data_ce_out 
);


// IF



endmodule