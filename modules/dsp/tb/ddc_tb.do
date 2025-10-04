vlib work
vmap work

vlog  ../../common/rtl/shift_reg.sv
vlog  ../rtl/dds.sv
vlog  ../rtl/round.sv
vlog  ../rtl/cmult.sv
vlog  ../rtl/fir_filter.sv
vlog  ../rtl/sfir_even_symmetric_systolic_top.sv
vlog  ../rtl/sfir.sv
vlog  ../rtl/ddc.sv

vlog ddc_tb.sv

vsim -voptargs="+acc" ddc_tb
add log -r /*

add wave -expand -group DDC /ddc_tb/dut/*

run -all
wave zoom full
