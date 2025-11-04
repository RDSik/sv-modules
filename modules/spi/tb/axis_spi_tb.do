vlib work
vmap work

vlog  ../../interface/rtl/axis_if.sv
vlog  ../../interface/rtl/spi_if.sv

vlog  ../rtl/axis_spi_master.sv
vlog  ../rtl/spi_shift.sv
vlog  ../rtl/spi_clk_gen.sv

vlog axis_spi_tb.sv

vsim -voptargs="+acc" axis_spi_tb
add log -r /*

add wave -expand -group SPI_MASSTER /axis_spi_tb/dut/*
add wave -expand -group M_AXIS      /axis_spi_tb/dut/m_axis/*
add wave -expand -group S_AXIS      /axis_spi_tb/dut/s_axis/*
add wave -expand -group SPI         /axis_spi_tb/dut/m_spi/*

run -all
wave zoom full