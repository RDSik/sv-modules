vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv
vlog  ../../interface/rtl/axil_if.sv
vlog  ../../interface/rtl/spi_if.sv

vlog ../../fifo/rtl/async_fifo.sv
vlog ../../fifo/rtl/axis_fifo_wrap.sv
vlog ../../fifo/rtl/fifo_wrap.sv
vlog ../../fifo/rtl/rd_ptr_empty.sv
vlog ../../fifo/rtl/sync_fifo.sv
vlog ../../fifo/rtl/wr_ptr_full.sv

vlog ../../arbiter/rtl/round_robin_arbiter.sv

vlog ../../common/rtl/ram_sdp.sv
vlog ../../common/rtl/shift_reg.sv
vlog ../../common/rtl/axil_reg_file.sv
vlog ../../common/rtl/axil_reg_file_wrap.sv
vlog ../../common/rtl/axil_crossbar.sv

vlog  ../../uart/rtl/axil_uart.sv
vlog  ../../uart/rtl/axis_uart_tx.sv
vlog  ../../uart/rtl/axis_uart_rx.sv
vlog  ../../uart/rtl/uart_pkg.svh

vlog  ../../spi/rtl/axil_spi.sv
vlog  ../../spi/rtl/axis_spi_master.sv
vlog  ../../spi/rtl/spi_pkg.svh

vlog ../../opencores/rtl/i2c_master_bit_ctrl.v
vlog ../../opencores/rtl/i2c_master_byte_ctrl.v
vlog ../../opencores/rtl/i2c_master_defines.v
vlog ../../opencores/rtl/timescale.v

vlog  ../../i2c/rtl/axil_i2c.sv
vlog  ../../i2c/rtl/i2c_pkg.svh

vlog ../rtl/axil_top.sv
vlog axil_top_tb.sv

vsim -voptargs="+acc" axil_top_tb
add log -r /*

add wave -expand -group CROSSBAR  /axil_top_tb/i_axil_top/i_axil_crossbar/*
add wave -expand -group UART      /axil_top_tb/i_axil_top/i_axil_uart/*
add wave -expand -group SPI       /axil_top_tb/i_axil_top/i_axil_spi/*
add wave -expand -group I2C       /axil_top_tb/i_axil_top/i_axil_i2c/*

run -all
wave zoom full