// memory model for data or instruction memory

module InstrMemoryModel # (
  parameter integer ADDR_WIDTH = 64,
  parameter integer INSTR_WIDTH = 32
) (
  input [ADDR_WIDTH - 1 : 0] addr_in,
  output [INSTR_WIDTH - 1 : 0] instr_out
);

localparam integer MEM_SIZE = 2**ADDR_WIDTH;

reg [INSTR_WIDTH - 1 : 0] mem [0 : 2**MEM_SIZE - 1];

assign instr_out = mem[addr_in];

endmodule


module DataMemoryModel # (
  parameter integer ADDR_WIDTH = 64,
  parameter integer DATA_WIDTH = 64
) (

  input clk,
  input rst_n,

  input [ADDR_WIDTH - 1 : 0] addr_in,
  input [DATA_WIDTH - 1 : 0] data_in,
  input write_en,
  output [DATA_WIDTH - 1 : 0] data_out
);

localparam integer MEM_SIZE = 2**ADDR_WIDTH;

reg [DATA_WIDTH - 1 : 0] mem [0 : 2**MEM_SIZE - 1];
reg [DATA_WIDTH - 1 : 0] data_out_reg;

assign data_out = data_out_reg;

always @(posedge clk or negedge rst_n) begin
  if (~rst_n)
    data_out_reg <= {DATA_WIDTH{1'b0}};
  else if (write_en)
    data_out_reg <= data_out_reg;
  else
    data_out_reg <= mem[addr_in];
end

always @(posedge clk) begin
  if (write_en)
    mem[addr_in] <= data_in;
end


endmodule 


