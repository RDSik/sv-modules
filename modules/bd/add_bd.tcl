set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/ps_pl_top.sv
        $path/rtl/ctrl_top.sv
    "

    add_files -norecurse $xil_defaultlib

    source $path/scripts/zynq_bd.tcl
} elseif {$gowin == 1} {
    add_file $path/rtl/ctrl_top.sv
}
