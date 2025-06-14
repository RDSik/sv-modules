vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv

vlog  ../rtl/axis_uart_pkg.svh
vlog  ../rtl/axis_uart_top.sv
vlog  ../rtl/axis_uart_tx.sv
vlog  ../rtl/axis_uart_rx.sv

vlog axis_uart_top_tb.sv

vsim -voptargs="+acc" axis_uart_top_tb
add log -r /*

add wave -expand -group UART_TX /axis_uart_top_tb/i_axis_uart_tx/*
add wave -expand -group UART_RX /axis_uart_top_tb/i_axis_uart_rx/*
add wave -expand -group M_AXIS  /axis_uart_top_tb/m_axis/*
add wave -expand -group S_AXIS  /axis_uart_top_tb/s_axis/*

run -all
wave zoom full
