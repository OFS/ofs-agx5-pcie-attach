# Copyright (C) 2023 Intel Corporation.
# SPDX-License-Identifier: MIT

set vlog_macros [get_all_global_assignments -name VERILOG_MACRO]
set include_ddr4 0
set ddr4_num_mem_groups 1

foreach_in_collection m $vlog_macros {
    if { [string equal "INCLUDE_DDR4" [lindex $m 2]] } {
        set_global_assignment -name VERILOG_MACRO "INCLUDE_LOCAL_MEM"
        set include_ddr4 1
    }

    # DDR4_NUM_MEM_GROUPS has a value, so it looks like a list
    if { [string match "DDR4_NUM_MEM_GROUPS*" [lindex $m 2]] } {
        set mem_group_str [split [lindex $m 2] "="]
        set ddr4_num_mem_groups [lindex $mem_group_str 1]
    }
}

if {$include_ddr4 == 1} {
    # Wrapper around the Qsys IP component
    set_global_assignment -name SYSTEMVERILOG_FILE $::env(BUILD_ROOT_REL)/ipss/mem/rtl/agx5_ddr4_top.sv

    # Memory model only used in SIM
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/ed_sim/ed_sim_mem.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/ed_sim/ed_sim_mem_group1.ip

    # AGX5 DDR4 Qsys
    set_global_assignment -name QSYS_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/agx5_ddr4_ss.qsys

    # Qsys IP components
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/axil_driver.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/reset_handler.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/s10_user_rst_clkgate.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/agx5_ddr4_ss_emif_a.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/agx5_ddr4_ss_emif_b.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/agx5_ddr4_ss_clock_bridge.ip
    set_global_assignment -name IP_FILE $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/ip/agx5_ddr4_ss/agx5_ddr4_ss_iopll_0.ip

    # Import the top-level memory project's interface into OFS
    dict set ::ofs_ip_cfg_db::ip_db $::env(BUILD_ROOT_REL)/ipss/mem/qip/agx5_ddr4_ss/agx5_ddr4_ss.qsys [list]
}
