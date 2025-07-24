set path [file dirname [info script]]

set xil_defaultlib "
    $path/rtl/sfir_even_symmetric_systolic_element.sv
    $path/rtl/sfir_even_symmetric_systolic_top.sv
    $path/tb/sfir_tb.sv
    $path/rtl/dds.sv
"
   
add_files -norecurse $xil_defaultlib
