vlib work
vmap work

vlog ../../interface/rtl/axil_if.sv
vlog ../../interface/rtl/wb_if.sv

vlog ../../common/rtl/axil2wb_bridge.sv

vlog ../rtl/axil_i2c.sv

vlog ../../opencores/rtl/i2c_master_bit_ctrl.v
vlog ../../opencores/rtl/i2c_master_byte_ctrl.v
vlog ../../opencores/rtl/i2c_master_defines.v
vlog ../../opencores/rtl/i2c_master_top.v
vlog ../../opencores/rtl/timescale.v

vlog axil_i2c_tb.sv

vsim -voptargs="+acc" axil_i2c_tb
add log -r /*

add wave -expand -group TOP      /axil_i2c_tb/i_axil_i2c/i_i2c_master_top/*
add wave -expand -group AXIL     /axil_i2c_tb/i_axil_i2c/s_axil/*
add wave -expand -group WB       /axil_i2c_tb/i_axil_i2c/m_wb/*

run -all
wave zoom full
