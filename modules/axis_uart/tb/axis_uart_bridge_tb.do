vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv

vlog modules/axis_uart/rtl/axis_uart_pkg.svh
vlog modules/axis_uart/rtl/axis_uart_bram_ctrl.sv
vlog modules/axis_uart/rtl/axis_uart_bridge.sv
vlog modules/axis_uart/rtl/axis_uart_tx.sv
vlog modules/axis_uart/rtl/axis_uart_rx.sv

vlog modules/fifo/rtl/async_fifo.sv
vlog modules/fifo/rtl/axis_fifo_wrap.sv
vlog modules/fifo/rtl/rd_ptr_empty.sv
vlog modules/fifo/rtl/shift_reg.sv
vlog modules/fifo/rtl/sync_fifo.sv
vlog modules/fifo/rtl/wr_ptr_full.sv

vlog modules/bmem/rtl/bram_true_dp.sv
vlog modules/bmem/rtl/bram_dp_2clk.sv
vlog modules/bmem/rtl/bram_dp.sv
vlog modules/bmem/rtl/brom.sv

vlog modules/axis_uart/tb/axis_uart_bridge_tb.sv

vsim -voptargs="+acc" axis_uart_bridge_tb
add log -r /*

add wave -expand -group TOP     /axis_uart_bridge_tb/dut/*
add wave -expand -group CTRL    /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/*
add wave -expand -group RAM     /axis_uart_bridge_tb/dut/i_bram_true_dp/*
add wave -expand -group UART_TX /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/i_axis_uart_tx/*
add wave                        /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/uart_tx/*
add wave -expand -group UART_RX /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/i_axis_uart_rx/*
add wave                        /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/uart_tx/*
add wave -expand -group FIFO_TX /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/i_axis_fifo_tx/*
add wave -expand -group FIFO_RX /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/i_axis_fifo_rx/*
add wave -expand -group S_AXIS  /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/s_axis/*
add wave -expand -group M_AXIS  /axis_uart_bridge_tb/dut/i_axis_uart_bram_ctrl/m_axis/*

run -all
wave zoom full
