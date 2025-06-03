// Arithmetic Logical Unit
`include "GlobalDefine.vh"
module ALU #(
    parameter DATA_WIDTH = 32
)(
    input [3 : 0] op_ctrl,

    input [DATA_WIDTH - 1 : 0] data_in_1,
    input [DATA_WIDTH - 1 : 0] data_in_2,

    output [DATA_WIDTH - 1 : 0] data_out,

    output zero
);

// ALUopcpde
localparam integer NONE = `ALU_NONE;
localparam integer ADD = `ALU_ADD;
localparam integer SUB = `ALU_SUB;
localparam integer AND = `ALU_AND;
localparam integer OR  = `ALU_OR;
localparam integer XOR = `ALU_XOR;
localparam integer SLL = `ALU_SLL;
localparam integer SRL = `ALU_SRL;
localparam integer LT  = `ALU_LT;
localparam integer LTU = `ALU_LTU;

wire carry;
wire overflow;


wire [DATA_WIDTH - 1 : 0] res_add_sub;
wire [DATA_WIDTH - 1 : 0] res_and;
wire [DATA_WIDTH - 1 : 0] res_or;
wire [DATA_WIDTH - 1 : 0] res_xor;
wire [DATA_WIDTH - 1 : 0] res_sll;
wire [DATA_WIDTH - 1 : 0] res_srl;

wire inv_1;
wire inv_2;

wire [DATA_WIDTH - 1 : 0] in_1;
wire [DATA_WIDTH - 1 : 0] in_2;

wire less_than;
wire less_than_unsigned;

assign inv_2 = ((op_ctrl == SUB) || (op_ctrl == LT) || (op_ctrl == LTU)) ? 1'b1 : 1'b0;

assign in_1 = data_in_1;
assign in_2 = (inv_2) ? (~data_in_2 + 1'b1) : data_in_2;

assign {carry, res_add_sub} = in_1 + in_2;
assign res_and = in_1 & in_2;
assign res_or = in_1 | in_2;
assign res_xor = in_1 ^ in_2;
assign res_sll = in_1 << in_2[4:0];
assign res_srl = in_1 >> in_2[4:0];


assign overflow = (in_1[DATA_WIDTH - 1] == in_2[DATA_WIDTH - 1]) && (res_add_sub[DATA_WIDTH - 1] != in_1[DATA_WIDTH - 1]);

assign less_than = (data_in_2 == {1'b1,{(DATA_WIDTH - 1){1'b0}}}) ? 1'b0 :
                   (~overflow) ? res_add_sub[DATA_WIDTH - 1] : in_1[DATA_WIDTH - 1];
assign less_than_unsigned = (|data_in_2) && (~carry);

assign data_out = (op_ctrl == NONE) ? data_in_2 :
                  (op_ctrl == ADD) ? res_add_sub :
                  (op_ctrl == SUB) ? res_add_sub :
                  (op_ctrl == AND) ? res_and :
                  (op_ctrl == OR)  ? res_or :
                  (op_ctrl == XOR) ? res_xor :
                  (op_ctrl == SLL) ? res_sll :
                  (op_ctrl == SRL) ? res_srl :
                  (op_ctrl == LT)  ? {{(DATA_WIDTH - 1){1'b0}}, (less_than)} :
                  (op_ctrl == LTU) ? {{(DATA_WIDTH - 1){1'b0}}, (less_than_unsigned)} : 0;

assign zero = ~(|data_out);

endmodule
