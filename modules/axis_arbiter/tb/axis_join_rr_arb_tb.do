vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv

vlog  ../rtl/axis_join_rr_arb.sv
vlog  ../rtl/axis_data_gen.sv

vlog axis_join_rr_arb_tb.sv

vsim -voptargs="+acc" axis_join_rr_arb_tb
add log -r /*

add wave -expand -group SPI_MASSTER /axis_join_rr_arb_tb/dut/*
add wave -expand -group M_AXIS      /axis_join_rr_arb_tb/dut/m_axis/*
add wave -expand -group S_AXIS      /axis_join_rr_arb_tb/dut/s_axis/*

run -all
wave zoom full