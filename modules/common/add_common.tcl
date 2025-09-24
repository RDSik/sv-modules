set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/ram_sp.sv
        $path/rtl/ram_sdp.sv
        $path/rtl/ram_tdp.sv
        $path/rtl/shift_reg.sv
        $path/rtl/axil_ram.sv
        $path/rtl/axil_reg_file.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/ram.sv
    add_file $path/rtl/ram_dp.sv
    add_file $path/rtl/ram_dp_2clk.sv
    add_file $path/rtl/ram_true_dp.sv
    add_file $path/rtl/shift_reg.sv
    add_file $path/rtl/axil_reg_file.sv
}
