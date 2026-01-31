set syn_top     "ps_pl_top"
set hw_project  ${syn_top}_hw_platform_0
set app         $syn_top
set bsp         ${app}_bsp
set device_tree ${app}_devtree_bsp
set cpu         "ps7_cortexa9_0"
set modules_dir [file normalize "modules"]
set sdk_dir     [file normalize "project/pz7020starlite/$syn_top.sdk"]

file delete -force $sdk_dir/SDK.log
file delete -force $sdk_dir/.metadata
file delete -force $sdk_dir/$hw_project
file delete -force $sdk_dir/$bsp
file delete -force $sdk_dir/$app
file delete -force $sdk_dir/$device_tree

setws $sdk_dir

repo -set "Zynq-Linux/device-tree-xlnx-xilinx-v2019.1"

createhw -name $hw_project -hwspec $sdk_dir/$syn_top.hdf

createbsp -name $bsp -hwproject $hw_project -proc $cpu -os standalone

createapp -name $app -app {Empty Application} -hwproject $hw_project -bsp $bsp -proc $cpu -os standalone -lang C

configapp -app $app build-config debug

createbsp -name $device_tree -hwproject $hw_project -proc $cpu -os device_tree

proc import_sdk {current_dir name} {
	set sdk_dirs [glob -nocomplain -type d [file join $current_dir */sdk]]
    foreach sdk_path $sdk_dirs  {
        if {[file isdirectory $sdk_path]} {
            puts "Current dir: $sdk_path"
            importsources -name $name -path $sdk_path
        }
    }
}

import_sdk $modules_dir $syn_top

projects -build
