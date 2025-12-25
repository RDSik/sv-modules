set path [file dirname [info script]]

if {$xilinx == 1} {
    set xil_defaultlib "
        $path/rtl/async_fifo.sv
        $path/rtl/axis_fifo.sv
        $path/rtl/fifo_wrap.sv
        $path/rtl/rd_ptr_empty.sv
        $path/rtl/sync_fifo.sv
        $path/rtl/wr_ptr_full.sv
    "
       
    add_files -norecurse $xil_defaultlib

    set xil_defaultlib "
        $path/tb/axis_fifo_tb.sv
    "
    add_files -fileset sim_1 $xil_defaultlib
} elseif {$gowin == 1} {
    add_file $path/rtl/async_fifo.sv
    add_file $path/rtl/fifo_wrap.sv
    add_file $path/rtl/axis_fifo.sv
    add_file $path/rtl/rd_ptr_empty.sv
    add_file $path/rtl/sync_fifo.sv
    add_file $path/rtl/wr_ptr_full.sv
}
