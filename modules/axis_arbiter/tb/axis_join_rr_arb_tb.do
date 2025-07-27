vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv

vlog  ../rtl/axis_join_rr_arb.sv
vlog  ../rtl/axis_lfsr.sv

vlog axis_join_rr_arb_tb.sv

vsim -voptargs="+acc" axis_join_rr_arb_tb
add log -r /*

add wave -expand -group SPI_MASSTER /axis_join_rr_arb_tb/i_axis_join_rr_arb/*
add wave -expand -group M_AXIS      /axis_join_rr_arb_tb/i_axis_join_rr_arb/m_axis/*
add wave -expand -group S_AXIS      /axis_join_rr_arb_tb/i_axis_join_rr_arb/s_axis/*

run -all
wave zoom full