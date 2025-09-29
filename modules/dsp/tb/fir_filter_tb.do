vlib work
vmap work

vlog  ../../common/rtl/shift_reg.sv
vlog  ../rtl/dds.sv
vlog  ../rtl/fir_filter.sv
vlog  ../rtl/sfir_even_symmetric_systolic_top.sv

vlog fir_filter_tb.sv

vsim -voptargs="+acc" fir_filter_tb
add log -r /*

add wave -expand -group FIR   /fir_filter_tb/i_fir_filter/*
add wave -expand -group SFIR  /fir_filter_tb/i_sfir/*
add wave -expand -group DDS_0 /fir_filter_tb/g_dds[0]/i_dds/*
add wave -expand -group DDS_1 /fir_filter_tb/g_dds[1]/i_dds/*

run -all
wave zoom full
