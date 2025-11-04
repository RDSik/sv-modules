set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/dds_compiler.xci
    "
    add_files -norecurse $xci_defaultlib

    set xil_defaultlib "
        $path/rtl/dds.sv
        $path/rtl/dds_wrap.sv
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/dds_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/dds.sv
    add_file $path/rtl/dds_wrap.sv
}
