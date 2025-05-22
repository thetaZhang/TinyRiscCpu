// Arithmetic Logical Unit

module ALU #(
    parameter DATA_WIDTH = 32
)(
    input [3 : 0] op_ctrl,

    input [DATA_WIDTH - 1 : 0] data_in_1,
    input [DATA_WIDTH - 1 : 0] data_in_2,

    output [DATA_WIDTH - 1 : 0] data_out,

    output zero,
    output carry,
    output overflow
);

// ALUopcpde
localparam integer ADD = 4'b0000;
localparam integer SUB = 4'b0001;
localparam integer AND = 4'b0010;
localparam integer OR  = 4'b0011;
localparam integer XOR = 4'b0100;
localparam integer LT = 4'b0101;
localparam integer NE = 4'b0110;
localparam integer LTU = 4'b0111;




wire [DATA_WIDTH - 1 : 0] res_add_sub;
wire [DATA_WIDTH - 1 : 0] res_and;
wire [DATA_WIDTH - 1 : 0] res_or;
wire [DATA_WIDTH - 1 : 0] res_xor;

wire inv_1;
wire inv_2;

wire [DATA_WIDTH - 1 : 0] in_1;
wire [DATA_WIDTH - 1 : 0] in_2;

wire less_than;
wire less_than_unsigned;

assign inv_2 = ((op_ctrl == SUB) || (op_ctrl == LT) || (op_ctrl == NE) || (op_ctrl == LTU)) ? 1'b1 : 1'b0;

assign in_1 = data_in_1;
assign in_2 = (inv_2) ? (~data_in_2 + 1'b1) : data_in_2;

assign {carry, res_add_sub} = in_1 + in_2;
assign res_and = in_1 & in_2;
assign res_or = in_1 | in_2;
assign res_xor = in_1 ^ in_2;

assign zero = ~(|res_add_sub);
assign overflow = (in_1[DATA_WIDTH - 1] == in_2[DATA_WIDTH - 1]) && (res_add_sub[DATA_WIDTH - 1] != in_1[DATA_WIDTH - 1]);

assign less_than = (data_in_2 == {1'b1,{(DATA_WIDTH - 1){1'b0}}}) ? 1'b0 :
                   (~overflow) ? res_add_sub[DATA_WIDTH - 1] : in_1[DATA_WIDTH - 1];
assign less_than_unsigned = (|data_in_2) && (~carry);

assign data_out = (op_ctrl == ADD) ? res_add_sub :
                  (op_ctrl == SUB) ? res_add_sub :
                  (op_ctrl == AND) ? res_and :
                  (op_ctrl == OR)  ? res_or :
                  (op_ctrl == XOR) ? res_xor :
                  (op_ctrl == LT)  ? {{(DATA_WIDTH - 1){1'b0}}, (less_than)} :
                  (op_ctrl == LTU) ? {{(DATA_WIDTH - 1){1'b0}}, (less_than_unsigned)} : 0;

endmodule
