# Copyright (C) 2020 Intel Corporation.
# SPDX-License-Identifier: MIT

#
# Description
#-----------------------------------------------------------------------------
#
#   Platform top level SDC 
#
#-----------------------------------------------------------------------------


#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group {sys_pll|iopll_0_clk_100m} -group { pcie_wrapper|pcie_ss.top|host_pcie.pcie_ss|pcie_ss|coreclkout_hip_pld_clk }

