set path [file dirname [info script]]

if {$xilinx == 1} {
    set dsp_files "
        $path/rtl/sfir_even_symmetric_systolic_element.sv
        $path/rtl/sfir_even_symmetric_systolic_top.sv
        $path/tb/sfir_tb.sv
        $path/rtl/dds.sv
        $path/rtl/complex_mult.sv
        $path/rtl/round.sv
    "

    add_files -norecurse $dsp_files
} elseif {$gowin == 1} {
    add_file $path/rtl/sfir_even_symmetric_systolic_element.sv
    add_file $path/rtl/sfir_even_symmetric_systolic_top.sv
    add_file $path/rtl/dds.sv
    add_file $path/rtl/complex_mult.sv
    add_file $path/rtl/round.sv
}
