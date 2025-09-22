set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axis_spi_master.sv
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/axis_spi_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_spi_master.sv
}
