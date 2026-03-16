set path [file dirname [info script]]

if {$xilinx == 1} {
    source $path/ip/acc_dma_test.tcl

    set xil_defaultlib "
        $path/rtl/axi_dma_test_wrap.sv
    "

    add_files -norecurse $xil_defaultlib
}
