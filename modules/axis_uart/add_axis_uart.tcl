set path [file dirname [info script]]

if {$xilinx == 1} {
    set xci_defaultlib "
        $path/ip/apb_ila.xci
    "

    add_files -norecurse $xci_defaultlib

    set xil_defaultlib "
        $path/rtl/apb_uart.sv
        $path/rtl/axis_uart_rx.sv
        $path/rtl/axis_uart_tx.sv
        $path/rtl/uart_pkg.svh
        $path/tb/axis_uart_tb.sv
        $path/tb/apb_uart_tb.sv
    "

    add_files -norecurse $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_uart_tx.sv
    add_file $path/rtl/axis_uart_rx.sv
    add_file $path/rtl/apb_uart.sv
    add_file $path/rtl/uart_pkg.svh
}
