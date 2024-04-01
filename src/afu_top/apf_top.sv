// Copyright (C) 2022 Intel Corporation.
// SPDX-License-Identifier: MIT

// Description
//-----------------------------------------------------------------------------
// Host AFU Peripheral Fabric interface wrapper
//-----------------------------------------------------------------------------

module apf_top (
   input logic clk,
   input logic rst_n,

   // APF managers
   ofs_fim_axi_lite_if.slave apf_st2mm_mst_if,
   // APF functions
   ofs_fim_axi_lite_if.master apf_achk_slv_if,
   ofs_fim_axi_lite_if.master apf_dummy_slv_if,
   ofs_fim_axi_lite_if.master apf_st2mm_slv_if
);
	

  p1_apf apf_inst (
   .clk_clk             (clk),
   .rst_n_reset_n       (rst_n),


   .p1_apf_st2mm_mst_awaddr  ( apf_st2mm_mst_if.awaddr),
   .p1_apf_st2mm_mst_awprot  ( apf_st2mm_mst_if.awprot),
   .p1_apf_st2mm_mst_awvalid ( apf_st2mm_mst_if.awvalid),
   .p1_apf_st2mm_mst_awready ( apf_st2mm_mst_if.awready),
   .p1_apf_st2mm_mst_wdata   ( apf_st2mm_mst_if.wdata),
   .p1_apf_st2mm_mst_wstrb   ( apf_st2mm_mst_if.wstrb),
   .p1_apf_st2mm_mst_wvalid  ( apf_st2mm_mst_if.wvalid),
   .p1_apf_st2mm_mst_wready  ( apf_st2mm_mst_if.wready),
   .p1_apf_st2mm_mst_bresp   ( apf_st2mm_mst_if.bresp),
   .p1_apf_st2mm_mst_bvalid  ( apf_st2mm_mst_if.bvalid),
   .p1_apf_st2mm_mst_bready  ( apf_st2mm_mst_if.bready),
   .p1_apf_st2mm_mst_araddr  ( apf_st2mm_mst_if.araddr),
   .p1_apf_st2mm_mst_arprot  ( apf_st2mm_mst_if.arprot),
   .p1_apf_st2mm_mst_arvalid ( apf_st2mm_mst_if.arvalid),
   .p1_apf_st2mm_mst_arready ( apf_st2mm_mst_if.arready),
   .p1_apf_st2mm_mst_rdata   ( apf_st2mm_mst_if.rdata),
   .p1_apf_st2mm_mst_rresp   ( apf_st2mm_mst_if.rresp),
   .p1_apf_st2mm_mst_rvalid  ( apf_st2mm_mst_if.rvalid),
   .p1_apf_st2mm_mst_rready  ( apf_st2mm_mst_if.rready),

   
   .p1_apf_achk_slv_awaddr  (apf_achk_slv_if.awaddr),
   .p1_apf_achk_slv_awprot  (apf_achk_slv_if.awprot),
   .p1_apf_achk_slv_awvalid (apf_achk_slv_if.awvalid),
   .p1_apf_achk_slv_awready (apf_achk_slv_if.awready),
   .p1_apf_achk_slv_wdata   (apf_achk_slv_if.wdata),
   .p1_apf_achk_slv_wstrb   (apf_achk_slv_if.wstrb),
   .p1_apf_achk_slv_wvalid  (apf_achk_slv_if.wvalid),
   .p1_apf_achk_slv_wready  (apf_achk_slv_if.wready),
   .p1_apf_achk_slv_bresp   (apf_achk_slv_if.bresp),
   .p1_apf_achk_slv_bvalid  (apf_achk_slv_if.bvalid),
   .p1_apf_achk_slv_bready  (apf_achk_slv_if.bready),
   .p1_apf_achk_slv_araddr  (apf_achk_slv_if.araddr),
   .p1_apf_achk_slv_arprot  (apf_achk_slv_if.arprot),
   .p1_apf_achk_slv_arvalid (apf_achk_slv_if.arvalid),
   .p1_apf_achk_slv_arready (apf_achk_slv_if.arready),
   .p1_apf_achk_slv_rdata   (apf_achk_slv_if.rdata),
   .p1_apf_achk_slv_rresp   (apf_achk_slv_if.rresp),
   .p1_apf_achk_slv_rvalid  (apf_achk_slv_if.rvalid),
   .p1_apf_achk_slv_rready  (apf_achk_slv_if.rready),

   .p1_apf_dummy_slv_awaddr  ( apf_dummy_slv_if.awaddr),
   .p1_apf_dummy_slv_awprot  ( apf_dummy_slv_if.awprot),
   .p1_apf_dummy_slv_awvalid ( apf_dummy_slv_if.awvalid),
   .p1_apf_dummy_slv_awready ( apf_dummy_slv_if.awready),
   .p1_apf_dummy_slv_wdata   ( apf_dummy_slv_if.wdata),
   .p1_apf_dummy_slv_wstrb   ( apf_dummy_slv_if.wstrb),
   .p1_apf_dummy_slv_wvalid  ( apf_dummy_slv_if.wvalid),
   .p1_apf_dummy_slv_wready  ( apf_dummy_slv_if.wready),
   .p1_apf_dummy_slv_bresp   ( apf_dummy_slv_if.bresp),
   .p1_apf_dummy_slv_bvalid  ( apf_dummy_slv_if.bvalid),
   .p1_apf_dummy_slv_bready  ( apf_dummy_slv_if.bready),
   .p1_apf_dummy_slv_araddr  ( apf_dummy_slv_if.araddr),
   .p1_apf_dummy_slv_arprot  ( apf_dummy_slv_if.arprot),
   .p1_apf_dummy_slv_arvalid ( apf_dummy_slv_if.arvalid),
   .p1_apf_dummy_slv_arready ( apf_dummy_slv_if.arready),
   .p1_apf_dummy_slv_rdata   ( apf_dummy_slv_if.rdata),
   .p1_apf_dummy_slv_rresp   ( apf_dummy_slv_if.rresp),
   .p1_apf_dummy_slv_rvalid  ( apf_dummy_slv_if.rvalid),
   .p1_apf_dummy_slv_rready  ( apf_dummy_slv_if.rready),

   .p1_apf_st2mm_slv_awaddr  ( apf_st2mm_slv_if.awaddr),
   .p1_apf_st2mm_slv_awprot  ( apf_st2mm_slv_if.awprot),
   .p1_apf_st2mm_slv_awvalid ( apf_st2mm_slv_if.awvalid),
   .p1_apf_st2mm_slv_awready ( apf_st2mm_slv_if.awready),
   .p1_apf_st2mm_slv_wdata   ( apf_st2mm_slv_if.wdata),
   .p1_apf_st2mm_slv_wstrb   ( apf_st2mm_slv_if.wstrb),
   .p1_apf_st2mm_slv_wvalid  ( apf_st2mm_slv_if.wvalid),
   .p1_apf_st2mm_slv_wready  ( apf_st2mm_slv_if.wready),
   .p1_apf_st2mm_slv_bresp   ( apf_st2mm_slv_if.bresp),
   .p1_apf_st2mm_slv_bvalid  ( apf_st2mm_slv_if.bvalid),
   .p1_apf_st2mm_slv_bready  ( apf_st2mm_slv_if.bready),
   .p1_apf_st2mm_slv_araddr  ( apf_st2mm_slv_if.araddr),
   .p1_apf_st2mm_slv_arprot  ( apf_st2mm_slv_if.arprot),
   .p1_apf_st2mm_slv_arvalid ( apf_st2mm_slv_if.arvalid),
   .p1_apf_st2mm_slv_arready ( apf_st2mm_slv_if.arready),
   .p1_apf_st2mm_slv_rdata   ( apf_st2mm_slv_if.rdata),
   .p1_apf_st2mm_slv_rresp   ( apf_st2mm_slv_if.rresp),
   .p1_apf_st2mm_slv_rvalid  ( apf_st2mm_slv_if.rvalid),
   .p1_apf_st2mm_slv_rready  ( apf_st2mm_slv_if.rready)

   );

endmodule
