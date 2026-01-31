TOP := ps_pl_top
GUI ?= 1

DUT ?= top
IF  ?= axil
SIM ?= questa

MACRO_FILE := $(IF)_$(DUT)_tb.do

SRC_FILES := $(wildcard \
	../../verification/tb/*.svh \
	../../interface/rtl/*.sv \
	../../common/rtl/*.sv \
	../../fifo/rtl/*.sv \
	../../$(DUT)/rtl/*.sv \
	../../$(DUT)/rtl/*.svh \
	../../$(DUT)/tb/*.sv \
	../../$(DUT)/tb/*.svh \
)

BOARD ?= pz7020starlite

PROJECT_DIR := project
EDA_TCL     := project.tcl
SDK_TCL     := sdk.tcl

.PHONY: project program sdk sim clean

sim: build run

build:
ifeq ($(SIM), verilator)
	$(SIM) --binary $(SRC_FILES) --trace --top $(IF)_$(DUT)_tb
else ifeq ($(SIM), questa)
	vsim -do modules/$(DUT)/tb/$(MACRO_FILE)
endif

run:
ifeq ($(SIM), verilator)
	./obj_dir/V$(IF)_$(DUT)_tb
endif

wave:
	gtkwave $(IF)_$(DUT)_tb.vcd

project:
ifeq ($(BOARD), tangprimer20k)
	gw_sh $(PROJECT_DIR)/$(BOARD)/$(EDA_TCL)
else ifeq ($(BOARD), pz7020starlite)
	vivado -mode batch -source $(EDA_TCL) -tclargs $(PROJECT_DIR)/$(BOARD) $(GUI)
endif

sdk:
	xsdk -batch -source $(SDK_TCL) -tclargs $(PROJECT_DIR)/$(BOARD)
ifeq ($(GUI), 1)
	xsdk -workspace $(PROJECT_DIR)/$(BOARD)/$(TOP).sdk
endif

program:
	openFPGALoader -b $(BOARD) -m $(PROJECT_DIR)/$(TOP)/impl/pnr/$(TOP).fs

clean:
	rm -rf $(PROJECT_DIR)/$(TOP)
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).cache
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).hw
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).runs
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).sim
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).src
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).ip_user_files
	rm -rf $(PROJECT_DIR)/$(BOARD)/$(TOP).sdk
	rm -rf $(PROJECT_DIR)/$(BOARD)/.Xil
	rm $(PROJECT_DIR)/$(BOARD)/$(TOP).xpr
	rm *.log
	rm *.jou
