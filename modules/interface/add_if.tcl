set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axis_if.sv
    $path/rtl/apb_if.sv
    $path/rtl/spi_if.sv
"

add_files -norecurse $xil_defaultlib
