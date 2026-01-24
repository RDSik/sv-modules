vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv

vlog modules/fifo/rtl/async_fifo.sv
vlog modules/fifo/rtl/axis_fifo.sv
vlog modules/fifo/rtl/fifo_wrap.sv
vlog modules/fifo/rtl/rd_ptr_empty.sv
vlog modules/fifo/rtl/sync_fifo.sv
vlog modules/fifo/rtl/wr_ptr_full.sv
vlog modules/common/rtl/ram_sdp.sv
vlog modules/common/rtl/shift_reg.sv

vlog modules/dw_conv/rtl/axis_dw_conv.sv
vlog modules/dw_conv/rtl/axis_dw_conv_wrap.sv

vlog modules/dw_conv/tb/axis_dw_conv_tb.sv

vsim -voptargs="+acc" axis_dw_conv_tb
add log -r /*

add wave -expand -group M_AXIS  /axis_dw_conv_tb/dut/m_axis/*
add wave -expand -group S_AXIS  /axis_dw_conv_tb/dut/s_axis/*

run -all
wave zoom full