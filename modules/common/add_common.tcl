set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/ram.sv
        $path/rtl/ram_dp.sv
        $path/rtl/ram_dp_2clk.sv
        $path/rtl/bram_true_dp.sv
        $path/rtl/shift_reg.sv
        $path/rtl/apb_reg_file.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/ram.sv
    add_file $path/rtl/ram_dp.sv
    add_file $path/rtl/ram_dp_2clk.sv
    add_file $path/rtl/bram_true_dp.sv
    add_file $path/rtl/shift_reg.sv
    add_file $path/rtl/apb_reg_file.sv
}
