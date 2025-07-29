set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_lfsr_wrap.sv
        $path/rtl/lfsr.sv
        $path/rtl/crc.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_lfsr_wrap.sv
    add_file $path/rtl/lfsr.sv
    add_file $path/rtl/crc.sv
}
