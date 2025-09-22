set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/dds_compiler.xci
    "
    add_files -norecurse $xci_defaultlib

    set xil_defaultlib "
        $path/rtl/sfir_even_symmetric_systolic_element.sv
        $path/rtl/sfir_even_symmetric_systolic_top.sv
        $path/rtl/sfir_top.sv
        $path/rtl/dds.sv
        $path/rtl/complex_mult.sv
        $path/rtl/round.sv
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/sfir_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/sfir_even_symmetric_systolic_element.sv
    add_file $path/rtl/sfir_even_symmetric_systolic_top.sv
    add_file $path/rtl/dds.sv
    add_file $path/rtl/complex_mult.sv
    add_file $path/rtl/round.sv
}
