vlib work
vmap work

vlog  ../../ram/rtl/shift_reg.sv
vlog  ../rtl/dds.sv
vlog  ../rtl/round.sv
vlog  ../rtl/sfir_even_symmetric_systolic_element.sv
vlog  ../rtl/sfir_even_symmetric_systolic_top.sv

vlog sfir_tb.sv

vsim -voptargs="+acc" sfir_tb
add log -r /*

add wave -expand -group SFIR_ /sfir_tb/i_sfir_even_symmetric_systolic_top/*
add wave -expand -group DDS_1 /sfir_tb/i_dds_1/*
add wave -expand -group DDS_2 /sfir_tb/i_dds_2/*

run -all
wave zoom full
