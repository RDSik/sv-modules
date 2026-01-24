set syn_top     "ps_pl_top"
set hw_project  ${syn_top}_hw_platform_0
set app         $syn_top
set bsp         ${app}_bsp
set device_tree ${app}_devtree_bsp
set cpu         "ps7_cortexa9_0"
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

set source_dir "modules/uart/sdk"

importsources -name $syn_top -path $source_dir

projects -build
