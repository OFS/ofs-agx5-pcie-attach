# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
# Pin and location assignments
#
#-----------------------------------------------------------------------------

# TOD clock
#set_location_assignment PIN_CA78 -to "tod_fpga_clk(n)"
#set_location_assignment PIN_BW78 -to tod_fpga_clk

# System clock
set_location_assignment PIN_BK31 -to SYS_REFCLK -comment IOBANK_6A
set_instance_assignment -name IO_STANDARD "3.3V LVCMOS" -to SYS_REFCLK

# PCIe reset
set_location_assignment PIN_BW28 -to PCIE_RESET_N -comment IOBANK_6A
set_instance_assignment -name IO_STANDARD "3.3V LVCMOS" -to PCIE_RESET_N
set_instance_assignment -name WEAK_PULL_DOWN_RESISTOR ON -to PCIE_RESET_N

# PCIe location
set_location_assignment PIN_AV3 -to PCIE_RX_N[0] -comment IOBANK_4C
set_location_assignment PIN_AT3 -to PCIE_RX_N[1] -comment IOBANK_4C
set_location_assignment PIN_AP3 -to PCIE_RX_N[2] -comment IOBANK_4C
set_location_assignment PIN_AM3 -to PCIE_RX_N[3] -comment IOBANK_4C
set_location_assignment PIN_AV1 -to PCIE_RX_P[0] -comment IOBANK_4C
set_location_assignment PIN_AT1 -to PCIE_RX_P[1] -comment IOBANK_4C
set_location_assignment PIN_AP1 -to PCIE_RX_P[2] -comment IOBANK_4C
set_location_assignment PIN_AM1 -to PCIE_RX_P[3] -comment IOBANK_4C

set_location_assignment PIN_AU10 -to PCIE_TX_N[0] -comment IOBANK_4C
set_location_assignment PIN_AR10 -to PCIE_TX_N[1] -comment IOBANK_4C
set_location_assignment PIN_AN10 -to PCIE_TX_N[2] -comment IOBANK_4C
set_location_assignment PIN_AL10 -to PCIE_TX_N[3] -comment IOBANK_4C
set_location_assignment PIN_AU7 -to PCIE_TX_P[0] -comment IOBANK_4C
set_location_assignment PIN_AR7 -to PCIE_TX_P[1] -comment IOBANK_4C
set_location_assignment PIN_AN7 -to PCIE_TX_P[2] -comment IOBANK_4C
set_location_assignment PIN_AL7 -to PCIE_TX_P[3] -comment IOBANK_4C

set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_RX_P
set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to PCIE_TX_P

set_location_assignment PIN_AT16 -to PCIE_REFCLK0 -comment IOBANK_4C
set_location_assignment PIN_AT21 -to "PCIE_REFCLK0(n)" -comment IOBANK_4C
set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to PCIE_REFCLK0
