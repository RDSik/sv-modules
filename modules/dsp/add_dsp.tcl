set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/dds_compiler.xci
    "
    add_files -norecurse $xci_defaultlib

    set xil_defaultlib "
        $path/rtl/fir_filter.sv
        $path/rtl/dds.sv
        $path/rtl/complex_mult.sv
        $path/rtl/round.sv
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/fir_filter_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/fir_filter.sv
    add_file $path/rtl/dds.sv
    add_file $path/rtl/complex_mult.sv
    add_file $path/rtl/round.sv
}
