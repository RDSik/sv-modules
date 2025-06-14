TOP := axis_uart_top

PROJECT_DIR := project

BOARD  ?= tangprimer20k

TCL_FILE := project.tcl

.PHONY: project program clean

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
	rm *.log
	rm *.jou
