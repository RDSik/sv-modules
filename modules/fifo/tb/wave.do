vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv

vlog modules/fifo/rtl/async_fifo.sv
vlog modules/fifo/rtl/axis_fifo_wrap.sv
vlog modules/fifo/rtl/rd_ptr_empty.sv
vlog modules/fifo/rtl/sync_fifo.sv
vlog modules/fifo/rtl/wr_ptr_full.sv
vlog modules/fifo/rtl/shift_reg.sv
vlog modules/bram/rtl/bram_dp.sv
vlog modules/bram/rtl/bram.sv

vlog modules/fifo/tb/axis_fifo_tb.sv

vsim -voptargs="+acc" axis_fifo_tb
add log -r /*

add wave -expand -group FIFO    /axis_fifo_tb/dut/g_fifo/i_fifo/*
add wave -expand -group M_AXIS  /axis_fifo_tb/dut/m_axis/*
add wave -expand -group S_AXIS  /axis_fifo_tb/dut/s_axis/*

run -all
wave zoom full