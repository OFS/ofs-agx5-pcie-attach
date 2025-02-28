package require -exact qsys 23.3

if { ![info exists sys_channels]} {
    set sys_channels { { {bot} {8} } { {top} {8} } }
}


if { ![info exists en_xbar]} {
    set en_xbar 1
}

proc config_noc {channels row} {
    set noc noc_${row}
    add_instance $noc intel_noc_initiator
    set_instance_parameter_value $noc INDIVIDUAL_AXI_CLKRESET {true}
    set_instance_parameter_value $noc INDEPENDENT_WIDE_INTERFACE_CLOCK {false}
    set_instance_parameter_value $noc NUM_AXI4_IF     $channels
    set_instance_parameter_value $noc NUM_AXI4LITE_IF {0}
    set_instance_parameter_value $noc AXI4_DATA_MODE  {AXI4_DATA_MODE_512}
    set_instance_parameter_value $noc AXI4_HANDSHAKE  {AXI4_HANDSHAKE_STANDARD}
    set_instance_parameter_value $noc NOC_QOS_MODE    {NOC_QOS_MODE_SOCKET}

    # Add the associated clock controller
    add_instance ${noc}_ctrl intel_noc_clock_ctrl
    set_instance_parameter_value ${noc}_ctrl REFCLK_FREQ {NOC_PLL_REFCLK_FREQ_100_MHZ}
    # TODO: export pll lock
    set_interface_property ${noc}_ctrl EXPORT_OF ${noc}_ctrl.refclk
}

proc config_hbm {channels row} {
    set hbm hbm_${row}
    add_instance $hbm hbm_fp
    for {set channel 0} {$channel < 8} {incr channel} {
        if {$channel >= $channels} {
            set_instance_parameter_value hbm CTRL_CH${channel}_EN {false}
            continue
        }
        set_instance_parameter_value $hbm CTRL_CH${channel}_EN {true}
        set_instance_parameter_value $hbm CTRL_CH${channel}_CLONE_OF_ID_AUTO_BOOL {true}
        
        if { ($channel == 0) } {
            set_instance_parameter_value $hbm CTRL_CH${channel}_CLONE_OF_ID {None}
        } else {
            set_instance_parameter_value $hbm CTRL_CH${channel}_CLONE_OF_ID {0}
        }
        set_instance_parameter_value $hbm CTRL_CH${channel}_CMD_USER_AP_EN {true}
    }
    # Signal exports
    set_interface_property ${hbm}_local_cal_fail    EXPORT_OF ${hbm}.local_cal_fail
    set_interface_property ${hbm}_local_cal_success EXPORT_OF ${hbm}.local_cal_success
    set_interface_property ${hbm}_fab_clk EXPORT_OF ${hbm}.fabric_clk
    set_interface_property ${hbm}_uib_clk EXPORT_OF ${hbm}.uibpll_refclk
    set_interface_property ${hbm}_rst_n   EXPORT_OF ${hbm}.hbm_reset_n
    set_interface_property ${hbm}_fab_clk EXPORT_OF ${hbm}.fabric_clk
    set_interface_property ${hbm}_uib_clk EXPORT_OF ${hbm}.uibpll_refclk
    set_interface_property ${hbm}_temp    EXPORT_OF ${hbm}.temp_i
    set_interface_property ${hbm}_cattrip EXPORT_OF ${hbm}.cattrip_i
}

proc compose_hbm_ss {sys_channels en_xbar} {
    set app_channel 0
    foreach conf $sys_channels {
        set row [lindex $conf 0]
        set hbm_channels [lindex $conf 1]
        set noc_channels [expr {$hbm_channels * 2}]
        config_hbm $hbm_channels $row
        config_noc $noc_channels $row

        set noc noc_${row}
        set hbm hbm_${row}
        
        # connections
        for {set channel 0} {$channel < $hbm_channels} {incr channel} {
            for {set psuedo_channel 0} {$psuedo_channel < 2} {incr psuedo_channel} {
                set noc_channel    [expr {$channel * 2} + $psuedo_channel]
                if {[string is true $en_xbar]} {
                    # Full NxN crossbar
                    for {set hbm_conn 0} {$hbm_conn < $hbm_channels} {incr hbm_conn} {
                        for {set hbm_pchan_conn 0} {$hbm_pchan_conn < 2} {incr hbm_pchan_conn} {
                            # wide integer math is not supported in tcl 8.0 (qsys) so the address generation
                            # here is a hacky string concat
                            set prefix [format 0x%x [expr 0x4 * ($hbm_conn*2 + $hbm_pchan_conn)]]
                            set addr "${prefix}0000000"

                            add_connection ${noc}.i${noc_channel}_axi4noc/${hbm}.t_ch${hbm_conn}_u${hbm_pchan_conn}_axi4noc
                            set_connection_parameter_value ${noc}.i${noc_channel}_axi4noc/${hbm}.t_ch${hbm_conn}_u${hbm_pchan_conn}_axi4noc baseAddress $addr
                        }
                    }
                } else {
                    add_connection ${noc}.i${noc_channel}_axi4noc/${hbm}.t_ch${channel}_u${psuedo_channel}_axi4noc
                }
                set_interface_property i${app_channel}_app EXPORT_OF ${noc}.s${noc_channel}_axi4
                set_interface_property i${app_channel}_app_clk EXPORT_OF ${noc}.s${noc_channel}_axi4_aclk
                set_interface_property i${app_channel}_app_rst_n EXPORT_OF ${noc}.s${noc_channel}_axi4_aresetn
                incr app_channel
            }
        }
    }
}


create_system hbm_ss
set_project_property DEVICE AGMH039R47A2E2V
set_project_property DEVICE_FAMILY Agilex


# set_module_property name hbm_ss
# set_module_property COMPOSITION_CALLBACK compose_hbm_ss



set_module_property NAME {hbm_ss}
set_module_property FILE {hbm_ss.qsys}
set_module_property GENERATION_ID {0x00000000}

compose_hbm_ss $sys_channels $en_xbar

# save the system
sync_sysinfo_parameters
save_system hbm_ss
