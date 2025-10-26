vlib work
vmap work

vlog ../../interface/rtl/axis_if.sv
vlog ../../interface/rtl/axil_if.sv

vlog ../rtl/uart_pkg.svh
vlog ../rtl/axil_uart.sv
vlog ../rtl/axis_uart_tx.sv
vlog ../rtl/axis_uart_rx.sv

vlog ../../fifo/rtl/async_fifo.sv
vlog ../../fifo/rtl/axis_fifo_wrap.sv
vlog ../../fifo/rtl/rd_ptr_empty.sv
vlog ../../fifo/rtl/sync_fifo.sv
vlog ../../fifo/rtl/wr_ptr_full.sv

vlog ../../common/rtl/ram_sdp.sv
vlog ../../common/rtl/shift_reg.sv
vlog ../../common/rtl/axil_reg_file.sv

vlog axil_uart_tb.sv

vsim -voptargs="+acc" axil_uart_tb
add log -r /*

add wave -expand -group TOP      /axil_uart_tb/*
add wave -expand -group FIFO_RX  /axil_uart_tb/i_axil_uart/i_axis_fifo_rx/*
add wave -expand -group UART_RX  /axil_uart_tb/i_axil_uart/i_axis_uart_rx/*
add wave -expand -group FIFO_TX  /axil_uart_tb/i_axil_uart/i_axis_fifo_tx/*
add wave -expand -group UART_TX  /axil_uart_tb/i_axil_uart/i_axis_uart_tx/*
add wave -expand -group REG_FILE /axil_uart_tb/i_axil_uart/i_axil_reg_file/*
add wave -expand -group AXIL     /axil_uart_tb/i_axil_uart/s_axil/*

run -all
wave zoom full
