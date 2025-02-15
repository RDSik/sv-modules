vlib work
vmap work

vlog tb/axis_uart_top_tb.sv
vlog tb/axis_uart_top_if.sv
vlog tb/environment.sv
vlog src/axis_if.sv
vlog src/axis_uart_top.sv
vlog src/axis_uart_tx.sv
vlog src/axis_uart_rx.sv

vsim -voptargs="+acc" axis_uart_top_tb
add log -r /*

add wave -expand -group UART_TX sim:/axis_uart_top_tb/dut/i_axis_uart_tx/*
add wave -expand -group UART_RX sim:/axis_uart_top_tb/dut/i_axis_uart_rx/*

run -all
wave zoom full