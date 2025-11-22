set part     "xc7z020clg400-2"
set syn_top  "ps_pl_top"
set sim_top  "axil_uart_tb"
set language "Verilog"
set gui_flag  [lindex $argv 0]

set project_dir [file normalize "project/pz7020starlite"]
set modules_dir [file normalize "modules"]

create_project -force $syn_top $project_dir -part $part

set_property target_language $language [current_project]
set_property top $syn_top [current_fileset]
set_property top $sim_top [get_filesets sim_1]

proc source_scripts {current_dir} {
    foreach sub_dir [glob -nocomplain -directory $current_dir *] {
        if {[file isdirectory $sub_dir]} {
           global gowin
            global xilinx
            set gowin 0
            set xilinx 1
            puts "Current dir: $sub_dir"
            cd $sub_dir
            foreach script [glob -nocomplain *.tcl] {
                if {[catch {source $script} err]} {
                    puts "Error source '$script': $err"
                } else {
                    puts "Success source: $script"
                }
            }
            cd $current_dir
        }
    }
}

source_scripts $modules_dir

upgrade_ip [get_ips -all]

add_files -fileset constrs_1 -norecurse $project_dir/$syn_top.xdc

set_property strategy Flow_PerfOptimized_high [get_runs synth_1]
set_property strategy Performance_ExtraTimingOpt [get_runs impl_1]

if {$gui_flag == 1} {
    start_gui
}

launch_runs synth_1
wait_on_run synth_1
open_run synth_1 -name synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
