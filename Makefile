SIMULATOR ?= iverilog


VERILOG_SRC += $(wildcard $(PWD)/src/*.v)
VERILOG_SRC += $(wildcard $(PWD)/src/*/*.v)
TEST_SRC += $(wildcard $(PWD)/test/riscv_soc_tb.v)
TOP = riscv_soc_tb


ifeq ($(SIMULATOR), iverilog)
    SIM_CMD = iverilog
    SIM_RUN = vvp
    COMPILE_ARGS = -o $(BIN) -s $(TOP) -D TEST_DATA_PATH=\"$(DATA_PATH)\" -D TEST_INST_PATH=\"$(INST_PATH)\"
    SIM_ARGS = 
else ifeq ($(SIMULATOR), questa) 
    SIM_CMD = vlog
    SIM_RUN = vsim
    COMPILE_ARGS = -work $(QS_LIB_DIR) +define+TEST_DATA_PATH=\"$(DATA_PATH)\" +define+TEST_INST_PATH=\"$(INST_PATH)\"
    SIM_ARGS = -c -voptargs=+acc -l $(BUILD_DIR)/transcript -do "run -all;" $(TOP)
		SIM_WAVE_ARGS = -voptargs=+acc -l $(BUILD_DIR)/transcript -wlf $(BUILD_DIR)/$(TOP).wlf -do "log -r /*;run -all;" $(TOP)
else
    $(error simulator do not exist: $(SIMULATOR))
endif



ifeq ($(SIMULATOR), iverilog)
DATA_PATH ?= ../test/data/data_mem.txt
INST_PATH ?= ../test/data/machinecode.txt
else ifeq ($(SIMULATOR), questa)
DATA_PATH ?= test/data/data_mem.txt
INST_PATH ?= test/data/machinecode.txt
endif


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

com: $(BIN)


ifeq ($(SIMULATOR), iverilog)
sim: $(BIN)
	cd $(BUILD_DIR) && $(SIM_RUN) $(TOP).vvp $(SIM_RUN_ARGS)
else ifeq ($(SIMULATOR), questa)
sim: $(BIN)
	$(SIM_RUN) $(SIM_ARGS)
endif


ifeq ($(SIMULATOR), iverilog)
wave: $(BIN)
	cd $(BUILD_DIR) && $(SIM_RUN) $(TOP).vvp $(SIM_RUN_ARGS);
	gtkwave $(BUILD_DIR)/$(TOP).vcd;
else ifeq ($(SIMULATOR), questa)
wave: $(BIN)
	$(SIM_RUN) $(SIM_WAVE_ARGS)
endif

clean:
	rm -f  $(BUILD_DIR)/*