module riscv(

	input wire				 clk,
	input wire				 rst,         // high is reset
	
    // inst_mem
	input wire[31:0]         inst_i,
	output wire[31:0]        inst_addr_o,
	output wire              inst_ce_o,

    // data_mem
	input wire[31:0]         data_i,      // load data from data_mem
	output wire              data_we_o,
    output wire              data_ce_o,
	output wire[31:0]        data_addr_o,
	output wire[31:0]        data_o       // store data to  data_mem

);

//  instance your module  below

wire rst_n;
assign rst_n = ~rst;

tinyrisc_top tinyrisc_top_inst(
    .clk(clk),
    .rst_n(rst_n),
    
    // inst_mem
    .inst_in(inst_i),
    .inst_addr_out(inst_addr_o),
    .inst_ce_out(inst_ce_o),

    // data_mem
    .data_rd_in(data_i),
    .data_we_out(data_we_o),
    .data_ce_out(data_ce_o),
    .data_addr_out(data_addr_o),
    .data_wr_out(data_o)
);




endmodule