set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axis_if.sv
"

add_files -norecurse $xil_defaultlib
