set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/axi_protocol_converter/axi_protocol_converter.xci
        $path/ip/axi_dma_sim/axi_dma_sim.xci
    "
    add_files -norecurse $xci_defaultlib
    
    set xil_defaultlib "
        $path/rtl/axi_dma_wrap.sv
    "

    add_files -norecurse $xil_defaultlib
}
