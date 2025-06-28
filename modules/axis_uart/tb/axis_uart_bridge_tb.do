vlib work
vmap work

vlog ../../interface/rtl/axis_if.sv

vlog ../rtl/axis_uart_pkg.svh
vlog ../rtl/axis_uart_bram_ctrl.sv
vlog ../rtl/axis_uart_bridge.sv
vlog ../rtl/axis_uart_tx.sv
vlog ../rtl/axis_uart_rx.sv

vlog ../../fifo/rtl/async_fifo.sv
vlog ../../fifo/rtl/axis_fifo_wrap.sv
vlog ../../fifo/rtl/rd_ptr_empty.sv
vlog ../../fifo/rtl/shift_reg.sv
vlog ../../fifo/rtl/sync_fifo.sv
vlog ../../fifo/rtl/wr_ptr_full.sv

vlog ../../ram/rtl/bram_true_dp.sv
vlog ../../ram/rtl/ram_dp_2clk.sv
vlog ../../ram/rtl/ram_dp.sv
vlog ../../ram/rtl/ram.sv

vlog axis_uart_bridge_tb.sv

vsim -voptargs="+acc" axis_uart_bridge_tb
add log -r /*

add wave -expand -group BRAM_CTRL /axis_uart_bridge_tb/i_axis_uart_bram_ctrl/*
add wave -expand -group BRAM      /axis_uart_bridge_tb/i_bram_true_dp/*
add wave -expand -group FIFO_RX /axis_uart_bridge_tb/i_axis_uart_bram_ctrl/fifo_rx/*
add wave -expand -group UART_RX /axis_uart_bridge_tb/i_axis_uart_bram_ctrl/i_axis_uart_rx/*
add wave -expand -group FIFO_TX /axis_uart_bridge_tb/i_axis_uart_bram_ctrl/fifo_tx/*
add wave -expand -group UART_TX /axis_uart_bridge_tb/i_axis_uart_bram_ctrl/i_axis_uart_tx/*

run -all
wave zoom full
