set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/bram_dp.sv
    $path/rtl/bram_true_dp.sv
    $path/rtl/bram.sv
"

add_files -norecurse $xil_defaultlib
