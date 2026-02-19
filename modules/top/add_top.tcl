set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axil_top.sv
        $path/rtl/ps_pl_top.sv
        $path/rtl/top_pkg.svh
    "

    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/axil_top_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axil_top.sv
}
