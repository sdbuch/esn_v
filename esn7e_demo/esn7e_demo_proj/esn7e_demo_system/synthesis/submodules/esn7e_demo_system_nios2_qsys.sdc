# Legal Notice: (C)2016 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	esn7e_demo_system_nios2_qsys 	esn7e_demo_system_nios2_qsys:*
set 	esn7e_demo_system_nios2_qsys_oci 	esn7e_demo_system_nios2_qsys_nios2_oci:the_esn7e_demo_system_nios2_qsys_nios2_oci
set 	esn7e_demo_system_nios2_qsys_oci_break 	esn7e_demo_system_nios2_qsys_nios2_oci_break:the_esn7e_demo_system_nios2_qsys_nios2_oci_break
set 	esn7e_demo_system_nios2_qsys_ocimem 	esn7e_demo_system_nios2_qsys_nios2_ocimem:the_esn7e_demo_system_nios2_qsys_nios2_ocimem
set 	esn7e_demo_system_nios2_qsys_oci_debug 	esn7e_demo_system_nios2_qsys_nios2_oci_debug:the_esn7e_demo_system_nios2_qsys_nios2_oci_debug
set 	esn7e_demo_system_nios2_qsys_wrapper 	esn7e_demo_system_nios2_qsys_jtag_debug_module_wrapper:the_esn7e_demo_system_nios2_qsys_jtag_debug_module_wrapper
set 	esn7e_demo_system_nios2_qsys_jtag_tck 	esn7e_demo_system_nios2_qsys_jtag_debug_module_tck:the_esn7e_demo_system_nios2_qsys_jtag_debug_module_tck
set 	esn7e_demo_system_nios2_qsys_jtag_sysclk 	esn7e_demo_system_nios2_qsys_jtag_debug_module_sysclk:the_esn7e_demo_system_nios2_qsys_jtag_debug_module_sysclk
set 	esn7e_demo_system_nios2_qsys_oci_path 	 [format "%s|%s" $esn7e_demo_system_nios2_qsys $esn7e_demo_system_nios2_qsys_oci]
set 	esn7e_demo_system_nios2_qsys_oci_break_path 	 [format "%s|%s" $esn7e_demo_system_nios2_qsys_oci_path $esn7e_demo_system_nios2_qsys_oci_break]
set 	esn7e_demo_system_nios2_qsys_ocimem_path 	 [format "%s|%s" $esn7e_demo_system_nios2_qsys_oci_path $esn7e_demo_system_nios2_qsys_ocimem]
set 	esn7e_demo_system_nios2_qsys_oci_debug_path 	 [format "%s|%s" $esn7e_demo_system_nios2_qsys_oci_path $esn7e_demo_system_nios2_qsys_oci_debug]
set 	esn7e_demo_system_nios2_qsys_jtag_tck_path 	 [format "%s|%s|%s" $esn7e_demo_system_nios2_qsys_oci_path $esn7e_demo_system_nios2_qsys_wrapper $esn7e_demo_system_nios2_qsys_jtag_tck]
set 	esn7e_demo_system_nios2_qsys_jtag_sysclk_path 	 [format "%s|%s|%s" $esn7e_demo_system_nios2_qsys_oci_path $esn7e_demo_system_nios2_qsys_wrapper $esn7e_demo_system_nios2_qsys_jtag_sysclk]
set 	esn7e_demo_system_nios2_qsys_jtag_sr 	 [format "%s|*sr" $esn7e_demo_system_nios2_qsys_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$esn7e_demo_system_nios2_qsys_oci_break_path|break_readreg*] -to [get_keepers *$esn7e_demo_system_nios2_qsys_jtag_sr*]
set_false_path -from [get_keepers *$esn7e_demo_system_nios2_qsys_oci_debug_path|*resetlatch]     -to [get_keepers *$esn7e_demo_system_nios2_qsys_jtag_sr[33]]
set_false_path -from [get_keepers *$esn7e_demo_system_nios2_qsys_oci_debug_path|monitor_ready]  -to [get_keepers *$esn7e_demo_system_nios2_qsys_jtag_sr[0]]
set_false_path -from [get_keepers *$esn7e_demo_system_nios2_qsys_oci_debug_path|monitor_error]  -to [get_keepers *$esn7e_demo_system_nios2_qsys_jtag_sr[34]]
set_false_path -from [get_keepers *$esn7e_demo_system_nios2_qsys_ocimem_path|*MonDReg*] -to [get_keepers *$esn7e_demo_system_nios2_qsys_jtag_sr*]
set_false_path -from *$esn7e_demo_system_nios2_qsys_jtag_sr*    -to *$esn7e_demo_system_nios2_qsys_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$esn7e_demo_system_nios2_qsys_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$esn7e_demo_system_nios2_qsys_oci_debug_path|monitor_go
