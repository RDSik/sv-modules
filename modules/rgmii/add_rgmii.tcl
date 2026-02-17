set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/clk_wiz_eth/clk_wiz_eth.xci
    "
    add_files -norecurse $xci_defaultlib
    
    set xil_defaultlib "
        $path/rtl/axil_rgmii.sv
        $path/rtl/axis_rgmii.sv
        $path/rtl/eth_header_gen.sv
        $path/rtl/mac_tx.sv
        $path/rtl/mac_rx.sv
        $path/rtl/rgmii_rx.sv
        $path/rtl/rgmii_tx.sv
        $path/rtl/rgmii_pkg.svh
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/axis_rgmii_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/eth_header_gen.sv
    add_file $path/rtl/mac_tx.sv
    add_file $path/rtl/mac_rx.sv
    add_file $path/rtl/rgmii_rx.sv
    add_file $path/rtl/rgmii_tx.sv
    add_file $path/rtl/axis_rgmii.sv
    add_file $path/rtl/axil_rgmii.sv
    add_file $path/rtl/rgmii_pkg.svh
}
