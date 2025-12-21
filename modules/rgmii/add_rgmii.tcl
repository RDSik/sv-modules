set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_rgmii.sv
        $path/rtl/eth_header_gen.sv
        $path/rtl/packet_gen.sv
        $path/rtl/packet_recv.sv
        $path/rtl/rgmii_rx.sv
        $path/rtl/rgmii_tx.sv
        $path/rtl/rgmii_pkg.svh
    "
    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_rmii.sv
    add_file $path/rtl/eth_header_gen.sv
    add_file $path/rtl/packet_gen.sv
    add_file $path/rtl/packet_recv.sv
    add_file $path/rtl/rmii_pkg.svh
}
