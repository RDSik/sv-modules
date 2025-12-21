vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv
vlog  ../../common/rtl/axis_lfsr_wrap.sv
vlog  ../../common/rtl/lfsr.sv
vlog  ../../common/rtl/crc.sv

vlog  ../rtl/axis_rr_arb_wrap.sv
vlog  ../rtl/round_robin_arbiter.sv

vlog axis_rr_arb_tb.sv

vsim -voptargs="+acc" axis_rr_arb_tb
add log -r /*

add wave -expand -group TOP     /axis_rr_arb_tb/dut/*
add wave -expand -group RR_ARB  /axis_rr_arb_tb/dut/i_round_robin_arbiter/*
add wave -expand -group M_AXIS  /axis_rr_arb_tb/dut/m_axis/*

run -all
wave zoom full