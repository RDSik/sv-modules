set top      "ctrl_top"
set part     "GW2A-LV18PG256C8/I7"
set dev_ver  "C"
set language "sysv2017"

set modules_dirs [list \
    ../../modules/axis_dw_conv \
    ../../modules/arbiter \
    ../../modules/spi \
    ../../modules/uart \
    ../../modules/i2c \
    ../../modules/fifo \
    ../../modules/common \
    ../../modules/bd \
    ../../modules/dsp \
    ../../modules/lfsr \
    ../../modules/interface \
]

set constrain_dir "../tangprimer20k"

create_project -name $top -dir project -pn $part -device_version $dev_ver -force
    
proc source_scripts {dirs} {
    foreach current_dir $dirs {
        global gowin
        global xilinx
        set gowin 1
        set xilinx 0
        set scripts [glob -nocomplain -directory $current_dir *.tcl]
        foreach script $scripts {
            if {[catch {source $script} err]} {
                puts "Error source '$script': $err"
            } else {
                puts "Success source: $script"
            }
        }
    }
}

source_scripts $modules_dirs

add_file $constrain_dir/top.sdc
add_file $constrain_dir/top.cst

set_option -top_module $top
set_option -verilog_std $language
set_option -use_sspi_as_gpio 1
set_option -use_ready_as_gpio 1
set_option -use_done_as_gpio 1

run all
