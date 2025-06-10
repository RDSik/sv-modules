TOP := axis_uart_top

PROJECT_DIR := project

SIM    ?= verilator
BOARD  ?= tangprimer20k
TB_DIR ?= axis_uart

MACRO_FILE := wave.do
TCL_FILE   := project.tcl

SRC_FILES := $(wildcard \
	modules/axis_uart/rtl/*.sv \
	modules/axis_uart/rtl/*.svh \
	modules/axis_spit/rtl/*.sv \
	modules/axis_spi/rtl/*.svh \
	modules/axis_spi/tb/*.sv \
	modules/fifo/rtl/*.sv \
	modules/fifo/tb/*.sv \
	modules/bmem/rtl/*.sv \
	modules/interface/rtl/*.sv \
	modules/verification/tb/*.sv \
	modules/verification/tb/*.svh \
)

.PHONY: sim project wave program clean

sim: build run

build:
ifeq ($(SIM), verilator)
	$(SIM) --binary $(SRC_FILES) --trace --top $(TOP)_tb
else ifeq ($(SIM), questa)
	vsim -do modules/$(TB_DIR)/tb/$(MACRO_FILE)
endif

run:
ifeq ($(SIM), verilator)
	./obj_dir/V$(TOP)_tb
endif

wave:
	gtkwave $(TOP)_tb.vcd

project: 
ifeq ($(BOARD), tangprimer20k)
	gw_sh $(PROJECT_DIR)/$(BOARD)/$(TCL_FILE)
else ifeq ($(BOARD), pz7020starlite)
	vivado -mode tcl -source $(PROJECT_DIR)/$(BOARD)/$(TCL_FILE)
endif

program:
	openFPGALoader -b $(BOARD) -m $(PROJECT_DIR)/$(TOP)/impl/pnr/$(TOP).fs

clean:
	rm -rf $(PROJECT_DIR)/$(TOP)
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).cache
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).hw
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).runs
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).sim
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).ip_user_files
	rm -rf $(PROJECT_DIR)/pz7020starlite/.Xil
	rm $(PROJECT_DIR)/pz7020starlite/$(TOP).xpr
	rm -rf obj_dir
	rm -rf work
	rm transcript
	rm *.vcd
	rm *.wlf
	rm *.log
	rm *.jou
