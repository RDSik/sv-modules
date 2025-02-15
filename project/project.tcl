create_project -name axis_uart_top -dir project -pn GW2A-LV18PG256C8/I7 -device_version C -force
add_file ../../src/axis_if.sv
add_file ../../src/axis_uart_top.sv
add_file ../../src/axis_uart_tx.sv
add_file ../../src/axis_uart_rx.sv
add_file ../axis_uart_top.sdc
add_file ../axis_uart_top.cst
set_option -top_module axis_uart_top
set_option -verilog_std sysv2017
run all