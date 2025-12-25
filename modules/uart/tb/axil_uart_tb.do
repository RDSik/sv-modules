vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv
vlog modules/interface/rtl/axil_if.sv

vlog modules/uart/rtl/uart_pkg.svh
vlog modules/uart/rtl/axil_uart.sv
vlog modules/uart/rtl/axis_uart_tx.sv
vlog modules/uart/rtl/axis_uart_rx.sv

vlog modules/fifo/rtl/async_fifo.sv
vlog modules/fifo/rtl/axis_fifo.sv
vlog modules/fifo/rtl/fifo_wrap.sv
vlog modules/fifo/rtl/rd_ptr_empty.sv
vlog modules/fifo/rtl/sync_fifo.sv
vlog modules/fifo/rtl/wr_ptr_full.sv

vlog modules/common/rtl/ram_sdp.sv
vlog modules/common/rtl/shift_reg.sv
vlog modules/common/rtl/axil_reg_file.sv
vlog modules/common/rtl/axil_reg_file_wrap.sv

vlog modules/uart/tb/axil_uart_tb.sv

vsim -voptargs="+acc" axil_uart_tb
add log -r /*

add wave -expand -group UART_RX  /axil_uart_tb/i_axil_uart/i_axis_uart_rx/*
add wave -expand -group UART_TX  /axil_uart_tb/i_axil_uart/i_axis_uart_tx/*
add wave -expand -group FIFO_RX  /axil_uart_tb/i_axil_uart/fifo_rx/*
add wave -expand -group FIFO_TX  /axil_uart_tb/i_axil_uart/fifo_tx/*
add wave -expand -group REG_FILE /axil_uart_tb/i_axil_uart/i_axil_reg_file/g_sync_mode/i_axil_reg_file/*
add wave -expand -group AXIL     /axil_uart_tb/i_axil_uart/s_axil/*

run -all
wave zoom full
