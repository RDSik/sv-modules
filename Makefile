TOP := axis_uart_top

SRC_DIR     := src
TB_DIR      := tb
PROJECT_DIR := project

SIM     ?= verilator
BOARD   ?= tangprimer20k
PROGRAM := openFPGALoader

MACRO_FILE := wave.do
TCL        := project.tcl

SRC_FILES += $(SRC_DIR)/axis_uart_top.sv
SRC_FILES += $(SRC_DIR)/axis_if.sv
SRC_FILES += $(SRC_DIR)/axis_uart_rx.sv
SRC_FILES += $(SRC_DIR)/axis_uart_tx.sv

SRC_FILES += $(TB_DIR)/axis_uart_top_tb.sv
SRC_FILES += $(TB_DIR)/axis_uart_top_if.sv
SRC_FILES += $(TB_DIR)/environment.sv

.PHONY: all project program clean

all: build run wave

build:
ifeq ($(SIM), verilator)
	$(SIM) --binary $(SRC_FILES) --trace -I$(SRC_DIR) -I$(TB_DIR) --top $(TOP)_tb
else ifeq ($(SIM), questa)
	vsim -do $(TB_DIR)/$(MACRO_FILE)
endif

run:
	./obj_dir/V$(TOP)_tb

wave:
	gtkwave $(TOP)_tb.vcd

project: 
	gw_sh $(PROJECT_DIR)/$(TCL)

program:
	$(PROGRAM) -b $(BOARD) -m $(PROJECT_DIR)/$(TOP)/impl/pnr/$(TOP).fs

clean:
ifeq ($(OS), Windows_NT)
	rmdir /s /q $(PROJECT_DIR)\$(TOP)
	rmdir /s /q work
	del *.vcd
else
	rm -rf $(PROJECT_DIR)/$(TOP)
	rm -rf obj_dir
	rm -rf work
	rm *.vcd
endif