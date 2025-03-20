set top      "axis_uart_top"
set part     "GW2A-LV18PG256C8/I7"
set dev_ver  "C"
set language "sysv2017"

set rtl_dir       "../../rtl"
set constrain_dir "../"

create_project -name $top -dir project -pn $part -device_version $dev_ver -force

add_file $rtl_dir/axis_if.sv
add_file $rtl_dir/axis_uart_top.sv
add_file $rtl_dir/axis_uart_tx.sv
add_file $rtl_dir/axis_uart_rx.sv

add_file $constrain_dir/axis_uart_top.sdc
add_file $constrain_dir/axis_uart_top.cst

set_option -top_module $top
set_option -verilog_std $language

run all