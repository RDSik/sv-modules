set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axis_data_gen.sv
    $path/rtl/axis_spi_master.sv
    $path/tb/axis_spi_top_tb.sv
"

add_files -norecurse $xil_defaultlib
