VERILOG_SRC += $(wildcard $(PWD)/src/*.v)
VERILOG_SRC += $(wildcard $(PWD)/src/*/*.v)
TEST_SRC += $(wildcard $(PWD)/test/riscv_soc_tb.v)
TOP = riscv_soc_tb

DATA_PATH ?= test/data/data_mem.txt
INST_PATH ?= test/data/machinecode.txt

COMPILE_ARGS += -D TEST_DATA_PATH=\"$(DATA_PATH)\" -D TEST_INST_PATH=\"$(INST_PATH)\"

BIN = $(TOP).vvp

$(BIN): $(VERILOG_SRC) $(TEST_SRC)
	iverilog $(COMPILE_ARGS) -o $(BIN) -s $(TOP) $(VERILOG_SRC) $(TEST_SRC)

.PHONY: all clean test

all: $(BIN)

sim: $(BIN)
	vvp $(BIN)

clean:
	rm -f *.vvp *.vcd