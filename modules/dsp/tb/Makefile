TOP ?= sfir

SIM ?= questa

MACRO_FILE := $(TOP)_tb.do

SRC_FILES := $(wildcard \
	../../ram/rtl/*.sv \
	../rtl/*.sv \
	./*.sv \
)

.PHONY: sim wave clean

sim: build run

build:
ifeq ($(SIM), verilator)
	$(SIM) --binary $(SRC_FILES) --trace --top $(TOP)_tb
else ifeq ($(SIM), questa)
	vsim -do $(MACRO_FILE)
endif

run:
ifeq ($(SIM), verilator)
	./obj_dir/V$(TOP)_tb
endif

wave:
	gtkwave $(TOP)_tb.vcd

clean:
	rm -rf obj_dir
	rm -rf work
	rm transcript
	rm *.vcd
	rm *.wlf
