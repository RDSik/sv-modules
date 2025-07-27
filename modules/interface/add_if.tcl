set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_if.sv
        $path/rtl/apb_if.sv
        $path/rtl/spi_if.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_if.sv
    add_file $path/rtl/apb_if.sv
    add_file $path/rtl/spi_if.sv
}
