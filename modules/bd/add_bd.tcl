set path [file dirname [info script]]

if {$xilinx == 1} {
    source $path/scripts/zynq_bd.tcl

    set xil_defaultlib "
        $path/rtl/bd_top.sv
    "

    add_files -norecurse $xil_defaultlib
}
