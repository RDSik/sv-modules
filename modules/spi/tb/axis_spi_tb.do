vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv
vlog modules/interface/rtl/spi_if.sv

vlog modules/spi/rtl/axis_spi_master.sv

vlog modules/spi/tb/axis_spi_tb.sv

vsim -voptargs="+acc" axis_spi_tb
add log -r /*

add wave -expand -group SPI_MASSTER /axis_spi_tb/dut/*
add wave -expand -group M_AXIS      /axis_spi_tb/dut/m_axis/*
add wave -expand -group S_AXIS      /axis_spi_tb/dut/s_axis/*
add wave -expand -group SPI         /axis_spi_tb/dut/m_spi/*

run -all
wave zoom full