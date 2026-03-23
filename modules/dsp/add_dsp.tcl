set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/dds_compiler/dds_compiler.xci
    "
    add_files -norecurse $xci_defaultlib

    set xil_defaultlib "
        $path/rtl/fir_filter.sv
        $path/rtl/cmult.sv
        $path/rtl/round.sv
        $path/rtl/sfir_even_symmetric_systolic_top.sv
        $path/rtl/sfir.sv
        $path/rtl/ddc.sv
        $path/rtl/dds.sv
        $path/rtl/mixer.sv
        $path/rtl/resampler.sv
        $path/rtl/mult_signed.sv
        $path/rtl/saturate.sv
        $path/rtl/amplitude.sv
        $path/rtl/test_signal_gen.sv
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/ddc_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/fir_filter.sv
    add_file $path/rtl/cmult.sv
    add_file $path/rtl/round.sv
    add_file $path/rtl/sfir_even_symmetric_systolic_top.sv
    add_file $path/rtl/resampler.sv
    add_file $path/rtl/mult_signed.sv
    add_file $path/rtl/saturate.sv
    add_file $path/rtl/amplitude.sv
}
