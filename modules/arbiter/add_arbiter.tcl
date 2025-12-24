set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_fork.sv
        $path/rtl/axis_arbiter.sv
        $path/rtl/round_robin_arbiter.sv
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/axis_arbiter_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_fork.sv
    add_file $path/rtl/axis_arbiter.sv
    add_file $path/rtl/round_robin_arbiter.sv
}
