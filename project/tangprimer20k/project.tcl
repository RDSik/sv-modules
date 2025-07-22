set top      "axis_uart_top"
set part     "GW2A-LV18PG256C8/I7"
set dev_ver  "C"
set language "sysv2017"

set modules_dir   "../../modules"
set constrain_dir "../tangprimer20k"

create_project -name $top -dir project -pn $part -device_version $dev_ver -force

add_file $modules_dir/axis_uart/rtl/axis_uart_tx.sv
add_file $modules_dir/axis_uart/rtl/axis_uart_rx.sv
add_file $modules_dir/axis_uart/rtl/axis_uart_top.sv
add_file $modules_dir/axis_uart/rtl/uart_pkg.svh

add_file $modules_dir/axis_spi/rtl/axis_data_gen.sv
add_file $modules_dir/axis_spi/rtl/axis_spi_master.sv

add_file $modules_dir/axis_arbiter/rtl/axis_fork.sv
add_file $modules_dir/axis_arbiter/rtl/axis_join_rr_arb.sv

add_file $modules_dir/fifo/rtl/async_fifo.sv
add_file $modules_dir/fifo/rtl/axis_fifo_wrap.sv
add_file $modules_dir/fifo/rtl/rd_ptr_empty.sv
add_file $modules_dir/fifo/rtl/sync_fifo.sv
add_file $modules_dir/fifo/rtl/wr_ptr_full.sv
add_file $modules_dir/fifo/rtl/shift_reg.sv

add_file $modules_dir/ram/rtl/bram_true_dp.sv
add_file $modules_dir/ram/rtl/ram_dp_2clk.sv
add_file $modules_dir/ram/rtl/ram_dp.sv
add_file $modules_dir/ram/rtl/ram.sv

add_file $modules_dir/interface/rtl/axis_if.sv
add_file $modules_dir/interface/rtl/spi_if.sv
add_file $modules_dir/interface/rtl/apb_if.sv

add_file $constrain_dir/axis_uart_top.sdc
add_file $constrain_dir/axis_uart_top.cst

set_option -top_module $top
set_option -verilog_std $language
set_option -use_sspi_as_gpio 1
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1

run all
