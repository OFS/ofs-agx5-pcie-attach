# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Pin and location assignments
#
#-----------------------------------------------------------------------------

#set_location_assignment PIN_P36 -to qsfpa_resetn
#set_location_assignment PIN_R35 -to qsfpa_lpmode
#set_location_assignment PIN_M36 -to qsfpa_modeseln
#set_location_assignment PIN_L35 -to qsfpa_intn
# set_location_assignment PIN_KU60 -to qsfpa_modprsln
#set_location_assignment PIN_R33 -to qsfpa_power_good
#set_location_assignment PIN_P32 -to qsfpb_resetn
#set_location_assignment PIN_R31 -to qsfpb_lpmode
#set_location_assignment PIN_M32 -to qsfpb_modeseln
#set_location_assignment PIN_L31 -to qsfpb_intn
# set_location_assignment PIN_KF58 -to qsfpb_modprsln
#set_location_assignment PIN_W35 -to qsfpb_power_good
#set_location_assignment PIN_K44 -to qsfpa_i2c_scl
#set_location_assignment PIN_J43 -to qsfpa_i2c_sda

set_location_assignment PIN_CE24 -to "tod_fpga_clk(n)"
set_location_assignment PIN_CG24 -to tod_fpga_clk
set_location_assignment PIN_CH25 -to b_1pps_fpga_clk
#set_location_assignment PIN_B32 -to qsfpb_i2c_scl
#set_location_assignment PIN_A31 -to qsfpb_i2c_sda
set_location_assignment PIN_V19  -to b_sel_1pps_inout
set_location_assignment PIN_CH27 -to b_shdn_1pps_to_10mhz
set_location_assignment PIN_CG28 -to b_shdn_10mhz_in
set_location_assignment PIN_CH29 -to b_shdn_10mhz_out
set_location_assignment PIN_CN24 -to arb_in
set_location_assignment PIN_CK25 -to arb_out
set_location_assignment PIN_CM25 -to fm61_testio_d[0]
set_location_assignment PIN_CL26 -to fm61_testio_d[1]
set_location_assignment PIN_CN26 -to fm61_testio_d[2]
set_location_assignment PIN_CK27 -to fm61_testio_d[3]
set_location_assignment PIN_CM27 -to fm61_testio_d[4]
set_location_assignment PIN_CL28 -to fm61_testio_d[5]
set_location_assignment PIN_CN28 -to fm61_testio_d[6]
set_location_assignment PIN_CK29 -to fm61_testio_d[7]
set_location_assignment PIN_CM29 -to fm61_testio_clkout
set_location_assignment PIN_DA22 -to "fpga_pcie_refclk3_100m(n)"
set_location_assignment PIN_DC22 -to fpga_pcie_refclk3_100m
set_location_assignment PIN_CV27 -to fpga_fabric_reset_n
set_location_assignment PIN_CU28 -to m10_conf_done
set_location_assignment PIN_DC24 -to b_fpga_hps_zl_gpout[0]

# set_location_assignment PIN_B48 -to qsfpa_act_r
set_location_assignment PIN_D44 -to qsfpa_act_g
set_location_assignment PIN_J43 -to qsfpa_speed_y
set_location_assignment PIN_H44 -to qsfpa_speed_g

# set_location_assignment PIN_G49 -to qsfpb_act_r
set_location_assignment PIN_B41 -to qsfpb_act_g
set_location_assignment PIN_D42 -to qsfpb_speed_y
set_location_assignment PIN_J41 -to qsfpb_speed_g

# set_location_assignment PIN_AG6 -to hps_uart_tx
# set_location_assignment PIN_AB1 -to hps_uart_rx
# set_location_assignment PIN_V1 -to b_fpga_hps_zl_ho
# set_location_assignment PIN_AD11 -to fpga_hps_clkin
# set_location_assignment PIN_AC12 -to b_zl_spi_sck
# set_location_assignment PIN_H3 -to b_zl_spi_si
# set_location_assignment PIN_AD13 -to b_zl_spi_so
# set_location_assignment PIN_F3 -to b_zl_spi_cs

## QSFP-DD 1 pins on board
set_location_assignment PIN_GK83 -to hssi_if[0].rx_p 
set_location_assignment PIN_HB83 -to hssi_if[1].rx_p
set_location_assignment PIN_HP83 -to hssi_if[2].rx_p
set_location_assignment PIN_JD80 -to hssi_if[3].rx_p

set_location_assignment PIN_GN82 -to hssi_if[0].rx_n 
set_location_assignment PIN_HE82 -to hssi_if[1].rx_n
set_location_assignment PIN_HU82 -to hssi_if[2].rx_n
set_location_assignment PIN_JA79 -to hssi_if[3].rx_n

set_location_assignment PIN_JG83 -to hssi_if[4].rx_p
set_location_assignment PIN_JT80 -to hssi_if[5].rx_p
set_location_assignment PIN_JW83 -to hssi_if[6].rx_p
set_location_assignment PIN_KH80 -to hssi_if[7].rx_p

set_location_assignment PIN_JK82 -to hssi_if[4].rx_n  
set_location_assignment PIN_JN79 -to hssi_if[5].rx_n
set_location_assignment PIN_KB82 -to hssi_if[6].rx_n
set_location_assignment PIN_KE79 -to hssi_if[7].rx_n


set_location_assignment PIN_JD74 -to qsfp_ref_clk
#set_location_assignment PIN_JA73 -to "qsfp_ref_clk(n)"

set_location_assignment PIN_GG78 -to hssi_if[0].tx_p
set_location_assignment PIN_GW80 -to hssi_if[1].tx_p
set_location_assignment PIN_HB77 -to hssi_if[2].tx_p
set_location_assignment PIN_HL80 -to hssi_if[3].tx_p

set_location_assignment PIN_GK77 -to hssi_if[0].tx_n
set_location_assignment PIN_GT79 -to hssi_if[1].tx_n
set_location_assignment PIN_HE76 -to hssi_if[2].tx_n
set_location_assignment PIN_HH79 -to hssi_if[3].tx_n

set_location_assignment PIN_HP77 -to hssi_if[4].tx_p
set_location_assignment PIN_JG77 -to hssi_if[5].tx_p
set_location_assignment PIN_JT74 -to hssi_if[6].tx_p
set_location_assignment PIN_JW77 -to hssi_if[7].tx_p

set_location_assignment PIN_HU76 -to hssi_if[4].tx_n
set_location_assignment PIN_JK76 -to hssi_if[5].tx_n
set_location_assignment PIN_JN73 -to hssi_if[6].tx_n
set_location_assignment PIN_KB76 -to hssi_if[7].tx_n

# PCIe location
set_location_assignment PIN_AM1 -to PCIE_RX_P[0]
set_location_assignment PIN_AP1 -to PCIE_RX_P[1]
set_location_assignment PIN_AT1 -to PCIE_RX_P[2]
set_location_assignment PIN_AV1 -to PCIE_RX_P[3]
set_location_assignment PIN_AM3 -to PCIE_RX_N[0]
set_location_assignment PIN_AP3 -to PCIE_RX_N[1]
set_location_assignment PIN_AT3 -to PCIE_RX_N[2]
set_location_assignment PIN_AV3 -to PCIE_RX_N[3]

set_location_assignment PIN_AL7 -to PCIE_TX_P[0]
set_location_assignment PIN_AN7 -to PCIE_TX_P[1]
set_location_assignment PIN_AR7 -to PCIE_TX_P[2]
set_location_assignment PIN_AU7 -to PCIE_TX_P[3]
set_location_assignment PIN_AL10 -to PCIE_TX_N[0]
set_location_assignment PIN_AN10 -to PCIE_TX_N[1]
set_location_assignment PIN_AR10 -to PCIE_TX_N[2]
set_location_assignment PIN_AU10 -to PCIE_TX_N[3]
set_location_assignment PIN_BW28 -to PCIE_RESET_N
set_location_assignment PIN_DR68 -to PCIE_REFCLK0
#set_location_assignment PIN_DM70 -to "PCIE_REFCLK0(n)"
set_location_assignment PIN_CU68 -to PCIE_REFCLK1

set_location_assignment PIN_N45 -to SYS_REFCLK
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to qsfp_ref_clk

set_instance_assignment -name IO_STANDARD "1.2 V" -to b_sel_1pps_inout
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_1pps_to_10mhz
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_10mhz_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_shdn_10mhz_out
set_instance_assignment -name SLEW_RATE 0 -to b_sel_1pps_inout
set_instance_assignment -name SLEW_RATE 0 -to b_shdn_1pps_to_10mhz
set_instance_assignment -name SLEW_RATE 0 -to b_shdn_10mhz_in
set_instance_assignment -name SLEW_RATE 0 -to b_shdn_10mhz_out
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to cvl_serial_rx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to cvl_serial_tx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp_serial[*].tx_p[*]
set_instance_assignment -name IO_STANDARD "HSSI DIFFERENTIAL I/O" -to qsfp_serial[*].rx_p[*]
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_resetn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_lpmode -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_modeseln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_intn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_modprsln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_power_good -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_resetn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_lpmode -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_modeseln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_intn -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_modprsln -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_power_good -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_i2c_scl -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_i2c_sda -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_i2c_scl -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_i2c_sda -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_resetn -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_lpmode -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_modeseln -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_resetn -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_lpmode -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_modeseln -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_i2c_scl -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_i2c_sda -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_i2c_scl -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_i2c_sda -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_act_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_act_r -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_act_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_act_r -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_speed_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpa_speed_y -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_speed_g -entity top
set_instance_assignment -name IO_STANDARD "1.2 V" -to qsfpb_speed_y -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_act_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_act_r -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_act_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_act_r -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_speed_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpa_speed_y -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_speed_g -entity top
set_instance_assignment -name SLEW_RATE 0 -to qsfpb_speed_y -entity top
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK0
set_instance_assignment -name IO_STANDARD HCSL -to PCIE_REFCLK1
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to fpga_pcie_refclk3_100m
set_instance_assignment -name IO_STANDARD 1.0V -to PCIE_RESET_N
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_P
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_P
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to SYS_REFCLK
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to SYS_REFCLK
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_cs_n
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_d
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_oe
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_qspi_clk
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_cs_n
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_d
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_oe
set_instance_assignment -name SLEW_RATE 0 -to fpga_qspi_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_m10_ibus
set_instance_assignment -name SLEW_RATE 0 -to fpga_m10_ibus
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_fabric_reset_n
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_seu_error
set_instance_assignment -name SLEW_RATE 0 -to fpga_seu_error
set_instance_assignment -name SLEW_RATE 0 -to arb_in
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_1pps_fpga_clk
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to tod_fpga_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_d
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_clkout
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_testio_clkin
set_instance_assignment -name SLEW_RATE 0 -to fm61_testio_d
set_instance_assignment -name SLEW_RATE 0 -to fm61_testio_clkout
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_m10_crc_error
set_instance_assignment -name IO_STANDARD "1.2 V" -to m10_conf_done
set_instance_assignment -name IO_STANDARD "1.2 V" -to b_fpga_hps_zl_gpout
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_smclk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_smdat
set_instance_assignment -name SLEW_RATE 0 -to fm61_smdat
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_scl
set_instance_assignment -name IO_STANDARD "1.2 V" -to fm61_sda
set_instance_assignment -name SLEW_RATE 0 -to fm61_scl
set_instance_assignment -name SLEW_RATE 0 -to fm61_sda

set_instance_assignment -name HSSI_PARAMETER "rx_ac_couple_enable=ENABLE" -to qsfp_serial[*].rx_p[*] -entity top
set_instance_assignment -name HSSI_PARAMETER "rx_onchip_termination=RX_ONCHIP_TERMINATION_R_2" -to qsfp_serial[*].rx_p[*] -entity top
#set_location_assignment PIN_A50 -to master_tod_top_0_pulse_per_second
set_instance_assignment -name HSSI_PARAMETER "txeq_main_tap=35" -to qsfp_serial[*].tx_p[*] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_1=5" -to qsfp_serial[*].tx_p[*] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_pre_tap_2=0" -to qsfp_serial[*].tx_p[*] -entity top
set_instance_assignment -name HSSI_PARAMETER "txeq_post_tap_1=0" -to qsfp_serial[*].tx_p[*] -entity top
