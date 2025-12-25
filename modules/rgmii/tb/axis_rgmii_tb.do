vlib work
vmap work

vlog modules/interface/rtl/axis_if.sv

vlog modules/fifo/rtl/async_fifo.sv
vlog modules/fifo/rtl/axis_fifo.sv
vlog modules/fifo/rtl/fifo_wrap.sv
vlog modules/fifo/rtl/rd_ptr_empty.sv
vlog modules/fifo/rtl/sync_fifo.sv
vlog modules/fifo/rtl/wr_ptr_full.sv

vlog modules/common/rtl/ram_sdp.sv
vlog modules/common/rtl/shift_reg.sv

vlog  modules/rgmii/rtl/rgmii_pkg.svh
vlog  modules/rgmii/rtl/packet_gen.sv
vlog  modules/rgmii/rtl/eth_header_gen.sv
vlog  modules/rgmii/rtl/packet_recv.sv

vlog modules/rgmii/tb/axis_rgmii_tb.sv

vsim -voptargs="+acc" axis_rgmii_tb
add log -r /*

add wave -expand -group PACKET_GEN  /axis_rgmii_tb/i_packet_gen/*
add wave -expand -group PACKET_RECV /axis_rgmii_tb/i_packet_recv/*
add wave -expand -group M_AXIS      /axis_rgmii_tb/m_axis/*
add wave -expand -group S_AXIS      /axis_rgmii_tb/s_axis/*

run -all
wave zoom full
