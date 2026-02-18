set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/axil_ila/axil_ila.xci
        $path/ip/axi_clock_converter/axi_clock_converter.xci
        $path/ip/axi_crossbar/axi_crossbar.xci
    "
    add_files -norecurse $xci_defaultlib
    
    set xil_defaultlib "
        $path/rtl/ram_sp.sv
        $path/rtl/ram_sdp.sv
        $path/rtl/ram_tdp.sv
        $path/rtl/shift_reg.sv
        $path/rtl/axil_ram.sv
        $path/rtl/axil_reg_file.sv
        $path/rtl/axil_reg_file_wrap.sv
        $path/rtl/axil_crossbar.sv
        $path/rtl/axis_lfsr_wrap.sv
        $path/rtl/lfsr.sv
        $path/rtl/crc.sv
        $path/rtl/iddr.sv
        $path/rtl/oddr.sv
        $path/rtl/axis_reg.sv
        $path/rtl/clk_manager.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/ram_sp.sv
    add_file $path/rtl/ram_sdp.sv
    add_file $path/rtl/ram_tdp.sv
    add_file $path/rtl/shift_reg.sv
    add_file $path/rtl/axil_ram.sv
    add_file $path/rtl/axil_reg_file.sv
    add_file $path/rtl/axil_reg_file_wrap.sv
    add_file $path/rtl/axil_crossbar.sv
    add_file $path/rtl/axis_lfsr_wrap.sv
    add_file $path/rtl/lfsr.sv
    add_file $path/rtl/crc.sv
    add_file $path/rtl/iddr.sv
    add_file $path/rtl/oddr.sv
    add_file $path/rtl/axis_reg.sv
}
