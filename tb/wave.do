vlib work
vmap work

vlog tb/axis_uart_top_tb.sv
vlog tb/axis_uart_top_if.sv
vlog tb/environment.sv
vlog rtl/axis_if.sv
vlog rtl/axis_uart_top.sv
vlog rtl/axis_uart_tx.sv
vlog rtl/axis_uart_rx.sv

vsim -voptargs="+acc" axis_uart_top_tb
add log -r /*

add wave -expand -group UART_TX /axis_uart_top_tb/dut/i_axis_uart_tx/*
add wave -expand -group UART_RX /axis_uart_top_tb/dut/i_axis_uart_rx/*
add wave -expand -group AXIS /axis_uart_top_tb/dut/axis/*

run -all
wave zoom full
