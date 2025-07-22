set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/axis_fork.sv
    $path/rtl/axis_join_rr_arb.sv
"

add_files -norecurse $xil_defaultlib
