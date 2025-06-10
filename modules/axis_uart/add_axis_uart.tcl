set path [file dirname [info script]]

set xci_defaultlib "
    $path/ip/uart_ila.xci
"

add_files -norecurse $xci_defaultlib

set xil_defaultlib "
    $path/rtl/axis_uart_rx.sv
    $path/rtl/axis_uart_top.sv
    $path/rtl/axis_uart_tx.sv
    $path/rtl/axis_uart.sv
    $path/rtl/axis_uart_pkg.svh
    $path/tb/axis_uart_top_tb.sv
"
   
add_files -norecurse $xil_defaultlib
