vlib work
vmap work

vlog ../../interface/rtl/axis_if.sv

vlog ../rtl/async_fifo.sv
vlog ../rtl/axis_fifo_wrap.sv
vlog ../rtl/rd_ptr_empty.sv
vlog ../rtl/sync_fifo.sv
vlog ../rtl/wr_ptr_full.sv
vlog ../rtl/shift_reg.sv
vlog ../../common/rtl/ram_dp.sv
vlog ../../common/rtl/ram_dp_2clk.sv

vlog axis_fifo_tb.sv

vsim -voptargs="+acc" axis_fifo_tb
add log -r /*

add wave -expand -group FIFO    /axis_fifo_tb/dut/g_fifo/i_fifo/*
add wave -expand -group M_AXIS  /axis_fifo_tb/dut/m_axis/*
add wave -expand -group S_AXIS  /axis_fifo_tb/dut/s_axis/*

run -all
wave zoom full