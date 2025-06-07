`timescale 1ps/1ps

module riscv_soc_tb();

  reg     clk;
  reg     rst;

  wire [31 : 0] reg_file_probe[0 : 31];

  task print_registers;
    integer i;
    begin
      $display("============ REGISTER FILE CONTENTS ============");
      for (i = 0; i < 32; i = i + 1) begin
        $display("x%0d 0x%08h", i, reg_file_probe[i]);
      end
      $display("===============================================");
    end
  endtask

  task print_memory;
  input [31:0] start_addr;
  input [31:0] end_addr;
  integer i;
  begin
    $display("============ MEMORY CONTENTS ============");
    $display("Address  | Value");
    $display("---------------------");
    for (i = start_addr; i <= end_addr; i = i + 1) begin
      $display("%4h     | %02h", i, data_mem0.data[i]);
    end
    $display("=========================================");
  end
endtask

  task dump_memory_to_file;
  input [31:0] start_addr;
  input [31:0] end_addr;
  integer file_handle;
  integer i;
  begin
    file_handle = $fopen("./build/data_mem_image.txt", "w");
    if (file_handle == 0) begin
      $display("Error: Could not open file for writing");
      $finish;
    end

    $display("Dumping memory from address 0x%h to 0x%h", start_addr, end_addr);

    for (i = start_addr; i <= end_addr; i = i + 1) begin
      $fdisplay(file_handle, "%4h: %02h", i, data_mem0.data[i]);
    end

    $fclose(file_handle);
    $display("Memory dump complete");
  end
endtask

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end
      
  initial begin
    rst = 1'b1;
    #30 rst= 1'b0;
    #100000 $display("---     result is %d         ---\n", verify);
    print_registers();
    print_memory(0, 32);
    dump_memory_to_file(0, 1024);
    if (reg_file_probe[27] != 32'h1) begin
      $display ("==========Error==========");
    end else begin
      $display ("==========Success==========");
    end
    #1000 $finish;
  end
       
  wire[31:0] inst_addr;
  wire[31:0] inst;
  wire 		 inst_ce;

  wire       data_ce;
  wire       data_we;
  wire[31:0] data_addr;
  wire[31:0] wdata;
  wire[31:0] rdata; 
  wire[31:0] verify; 
 

 riscv riscv0(
		.clk(clk),
		.rst(rst),
	
		.inst_addr_o(inst_addr),
		.inst_i(inst),
		.inst_ce_o(inst_ce),

		.data_ce_o(data_ce),	
		.data_we_o(data_we),
		.data_addr_o(data_addr),
		.data_i(rdata),
		.data_o(wdata)		
	);
	
	inst_mem inst_mem0(
		.ce(inst_ce),
		.addr(inst_addr),
		.inst(inst)	
	);

	data_mem data_mem0(
		.clk(clk),
		.ce(data_ce),
		.we(data_we),
		.addr(data_addr),
		.data_i(wdata),
		.data_o(rdata),
		.verify(verify)
	);

  genvar i;
  generate
    for (i = 0; i < 32; i = i + 1) begin : gen_reg_file_probe
      assign reg_file_probe[i] = riscv0.tinyrisc_top_inst.ID_u.regfile_u.reg_file[i];
    end
  endgenerate

  initial begin
    $dumpfile("./build/riscv_soc_tb.vcd");
    $dumpvars(0, riscv_soc_tb);
  end

endmodule
