SIMULATOR ?= iverilog


VERILOG_SRC += $(wildcard $(PWD)/src/*.v)
VERILOG_SRC += $(wildcard $(PWD)/src/*/*.v)
INC_DIR += $(wildcard $(PWD)/src/inc)
TEST_SRC += $(wildcard $(PWD)/test/riscv_soc_tb.v)
TOP = riscv_soc_tb


ifeq ($(SIMULATOR), iverilog)
    SIM_CMD = iverilog
    SIM_RUN = vvp
    COMPILE_ARGS = -o $(BIN) -s $(TOP) -D TEST_DATA_PATH=\"$(DATA_PATH)\" -D TEST_INST_PATH=\"$(INST_PATH)\" -I $(INC_DIR)
    SIM_ARGS = 
else ifeq ($(SIMULATOR), questa) 
    SIM_CMD = vlog
    SIM_RUN = vsim
    COMPILE_ARGS = -work $(QS_LIB_DIR) +define+TEST_DATA_PATH=\"$(DATA_PATH)\" +define+TEST_INST_PATH=\"$(INST_PATH)\" +incdir+$(INC_DIR)
    SIM_ARGS = -c -voptargs=+acc -l $(BUILD_DIR)/transcript -do "run -all;" $(TOP)
		SIM_WAVE_ARGS = -voptargs=+acc -l $(BUILD_DIR)/transcript -wlf $(BUILD_DIR)/$(TOP).wlf -do "log -r /*;run -all;" $(TOP)
else
    $(error simulator do not exist: $(SIMULATOR))
endif




DATA_PATH ?= test/data/data_mem.txt
INST_PATH ?= test/data/machinecode.txt


BUILD_DIR = build
QS_LIB_DIR = work

BIN = $(BUILD_DIR)/$(TOP).vvp



ifeq ($(SIMULATOR), iverilog)
$(BIN): $(VERILOG_SRC) $(TEST_SRC) | $(BUILD_DIR)
	$(SIM_CMD) $(COMPILE_ARGS) $(VERILOG_SRC) $(TEST_SRC) 
else ifeq ($(SIMULATOR), questa)
$(BIN): $(VERILOG_SRC) $(TEST_SRC) | $(QS_LIB_DIR)
	$(SIM_CMD) $(COMPILE_ARGS) $(VERILOG_SRC) $(TEST_SRC)
endif


$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(QS_LIB_DIR):
	-vlib $(QS_LIB_DIR)
	-vmap work $(QS_LIB_DIR)

.PHONY: init com clean sim wave

ifeq ($(SIMULATOR), iverilog)
init:
	mkdir -p $(BUILD_DIR)
else ifeq ($(SIMULATOR), questa)
init:
	vlib $(QS_LIB_DIR)
	vmap work $(QS_LIB_DIR)
endif

$(INST_PATH):
	cd test/assembler && ./assembler_linux
	cp test/assembler/machinecode.txt $(INST_PATH) -f

com: $(BIN) $(INST_PATH)


ifeq ($(SIMULATOR), iverilog)
sim: $(BIN) $(INST_PATH)
	$(SIM_RUN) $(BUILD_DIR)/$(TOP).vvp $(SIM_RUN_ARGS)
else ifeq ($(SIMULATOR), questa)
sim: $(BIN) $(INST_PATH)
	$(SIM_RUN) $(SIM_ARGS)
endif


ifeq ($(SIMULATOR), iverilog)
wave: $(BIN) $(INST_PATH)
	$(SIM_RUN) $(BUILD_DIR)/$(TOP).vvp $(SIM_RUN_ARGS);
	gtkwave $(BUILD_DIR)/$(TOP).vcd;
else ifeq ($(SIMULATOR), questa)
wave: $(BIN) $(INST_PATH)
	$(SIM_RUN) $(SIM_WAVE_ARGS)
endif

clean:
	rm -f  $(BUILD_DIR)/*
	rm test/data/machinecode.txt