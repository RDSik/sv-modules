set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_fork.sv
        $path/rtl/axis_rr_arb_wrap.sv
        $path/rtl/round_robin_arbiter.sv
        $path/tb/axis_rr_arb_tb.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_fork.sv
    add_file $path/rtl/axis_rr_arb_wrap.sv
    add_file $path/rtl/round_robin_arbiter.sv
}
