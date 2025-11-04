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

vlog ../../common/rtl/ram_sdp.sv
vlog ../../common/rtl/shift_reg.sv
vlog ../../common/rtl/axil_reg_file.sv

vlog  ../rtl/axil_spi.sv
vlog  ../rtl/axis_spi_master.sv
vlog  ../rtl/spi_pkg.svh

vlog axil_spi_tb.sv

vsim -voptargs="+acc" axil_spi_tb
add log -r /*

add wave -expand -group SPI_MASTER /axil_spi_tb/i_axil_spi/i_axis_spi_master/*
add wave -expand -group FIFO_RX    /axil_spi_tb/i_axil_spi/fifo_rx/*
add wave -expand -group FIFO_TX    /axil_spi_tb/i_axil_spi/fifo_tx/*
add wave -expand -group REG_FILE   /axil_spi_tb/i_axil_spi/i_axil_reg_file/*
add wave -expand -group AXIL       /axil_spi_tb/i_axil_spi/s_axil/*
add wave -expand -group SPI        /axil_spi_tb/i_axil_spi/m_spi/*

run -all
wave zoom full