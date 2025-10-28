vlib work
vmap work

vlog  ../rtl/dds.sv
vlog  ../../common/rtl/write_data_to_file.sv

vlog dds_tb.sv

vsim -voptargs="+acc" dds_tb
add log -r /*

add wave -expand -group DDS /dds_tb/dut/*

run -all
wave zoom full
