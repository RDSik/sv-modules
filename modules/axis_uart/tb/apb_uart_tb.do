vlib work
vmap work

vlog ../../interface/rtl/axis_if.sv
vlog ../../interface/rtl/apb_if.sv

vlog ../rtl/uart_pkg.svh
vlog ../rtl/apb_uart.sv
vlog ../rtl/axis_uart_tx.sv
vlog ../rtl/axis_uart_rx.sv

vlog ../../fifo/rtl/async_fifo.sv
vlog ../../fifo/rtl/axis_fifo_wrap.sv
vlog ../../fifo/rtl/rd_ptr_empty.sv
vlog ../../fifo/rtl/sync_fifo.sv
vlog ../../fifo/rtl/wr_ptr_full.sv

vlog ../../ram/rtl/ram_dp_2clk.sv
vlog ../../ram/rtl/ram_dp.sv
vlog ../../ram/rtl/shift_reg.sv
vlog ../../ram/rtl/apb_reg_file.sv

vlog apb_uart_tb.sv

vsim -voptargs="+acc" apb_uart_tb
add log -r /*

add wave -expand -group TOP     /apb_uart_tb/i_apb_uart/*
add wave -expand -group APB     /apb_uart_tb/i_apb_uart/s_apb/*
add wave -expand -group FIFO_RX /apb_uart_tb/i_apb_uart/i_axis_fifo_rx/*
add wave -expand -group UART_RX /apb_uart_tb/i_apb_uart/i_axis_uart_rx/*
add wave -expand -group FIFO_TX /apb_uart_tb/i_apb_uart/i_axis_fifo_tx/*
add wave -expand -group UART_TX /apb_uart_tb/i_apb_uart/i_axis_uart_tx/*

run -all
wave zoom full
