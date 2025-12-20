set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/axil_uart.sv
        $path/rtl/axis_uart_rx.sv
        $path/rtl/axis_uart_tx.sv
        $path/rtl/uart_pkg.svh
    "
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/axis_uart_tb.sv
        $path/tb/axil_uart_tb.sv
        $path/tb/axil_uart_class.svh
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/axis_uart_tx.sv
    add_file $path/rtl/axis_uart_rx.sv
    add_file $path/rtl/axil_uart.sv
    add_file $path/rtl/uart_pkg.svh
}
