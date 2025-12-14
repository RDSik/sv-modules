TOP := ps_pl_top
GUI ?= 1

PROJECT_DIR := project

BOARD ?= pz7020starlite

VIVADO_TCL := project.tcl
SDK_TCL    := sdk_project.tcl

.PHONY: project program clean

project:
ifeq ($(BOARD), tangprimer20k)
	gw_sh $(PROJECT_DIR)/$(BOARD)/$(VIVADO_TCL)
else ifeq ($(BOARD), pz7020starlite)
	vivado -mode batch -source $(PROJECT_DIR)/$(BOARD)/$(VIVADO_TCL) -tclargs $(GUI)
endif

sdk:
	xsct $(PROJECT_DIR)/$(BOARD)/$(SDK_TCL)

program:
	openFPGALoader -b $(BOARD) -m $(PROJECT_DIR)/$(TOP)/impl/pnr/$(TOP).fs

clean:
	rm -rf $(PROJECT_DIR)/$(TOP)
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).cache
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).hw
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).runs
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).sim
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).src
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).ip_user_files
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).sdk
	rm -rf $(PROJECT_DIR)/pz7020starlite/.Xil
	rm $(PROJECT_DIR)/pz7020starlite/$(TOP).xpr
	rm *.log
	rm *.jou
