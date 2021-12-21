# TCL File Generated by Component Editor 18.1
# Tue Dec 21 14:52:05 CET 2021
# DO NOT MODIFY


# 
# sobel_mask_CI "sobel_mask_CI" v1.0
# MLN 2021.12.21.14:52:05
# 3x3 sobel mask
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module sobel_mask_CI
# 
set_module_property DESCRIPTION "3x3 sobel mask"
set_module_property NAME sobel_mask_CI
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR MLN
set_module_property DISPLAY_NAME sobel_mask_CI
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL sobel
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file sobel_xy.vhd VHDL PATH ../vhdl_own/sobel_xy.vhd TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point nios_custom_instruction_slave
# 
add_interface nios_custom_instruction_slave nios_custom_instruction end
set_interface_property nios_custom_instruction_slave clockCycle 0
set_interface_property nios_custom_instruction_slave operands 2
set_interface_property nios_custom_instruction_slave ENABLED true
set_interface_property nios_custom_instruction_slave EXPORT_OF ""
set_interface_property nios_custom_instruction_slave PORT_NAME_MAP ""
set_interface_property nios_custom_instruction_slave CMSIS_SVD_VARIABLES ""
set_interface_property nios_custom_instruction_slave SVD_ADDRESS_GROUP ""

add_interface_port nios_custom_instruction_slave dataA_i dataa Input 32
add_interface_port nios_custom_instruction_slave dataB_i datab Input 32
add_interface_port nios_custom_instruction_slave done_o done Output 1
add_interface_port nios_custom_instruction_slave start_i start Input 1
add_interface_port nios_custom_instruction_slave rst_i reset Input 1
add_interface_port nios_custom_instruction_slave result_o result Output 32
add_interface_port nios_custom_instruction_slave clk_i clk Input 1

