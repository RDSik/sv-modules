set path [file dirname [info script]]

if {$xilinx == 1} {
    source $path/ip/axi_dma_test.tcl

    set xil_defaultlib "
        $path/rtl/axi_dma_test_wrap.sv
        $path/rtl/axi_dma_pkg.svh
    "

    add_files -norecurse $xil_defaultlib
}
