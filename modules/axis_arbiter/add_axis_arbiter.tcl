set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_fork.sv
        $path/rtl/axis_join_rr_arb.sv
        $path/rtl/axis_data_gen.sv
        $path/tb/axis_join_rr_arb_tb.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_fork.sv
    add_file $path/rtl/axis_join_rr_arb.sv
    add_file $path/rtl/axis_data_gen.sv
}
