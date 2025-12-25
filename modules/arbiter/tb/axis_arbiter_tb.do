vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv
vlog modules/common/rtl/axis_lfsr_wrap.sv
vlog modules/common/rtl/lfsr.sv
vlog modules/common/rtl/crc.sv

vlog modules/arbiter/rtl/axis_arbiter.sv
vlog modules/arbiter/rtl/round_robin_arbiter.sv

vlog modules/arbiter/tb/axis_arbiter_tb.sv

vsim -voptargs="+acc" axis_arbiter_tb
add log -r /*

add wave -expand -group TOP     /axis_arbiter_tb/dut/*
add wave -expand -group RR_ARB  /axis_arbiter_tb/dut/i_round_robin_arbiter/*
add wave -expand -group M_AXIS  /axis_arbiter_tb/dut/m_axis/*

run -all
wave zoom full