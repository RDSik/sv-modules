set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/ram.sv
    $path/rtl/ram_dp.sv
    $path/rtl/ram_dp_2clk.sv
    $path/rtl/bram_true_dp.sv
"

add_files -norecurse $xil_defaultlib
