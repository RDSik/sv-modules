set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/async_fifo.sv
    $path/rtl/axis_fifo_wrap.sv
    $path/rtl/rd_ptr_empty.sv
    $path/rtl/sync_fifo.sv
    $path/rtl/wr_ptr_full.sv
    $path/rtl/shift_reg.sv
    $path/tb/axis_fifo_tb.sv
"
   
add_files -norecurse $xil_defaultlib
