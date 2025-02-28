// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//  CSR address 
//
//-----------------------------------------------------------------------------
`ifndef __TEST_CSR_DEFS__
`define __TEST_CSR_DEFS__

`include "ofs_ip_cfg_db.vh"

package test_csr_defs;

    localparam BAR = 3'h0; 
    localparam PG_UART_DFH          = 32'h60000;
    localparam NUMBER_OF_LINKS = `OFS_FIM_IP_CFG_PCIE_SS_NUM_LINKS;
endpackage

`endif
