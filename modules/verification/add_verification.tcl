set path [file dirname [info script]]

set xil_defaultlib "
    $path/tb/agent.sv
    $path/tb/cfg.sv
    $path/tb/checker.sv
    $path/tb/driver.sv
    $path/tb/env.sv
    $path/tb/gen.sv
    $path/tb/monitor.sv
    $path/tb/packet.sv
    $path/tb/test_pkg.svh
    $path/tb/test.sv
"

add_files -norecurse $xil_defaultlib
