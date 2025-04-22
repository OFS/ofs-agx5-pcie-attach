// Copyright (C) 2020 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
// Memory Subsystem FIM wrapper
//
//-----------------------------------------------------------------------------

`include "ofs_fim_mem_defines.vh"
`include "ofs_ip_cfg_db.vh"

module agx5_ddr4_top
   import ofs_fim_mem_if_pkg::*;
#(
   parameter bit [11:0] FEAT_ID         = 12'h00f,
   parameter bit [3:0]  FEAT_VER        = 4'h1,
   parameter bit [23:0] NEXT_DFH_OFFSET = 24'h1000,
   parameter bit        END_OF_LIST     = 1'b0
)(
   input  wire                  SYS_REFCLK,
   input  wire                  clk,
   input  wire                  reset,

   ofs_fim_emif_axi_mm_if.emif  afu_mem_if  [NUM_MEM_CHANNELS-1:0],

   ofs_fim_mem_ddr4_ref_clk_if.ip ddr4_mem_if_ref_clk [NUM_DDR4_CHANNELS-1:0],
`ifdef HAS_IFC_AGX5_DDR4_SS_MEM_DDR4_IF
   agx5_ddr4_ss_mem_ddr4_if.ip    ddr4_mem_if         [NUM_GROUP_0_DDR4_CHANNELS-1:0],
`endif
`ifdef HAS_IFC_AGX5_DDR4_SS_MEM_G1_DDR4_IF
   agx5_ddr4_ss_mem_g1_ddr4_if.ip ddr4_mem_if_group_1 [NUM_GROUP_1_DDR4_CHANNELS-1:0],
`endif

   // CSR interfaces
   input                        clk_csr,
   input                        rst_n_csr,
   ofs_fim_axi_lite_if.slave    csr_lite_if
);

`ifndef __AGX5_DDR4_SS_IF_INFO_H__
   $error("Agilex 5 memory subsystem configuration is undefined, but the subsystem has been instantiated in the design!");
`endif

   // AXI-MM interface defined by mem_ss SystemVerilog wrapper module.
   agx5_ddr4_ss_local_mem_if    ss_axi_mm[NUM_MEM_CHANNELS-1:0]();
   wire  [NUM_MEM_CHANNELS-1:0] mem_ss_app_usr_clk;
   wire  [NUM_MEM_CHANNELS-1:0] mem_ss_app_usr_reset_n;

   logic [NUM_DDR4_CHANNELS-1:0] mem_ss_cal_success;
   logic [NUM_DDR4_CHANNELS-1:0] csr_cal_success;

   agx5_ddr4_ss_mem_ddr4_ck_if mem_ck_if[NUM_DDR4_CHANNELS-1:0]();
   wire [NUM_DDR4_CHANNELS-1:0] mem_reset_n;
   wire [NUM_DDR4_CHANNELS-1:0] mem_pll_ref_clk;
   wire [NUM_DDR4_CHANNELS-1:0] mem_oct_rzqin;
   for (genvar c = 0; c < NUM_DDR4_CHANNELS; c++) begin : ref_clk_map
      assign mem_pll_ref_clk[c] = ddr4_mem_if_ref_clk[c].clk;
      assign mem_oct_rzqin[c] = ddr4_mem_if_ref_clk[c].oct_rzqin;
      assign ddr4_mem_if_ref_clk[c].reset_n = mem_reset_n[c];
      assign ddr4_mem_if_ref_clk[c].ck_t = mem_ck_if[c].t;
      assign ddr4_mem_if_ref_clk[c].ck_c = mem_ck_if[c].c;
   end


fim_resync #(
   .SYNC_CHAIN_LENGTH(3),
   .WIDTH(NUM_DDR4_CHANNELS),
   .INIT_VALUE(0),
   .NO_CUT(0)
) mem_ss_cal_success_resync (
   .clk   (clk_csr),
   .reset (!rst_n_csr),
   .d     (mem_ss_cal_success),
   .q     (csr_cal_success)
);

mem_ss_csr #(
   .FEAT_ID          (FEAT_ID),
   .FEAT_VER         (FEAT_VER),
   .NEXT_DFH_OFFSET  (NEXT_DFH_OFFSET),
   .END_OF_LIST      (END_OF_LIST),
   .NUM_MEM_DEVICES  (NUM_DDR4_CHANNELS)
) mem_ss_csr_inst (
   .clk              (clk_csr),
   .rst_n            (rst_n_csr),

   .csr_lite_if      (csr_lite_if),

   .cal_fail         ('0),  // Current EMIF IP only returns success
   .cal_success      (csr_cal_success)
);


agx5_ddr4_ss_sv mem_ss_sv (
   .local_mem(ss_axi_mm),
   .mem_ddr4_cal_done_rst_n_reset_n(mem_ss_cal_success),
   .clk_clk(clk_csr),
   .local_mem_clock_out_clk(mem_ss_app_usr_clk),
   .local_mem_ctrl_ready_reset_n(mem_ss_app_usr_reset_n),

   .mem_ddr4(ddr4_mem_if),
 `ifdef HAS_IFC_AGX5_DDR4_SS_MEM_G1_DDR4_IF
   .mem_g1_ddr4(ddr4_mem_if_group_1),
 `endif
   .mem_ddr4_ck(mem_ck_if),
   .mem_ddr4_reset_n_mem_reset_n(mem_reset_n),
   .mem_ddr4_mem_oct_oct_rzqin(mem_oct_rzqin),
   .mem_ddr4_mem_ref_clk(mem_pll_ref_clk),
   .iopll_refclk_clk(SYS_REFCLK)
);


// Map the OFS AXI-MM interface to the memory subsystem interface
for (genvar c = 0; c < NUM_MEM_CHANNELS; c++) begin : axi_mm_map
   assign afu_mem_if[c].clk     = mem_ss_app_usr_clk[c];
   assign afu_mem_if[c].rst_n   = mem_ss_app_usr_reset_n[c];

   // Write address channel
   assign afu_mem_if[c].awready = ss_axi_mm[c].awready;
   assign ss_axi_mm[c].awvalid  = afu_mem_if[c].awvalid;
   assign ss_axi_mm[c].awid     = afu_mem_if[c].awid;
   assign ss_axi_mm[c].awaddr   = afu_mem_if[c].awaddr;
   assign ss_axi_mm[c].awlen    = afu_mem_if[c].awlen;
   assign ss_axi_mm[c].awsize   = afu_mem_if[c].awsize;
   // Fixed burst type is not supported
   assign ss_axi_mm[c].awburst  = (afu_mem_if[c].awburst == 0) ? 1 : afu_mem_if[c].awburst;
   assign ss_axi_mm[c].awlock   = afu_mem_if[c].awlock;
   assign ss_axi_mm[c].awcache  = afu_mem_if[c].awcache;
   assign ss_axi_mm[c].awprot   = afu_mem_if[c].awprot;
   // Write data channel
   assign afu_mem_if[c].wready  = ss_axi_mm[c].wready;
   assign ss_axi_mm[c].wvalid   = afu_mem_if[c].wvalid;
   assign ss_axi_mm[c].wdata    = afu_mem_if[c].wdata;
   assign ss_axi_mm[c].wstrb    = afu_mem_if[c].wstrb;
   assign ss_axi_mm[c].wlast    = afu_mem_if[c].wlast;
   // Write response channel
   assign ss_axi_mm[c].bready   = afu_mem_if[c].bready;
   assign afu_mem_if[c].bvalid  = ss_axi_mm[c].bvalid;
   assign afu_mem_if[c].bid     = ss_axi_mm[c].bid;
   assign afu_mem_if[c].bresp   = ss_axi_mm[c].bresp;
   assign afu_mem_if[c].buser   = '0;
   // Read address channel
   assign afu_mem_if[c].arready = ss_axi_mm[c].arready;
   assign ss_axi_mm[c].arvalid  = afu_mem_if[c].arvalid;
   assign ss_axi_mm[c].arid     = afu_mem_if[c].arid;
   assign ss_axi_mm[c].araddr   = afu_mem_if[c].araddr;
   assign ss_axi_mm[c].arlen    = afu_mem_if[c].arlen;
   assign ss_axi_mm[c].arsize   = afu_mem_if[c].arsize;
   // Fixed burst type is not supported
   assign ss_axi_mm[c].arburst  = (afu_mem_if[c].arburst == 0) ? 1 : afu_mem_if[c].arburst;
   assign ss_axi_mm[c].arlock   = afu_mem_if[c].arlock;
   assign ss_axi_mm[c].arcache  = afu_mem_if[c].arcache;
   assign ss_axi_mm[c].arprot   = afu_mem_if[c].arprot;
   // Read response channel
   assign ss_axi_mm[c].rready   = afu_mem_if[c].rready;
   assign afu_mem_if[c].rvalid  = ss_axi_mm[c].rvalid;
   assign afu_mem_if[c].rid     = ss_axi_mm[c].rid;
   assign afu_mem_if[c].rdata   = ss_axi_mm[c].rdata;
   assign afu_mem_if[c].rresp   = ss_axi_mm[c].rresp;
   assign afu_mem_if[c].rlast   = ss_axi_mm[c].rlast;
   assign afu_mem_if[c].ruser   = '0;
end

endmodule // agx5_ddr4_top
