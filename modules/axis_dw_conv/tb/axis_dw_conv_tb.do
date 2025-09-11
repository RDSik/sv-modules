vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv

vlog  ../rtl/axis_dw_conv.sv

vlog axis_dw_conv_tb.sv

vsim -voptargs="+acc" axis_dw_conv_tb
add log -r /*

add wave -expand -group DW_CONV /axis_dw_conv_tb/dut/*
add wave -expand -group M_AXIS  /axis_dw_conv_tb/dut/m_axis/*
add wave -expand -group S_AXIS  /axis_dw_conv_tb/dut/s_axis/*

run -all
wave zoom full