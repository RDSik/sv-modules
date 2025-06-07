vlib work
vmap work

vlog  modules/interface/rtl/axis_if.sv

vlog  modules/axis_spi/rtl/axis_spi_pkg.svh
vlog  modules/axis_spi/rtl/axis_spi_master.sv

vlog modules/axis_spi/tb/axis_spi_top_tb.sv

vsim -voptargs="+acc" axis_spi_top_tb
add log -r /*

add wave -expand -group SPI_MASSTER /axis_spi_top_tb/dut/*
add wave -expand -group M_AXIS      /axis_spi_top_tb/dut/m_axis/*
add wave -expand -group S_AXIS      /axis_spi_top_tb/dut/s_axis/*

run -all
wave zoom full