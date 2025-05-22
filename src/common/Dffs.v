// Dffs.v


// Dff with asynchronous negative edge reset
module DffNegRst #(
    parameter DATA_WIDTH = 1,
    parameter RST_VALUE = {DATA_WIDTH{1'b0}}
) (
    input clk,
    input rst_n,

    input  [DATA_WIDTH - 1 : 0] d,
    output [DATA_WIDTH - 1 : 0] q
);

  reg [DATA_WIDTH - 1 : 0] q_reg;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) q_reg <= RST_VALUE;
    else q_reg <= d;
  end

  assign q = q_reg;

endmodule

// Dff with asynchronous negative edge reset and enable
module DffNegRstEn #(
    parameter DATA_WIDTH = 1,
    parameter RST_VALUE = {DATA_WIDTH{1'b0}}
) (
    input clk,
    input rst_n,
    input en,

    input  [DATA_WIDTH - 1 : 0] d,
    output [DATA_WIDTH - 1 : 0] q
);

  reg [DATA_WIDTH - 1 : 0] q_reg;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) q_reg <= RST_VALUE;
    else if (en) q_reg <= d;
  end

  assign q = q_reg;

endmodule

// Dff with asynchronous negative edge reset, enable, and synchronous clear
module DffNegRstEnClr #(
    parameter DATA_WIDTH = 1,
    parameter RST_VALUE = {DATA_WIDTH{1'b0}}
) ( 
    input clk,
    input rst_n,
    input en,
    input clr,

    input  [DATA_WIDTH - 1 : 0] d,
    output [DATA_WIDTH - 1 : 0] q
);

  reg [DATA_WIDTH - 1 : 0] q_reg;

  always @(posedge clk or negedge rst_n) begin
    if (~rst_n) q_reg <= RST_VALUE;
    else if (clr) q_reg <= {DATA_WIDTH{1'b0}};
    else if (en) q_reg <= d;
  end

  assign q = q_reg;

endmodule
