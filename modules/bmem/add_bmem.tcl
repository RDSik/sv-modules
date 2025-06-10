set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/brom.sv
    $path/rtl/bram_dp.sv
    $path/rtl/bram_dp_2clk.sv
    $path/rtl/bram_true_dp.sv
"

add_files -norecurse $xil_defaultlib
