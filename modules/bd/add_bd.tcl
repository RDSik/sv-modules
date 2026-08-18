set path [file dirname [info script]]

if {$xilinx == 1} {
    source $path/scripts/zynq_bd.tcl

    set xci_defaultlib "
        $path/ip/axi_bram_ctrl_0/axi_bram_ctrl_0.xci
    "
    add_files -norecurse $xci_defaultlib

    set xil_defaultlib "
        $path/rtl/bd_top.sv
    "

    add_files -norecurse $xil_defaultlib
}
