vlib work
vmap work

vlog  rtl/brom.sv
vlog  rtl/dds.sv
vlog  rtl/fir_filter.sv

vlog tb/fir_filter_tb.sv

vsim -voptargs="+acc" fir_filter_tb
add log -r /*

add wave -expand -group FIR_FILTER /fir_filter_tb/i_fir_filter/*
add wave -expand -group DDS_1      /fir_filter_tb/i_dds_1/*
add wave -expand -group DDS_2      /fir_filter_tb/i_dds_2/*

run -all
wave zoom full
