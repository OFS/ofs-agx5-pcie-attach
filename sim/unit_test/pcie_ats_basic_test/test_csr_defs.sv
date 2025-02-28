// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  CSR address 
//
//-----------------------------------------------------------------------------
`include "ofs_ip_cfg_db.vh"

package test_csr_defs;
   localparam FME_DFH            = 32'h0;
   localparam FME_SCRATCHPAD0    = FME_DFH + 32'h28;

   localparam PCIE_DFH           = 32'h10000;
   localparam PCIE_SCRATCHPAD    = PCIE_DFH + 32'h8;
   localparam PCIE_TESTPAD       = PCIE_DFH + 32'h28;

   // Configured PCIe capabilities. These parameters are read from the PCIe SS IP
   // and written as macros to a header file included by ofs_ip_cfg_db.vh as
   // part of the Quartus project.

   localparam PCIE_NUM_PFS = `OFS_FIM_IP_CFG_PCIE_SS_NUM_PFS;
   localparam logic PCIE_ATS_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_ATS_CAP_VEC };
   localparam logic PCIE_VF_ATS_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_VF_ATS_CAP_VEC };
   localparam logic PCIE_PRS_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_PRS_CAP_VEC };
   localparam logic PCIE_PASID_CAP_EN[PCIE_NUM_PFS] = { `OFS_FIM_IP_CFG_PCIE_SS_PASID_CAP_VEC };
   localparam NUMBER_OF_LINKS = `OFS_FIM_IP_CFG_PCIE_SS_NUM_LINKS;


endpackage
