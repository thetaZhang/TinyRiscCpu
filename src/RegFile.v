// register file

module RegFile #(
  parameter integer ADDR_WIDTH = 5,
  parameter integer DATA_WIDTH = 64
) (
  input clk,
  input rst_n,

  input [ADDR_WIDTH - 1 : 0] addr_wr,
  input [DATA_WIDTH - 1 : 0] data_wr,

  input [ADDR_WIDTH - 1 : 0] addr_rd_1,
  output [DATA_WIDTH - 1 : 0] data_rd_1,

  input [ADDR_WIDTH - 1 : 0] addr_rd_2,
  output [DATA_WIDTH - 1 : 0] data_rd_2
);

localparam integer REG_FILE_SIZE = 2**ADDR_WIDTH;

wire [DATA_WIDTH - 1 : 0] reg_file [0 : REG_FILE_SIZE - 1];

assign reg_file[0] = {DATA_WIDTH{1'b0}};

genvar i;
generate
  for (i = 1; i < REG_FILE_SIZE; i = i + 1) begin : gen_reg
    wire [DATA_WIDTH - 1 : 0] reg_file_in;
    assign reg_file_in = (i == addr_wr) ? data_wr : reg_file[i];
    DffNegRst #(DATA_WIDTH) u_reg (clk, rst_n, reg_file_in, reg_file[i]);
  end
endgenerate

DffNegRst #(DATA_WIDTH) u_reg_rd_1 (clk, rst_n, reg_file[addr_rd_1], data_rd_1);
DffNegRst #(DATA_WIDTH) u_reg_rd_2 (clk, rst_n, reg_file[addr_rd_2], data_rd_2);


endmodule
