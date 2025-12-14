set syn_top       "ps_pl_top"
set hw_project    "hw_platform"
set cpu           "ps7_cortexa9_0"
set bsp           "standalone_bsp"
set device_tree   [file normalize "Zynq-Linux/device-tree-xlnx-xilinx-v2019.1"]
set workspace_dir [file normalize  "project/pz7020starlite"]
set project_dir   [file normalize "project/pz7020starlite"]
set sdk_dir       [file normalize "$project_dir/$syn_top.sdk"]

setws $project_dir
createhw -name $syn_top -hwspec $sdk_dir/$syn_top.hdf

createbsp -name $bsp -hwproject $hw_project \
          -proc $cpu -os standalone

createapp -name $syn_top -app {Empty Application} \
          -hwproject $syn_top -bsp $bsp \
          -proc $cpu -os standalone -lang C

set source_dir "/path/to/your/c/sources"

importsources -name $syn_top -path $source_dir
repo -set $device_tree
repo -scan
projects -build

