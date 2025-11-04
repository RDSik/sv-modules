vlib work
vmap work

vlog ../../interface/rtl/axil_if.sv

vlog ../../common/rtl/axil_reg_file.sv

vlog ../rtl/axil_i2c.sv
vlog ../rtl/i2c_pkg.svh

vlog ../../opencores/rtl/i2c_master_bit_ctrl.v
vlog ../../opencores/rtl/i2c_master_byte_ctrl.v
vlog ../../opencores/rtl/i2c_master_defines.v
vlog ../../opencores/rtl/timescale.v

vlog axil_i2c_tb.sv

vsim -voptargs="+acc" axil_i2c_tb
add log -r /*

add wave -expand -group TOP      /axil_i2c_tb/i_axil_i2c/i_i2c_master_byte_ctrl/*
add wave -expand -group REG      /axil_i2c_tb/i_axil_i2c/i_axil_reg_file/*
add wave -expand -group AXIL     /axil_i2c_tb/i_axil_i2c/s_axil/*

run -all
wave zoom full
