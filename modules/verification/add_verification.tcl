set path [file dirname [info script]]

set xil_defaultlib "
    $path/tb/cfg.svh
    $path/tb/env.svh
    $path/tb/test_pkg.svh
    $path/tb/axil_env.svh
"

add_files -norecurse $xil_defaultlib
