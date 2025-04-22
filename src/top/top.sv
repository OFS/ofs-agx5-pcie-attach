// Copyright (C) 2021 Intel Corporation.
// SPDX-License-Identifier: MIT



//
// Description
//-----------------------------------------------------------------------------------------------
//
//   Platform top level module
//
//-----------------------------------------------------------------------------------------------

                   `include "fpga_defines.vh"
                   `include "ofs_ip_cfg_db.vh"
                    import   ofs_fim_cfg_pkg::*      ;
                    import   ofs_fim_if_pkg::*       ;
                    import   pcie_ss_axis_pkg::*     ;


//-----------------------------------------------------------------------------------------------
// Module ports
//-----------------------------------------------------------------------------------------------

module top 
   import ofs_fim_mem_if_pkg::*;
   import top_cfg_pkg::*;
 (
                    input                                       SYS_REFCLK,   // System Reference Clock (100MHz)
                                      
// Local Memory technology interfaces
`ifdef INCLUDE_LOCAL_MEM
`ifdef INCLUDE_DDR4
                    ofs_fim_mem_ddr4_ref_clk_if.ip              ddr4_mem_ref_clk [NUM_DDR4_CHANNELS-1:0],
 `ifdef HAS_IFC_AGX5_DDR4_SS_MEM_DDR4_IF
                    agx5_ddr4_ss_mem_ddr4_if.ip                 ddr4_mem         [NUM_GROUP_0_DDR4_CHANNELS-1:0],
 `endif
 `ifdef HAS_IFC_AGX5_DDR4_SS_MEM_G1_DDR4_IF
                    agx5_ddr4_ss_mem_g1_ddr4_if.ip              ddr4_mem_group_1 [NUM_GROUP_1_DDR4_CHANNELS-1:0],
 `endif
`endif // INCLUDE_DDR4
`endif // INCLUDE_LOCAL_MEM

                    input                                       PCIE_REFCLK0                      ,// PCIe clock
                    input                                       PCIE_REFCLK1                      ,// PCIe clock
                    input                                       PCIE_RESET_N                      ,// PCIe reset
                    input  [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_RX_P                         ,// PCIe RX_P pins 
                    input  [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_RX_N                         ,// PCIe RX_N pins 
                    output [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_TX_P                         ,// PCIe TX_P pins 
                    output [ofs_fim_cfg_pkg::PCIE_LANES-1:0]    PCIE_TX_N                         // PCIe TX_N pins  

);

localparam MM_ADDR_WIDTH = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam MM_DATA_WIDTH = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;
localparam PCIE_NUM_LINKS = top_cfg_pkg::FIM_NUM_LINKS;

//-----------------------------------------------------------------------------------------------
// Internal signals
//-----------------------------------------------------------------------------------------------

// clock signals
wire clk_sys, clk_sys_div2, clk_sys_div4;
wire clk_100m;
wire clk_50m;
wire clk_csr;
wire clk_noc_fab, clk_noc_fab_wr;

logic h2f_reset, h2f_reset_q;

// reset signals
logic pll_locked;
logic ninit_done;
logic [PCIE_NUM_LINKS-1:0] pcie_reset_status;
logic [PCIE_NUM_LINKS-1:0] pcie_cold_rst_ack_n;
logic [PCIE_NUM_LINKS-1:0] pcie_warm_rst_ack_n;
logic [PCIE_NUM_LINKS-1:0] pcie_cold_rst_n;
logic [PCIE_NUM_LINKS-1:0] pcie_warm_rst_n;
logic [PCIE_NUM_LINKS-1:0] rst_n_sys;
logic [PCIE_NUM_LINKS-1:0] rst_n_sys_pcie;
logic [PCIE_NUM_LINKS-1:0] rst_n_sys_afu;
logic rst_n_sys_mem;
logic rst_n_sys_hps;
logic [PCIE_NUM_LINKS-1:0] rst_n_100m;
logic [PCIE_NUM_LINKS-1:0] rst_n_50m;
logic [PCIE_NUM_LINKS-1:0] rst_n_csr;
logic [PCIE_NUM_LINKS-1:0] pwr_good_n;
logic [PCIE_NUM_LINKS-1:0] pwr_good_csr_clk_n;

//Ctrl Shadow ports
logic         p0_ss_app_st_ctrlshadow_tvalid;
logic [39:0]  p0_ss_app_st_ctrlshadow_tdata;

// These used to be registers for explicit reset duplication. Now that
// rst_ctrl() automatically adds a duplication tree, they are simple
// assignment. Adding a register here would just get in the way.
assign rst_n_sys_pcie = rst_n_sys;
assign rst_n_sys_afu  = rst_n_sys;
assign rst_n_sys_mem  = rst_n_sys[0];
assign rst_n_sys_hps  = rst_n_sys[0];

always_ff @(posedge clk_sys) begin
  h2f_reset_q <= h2f_reset;
end

//-----------------------------------------------------------------------------------------------
// Instantiation of the AXI_L fabric interfaces on PF0 that address maps all the components on 
// the DFL list.Each of the components connected on the DFL have an AXI-L fabric connection that 
// allows the host to read registers, traverse the list to discover these componets and load the 
// associated drivers etc.
// The fabric is divided into 2 interconnected sections: the Board Peripheral fabric(BPF) that 
// maps the subsystems that control the board interfaces (PCIe, Memory, etc) and the 
// AFU Peripheral fabric (APF) which maps components in the AFU region (Protocol checker, 
// port gasket etc). 
// The fabrics are generated using scripts with a text file, with the components and the address 
// map, as the input. Please refer to the README in $OFS_ROOTDIR/src/pd_qsys for more details. This
// script also generates the fabric_width_pkg used below so that the widths of address busses are 
// consistent with the input specified. 
// In order to remove/add components to the DFL list, modify the qsys fabric in 
// src/pd_qsys to add/delete the component and then edit the list below to add/remove the interface. 
// If adding a component connect up the port to the new instance.
//-----------------------------------------------------------------------------------------------
// AXI4-lite interfaces
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_apf_mst_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_apf_mst_address_width)) bpf_apf_mst_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_apf_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_apf_slv_address_width)) bpf_apf_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_fme_mst_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_fme_mst_address_width)) bpf_fme_mst_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_fme_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_fme_slv_address_width)) bpf_fme_slv_if();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_pcie_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_pcie_slv_address_width)) bpf_pcie_slv_if[PCIE_NUM_LINKS-1:0]();
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(fabric_width_pkg::bpf_emif_slv_address_width), .ARADDR_WIDTH(fabric_width_pkg::bpf_emif_slv_address_width)) bpf_emif_slv_if();



// AXIS PCIe Subsystem Interface
pcie_ss_axis_if   pcie_ss_axis_rx_if [PCIE_NUM_LINKS-1:0] (.clk (clk_sys),.rst_n(rst_n_sys_pcie));
pcie_ss_axis_if   pcie_ss_axis_tx_if [PCIE_NUM_LINKS-1:0] (.clk (clk_sys),.rst_n(rst_n_sys_pcie));
pcie_ss_axis_if   pcie_ss_axis_rxreq_if [PCIE_NUM_LINKS-1:0] (.clk (clk_sys),.rst_n(rst_n_sys_pcie));
// TXREQ is only headers (read requests)
pcie_ss_axis_if #(
   .DATA_W(pcie_ss_hdr_pkg::HDR_WIDTH),
   .USER_W(ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH)
) pcie_ss_axis_txreq_if[PCIE_NUM_LINKS-1:0] (.clk (clk_sys),.rst_n(rst_n_sys_pcie));


pcie_ss_axis_pkg::t_axis_pcie_flr pcie_flr_req[PCIE_NUM_LINKS-1:0];
pcie_ss_axis_pkg::t_axis_pcie_flr pcie_flr_rsp[PCIE_NUM_LINKS-1:0];

// Partial Reconfiguration FIFO Parity Error from PR Controller
logic pr_parity_error;

// AVST interface
ofs_fim_axi_lite_if m_afu_lite();
ofs_fim_axi_lite_if s_afu_lite();


// Completion Timeout Interface
pcie_ss_axis_pkg::t_axis_pcie_cplto axis_cpl_timeout[PCIE_NUM_LINKS-1:0];

// Tag Mode
pcie_ss_axis_pkg::t_pcie_tag_mode tag_mode[PCIE_NUM_LINKS-1:0];


`ifdef INCLUDE_LOCAL_MEM
localparam AFU_MEM_CHANNELS = ofs_fim_mem_if_pkg::NUM_MEM_CHANNELS;

logic [4095:0] hps2emif;
logic [4095:0] emif2hps;
logic [1:0]    hps2emif_gp;
logic          emif2hps_gp;

//AFU EMIF AXI-MM IF
ofs_fim_emif_axi_mm_if #(
   .AWID_WIDTH   (ofs_fim_mem_if_pkg::AXI_MEM_AWID_WIDTH),
   .AWADDR_WIDTH (ofs_fim_mem_if_pkg::AXI_MEM_AWADDR_WIDTH),
   .AWUSER_WIDTH (ofs_fim_mem_if_pkg::AXI_MEM_AWUSER_WIDTH),
   .AWLEN_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_BURST_LEN_WIDTH),
   .WDATA_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_WDATA_WIDTH),
   .WUSER_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_WUSER_WIDTH),
   .BID_WIDTH    (ofs_fim_mem_if_pkg::AXI_MEM_BID_WIDTH),
   .BUSER_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_BUSER_WIDTH),
   .ARID_WIDTH   (ofs_fim_mem_if_pkg::AXI_MEM_ARID_WIDTH),
   .ARADDR_WIDTH (ofs_fim_mem_if_pkg::AXI_MEM_ARADDR_WIDTH),
   .ARUSER_WIDTH (ofs_fim_mem_if_pkg::AXI_MEM_ARUSER_WIDTH),
   .ARLEN_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_BURST_LEN_WIDTH),
   .RDATA_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_RDATA_WIDTH),
   .RID_WIDTH    (ofs_fim_mem_if_pkg::AXI_MEM_RID_WIDTH),
   .RUSER_WIDTH  (ofs_fim_mem_if_pkg::AXI_MEM_RUSER_WIDTH)
) afu_ext_mem_if [AFU_MEM_CHANNELS-1:0] ();

`endif

//-----------------------------------------------------------------------------------------------
// Connections
//-----------------------------------------------------------------------------------------------
assign clk_csr   = clk_100m;
assign rst_n_csr = rst_n_100m;

//-----------------------------------------------------------------------------------------------
// Configuration reset release IP
//-----------------------------------------------------------------------------------------------
`ifdef SIM_MODE
   // The simulation flow may manage ninit_done in the testbench, holding it
   // high at the start.
   assign ninit_done = 1'b0;
`else
   cfg_mon cfg_mon (
      .ninit_done (ninit_done)
   );
`endif

//-----------------------------------------------------------------------------------------------
// System PLL - instantiation of IOPLL to derive various clocks needed for the design.
// It derives the main design clock (470 MHz for the x16 design for e.g.) on which the majority 
// of the logic runs
// It also derives the ~100 MHz CSR clock along with a couple of related clocks to pass to the 
// port gasket for use by the AFUs
//-----------------------------------------------------------------------------------------------

sys_pll sys_pll (
   .rst                (ninit_done                ),
   .refclk             (SYS_REFCLK                ), // 100 MHz
   .locked             (pll_locked                ),
   .outclk_0           (clk_sys                   ), // 350 MHz for x8 and 470 MHz for x16
   .outclk_1           (clk_100m                  ), // 100 MHz
   .outclk_2           (clk_sys_div2              ), // 175 MHz for x8 and 235 MHz for x16
   .outclk_3           (clk_noc_fab_wr            ), // 600 MHz for driving wr fabric internal to NOC 
   .outclk_4           (clk_50m                   ), // 50 MHz
   .outclk_5           (clk_sys_div4              ), // 87.5 MHz for x8 and 117.5 MHz for x16
   .outclk_6           (clk_noc_fab               )  // 350 MHz for driving fabric side of NoC
);

//-----------------------------------------------------------------------------------------------
// Reset controller
//-----------------------------------------------------------------------------------------------

for (genvar j=0; j<PCIE_NUM_LINKS; j++) begin : PCIE_RST_CTRL
    rst_ctrl rst_ctrl (
    .clk_sys             (clk_sys                  ),
    .clk_100m            (clk_100m                 ),
    .clk_50m             (clk_50m                  ),
    .pll_locked          (pll_locked               ),
    .pcie_reset_status   (pcie_reset_status[j]     ),
    .pcie_cold_rst_ack_n (pcie_cold_rst_ack_n[j]   ),
    .pcie_warm_rst_ack_n (pcie_warm_rst_ack_n[j]   ),
                                                  
    .ninit_done          (ninit_done               ),
    .rst_n_sys           (rst_n_sys[j]             ),  // system reset synchronous to clk_sys
    .rst_n_100m          (rst_n_100m[j]            ),  // system reset synchronous to clk_100m
    .rst_n_50m           (rst_n_50m[j]             ),  // system reset synchronous to clk_50m
    .pwr_good_n          (pwr_good_n[j]            ),  // system reset synchronous to clk_100m
    .pwr_good_csr_clk_n  (pwr_good_csr_clk_n[j]    ),  // power good reset synchronous to clk_sys 
    .pcie_cold_rst_n     (pcie_cold_rst_n[j]       ),
    .pcie_warm_rst_n     (pcie_warm_rst_n[j]       )
    ); 
end 

//-----------------------------------------------------------------------------------------------
// Wrap PCIe pins in an interface
//-----------------------------------------------------------------------------------------------

ofs_fim_pcie_ss_pins_if #(.PCIE_LANES(ofs_fim_cfg_pkg::PCIE_LANES)) pin_pcie();
assign pin_pcie.refclk0_p = PCIE_REFCLK0;
assign pin_pcie.refclk1_p = PCIE_REFCLK1;
assign pin_pcie.in_perst_n = PCIE_RESET_N;
assign pin_pcie.rx_p = PCIE_RX_P;
assign pin_pcie.rx_n = PCIE_RX_N;
assign PCIE_TX_P = pin_pcie.tx_p;
assign PCIE_TX_N = pin_pcie.tx_n;

`ifdef CONFIG_AGILEX5
   // PCIe GTS reset sequencer
   agilex5_srcss_gts srcss_gts (
      .o_pma_cu_clk(pin_pcie.in_flux_clk[0])
     );

   assign pin_pcie.in_flux_clk[1] = 1'b0;
`else
   // Unused
   assign pin_pcie.in_flux_clk = '0;
`endif

//-----------------------------------------------------------------------------------------------
// PCIe Subsystem - this IP instantiates the QHIP and builds various features around it such
// as a standard AXI interface, standardized register interface for the driver, interrupt support
// data mover mode(hides complexity of TLPs while implementing functionality such as completion 
// combining etc). The AXI user clock is asynchronous to the reference and the QHIP clock.
//-----------------------------------------------------------------------------------------------
 pcie_wrapper #(  
     .PCIE_LANES       (ofs_fim_cfg_pkg::PCIE_LANES),
     .PCIE_NUM_LINKS   (PCIE_NUM_LINKS),
     .MM_ADDR_WIDTH    (MM_ADDR_WIDTH),
     .MM_DATA_WIDTH    (MM_DATA_WIDTH),
     .FEAT_ID          (12'h020),
     .FEAT_VER         (4'h0),
     .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_pcie_slv_next_dfh_offset),
     .END_OF_LIST      (fabric_width_pkg::bpf_pcie_slv_eol)  
) pcie_wrapper (
   .fim_clk                        (clk_sys                  ),
   .fim_rst_n                      (rst_n_sys_pcie           ),
   .csr_clk                        (clk_csr                  ),
   .csr_rst_n                      (rst_n_csr                ),
   .ninit_done                     (ninit_done               ),
   .reset_status                   (pcie_reset_status        ),  
   .subsystem_cold_rst_n        (pcie_cold_rst_n          ),     
   .subsystem_warm_rst_n        (pcie_warm_rst_n          ),
   .subsystem_cold_rst_ack_n    (pcie_cold_rst_ack_n      ),
   .subsystem_warm_rst_ack_n    (pcie_warm_rst_ack_n      ),
   .pin_pcie                       (pin_pcie                 ),
   .ss_app_st_ctrlshadow_tvalid     (ss_app_st_ctrlshadow_tvalid ),
   .ss_app_st_ctrlshadow_tdata      (ss_app_st_ctrlshadow_tdata  ),
   .axi_st_rxreq_if                (pcie_ss_axis_rxreq_if    ),
   .axi_st_rx_if                   (pcie_ss_axis_rx_if       ),
   .axi_st_tx_if                   (pcie_ss_axis_tx_if       ),
   .axi_st_txreq_if                (pcie_ss_axis_txreq_if    ),
   .csr_lite_if                    (bpf_pcie_slv_if          ), 
   .axi_st_flr_req                 (pcie_flr_req                ),
   .axi_st_flr_rsp                 (pcie_flr_rsp                ),
   .axis_cpl_timeout               (axis_cpl_timeout            ),
   .tag_mode                       (tag_mode                    )
);

//-----------------------------------------------------------------------------------------------
// FME
//-----------------------------------------------------------------------------------------------
  fme_top #(
     .ST2MM_MSIX_ADDR (fabric_width_pkg::apf_st2mm_slv_baseaddress + 'h10),
     .NEXT_DFH_OFFSET (fabric_width_pkg::bpf_fme_slv_next_dfh_offset)
  ) fme_top(
          .clk               (clk_csr                   ),
          .rst_n             (rst_n_csr[0]              ),
          .pr_parity_error   (pr_parity_error           ),
          .pwr_good_n        (pwr_good_n[0]             ),
          .axi_lite_m_if     (bpf_fme_mst_if            ),
          .axi_lite_s_if     (bpf_fme_slv_if            )
         );


//-----------------------------------------------------------------------------------------------
// AFU - The AFU_top hierarchy contains the following
// * protocol checker  - Module responsible for error handling and debug. 
// * st2mm             - Module that primarily handles streaming to AXI-MM conversion 
// * fim_afu_instances - This hierarchy contains the workloads that are instantiated in the static 
//                       region. This file is expected to be modified by the customer to instantiate
//                       other workloads as needed
// * port gasket and port_afu_instances - this hierarchy instanties the PR controller and assosciated 
//                       logic needed for partial reconfiguration. The workloads in the PR region 
//                       are instanted in port_afu_instances hierarchy. This is expected to be modified
//                       by the customer to instantiate the PR workloads
//-----------------------------------------------------------------------------------------------
  afu_top #(
          .PCIE_NUM_LINKS      (PCIE_NUM_LINKS)
`ifdef INCLUDE_LOCAL_MEM
         ,.AFU_MEM_CHANNEL     (AFU_MEM_CHANNELS   )
`endif
  )afu_top(
         .SYS_REFCLK          (SYS_REFCLK                   ),
         .clk                 (clk_sys                      ),
         .rst_n               (rst_n_sys_afu                ),
         .clk_csr             (clk_csr                      ),
         .rst_n_csr           (rst_n_csr                    ),
         .clk_50m             (clk_50m                      ),
         .rst_n_50m           (rst_n_50m                    ),
         .pwr_good_csr_clk_n  (pwr_good_csr_clk_n[0]        ), // power good reset synchronous to csr_clk
         .clk_div2            (clk_sys_div2                 ),
         .clk_div4            (clk_sys_div4                 ),

         .cpri_refclk_184_32m (cr3_cpri_reflclk_clk_184_32m ),
         .cpri_refclk_153_6m  (cr3_cpri_reflclk_clk_153_6m  ),
         
         .pcie_flr_req        (pcie_flr_req                 ),
         .pcie_flr_rsp        (pcie_flr_rsp                 ),
         .pr_parity_error     (pr_parity_error              ),
         .tag_mode            (tag_mode                     ),

         .apf_bpf_slv_if      (bpf_apf_mst_if               ),
         .apf_bpf_mst_if      (bpf_apf_slv_if               ),
         
         .pcie_ss_axis_rxreq  (pcie_ss_axis_rxreq_if        ),
         .pcie_ss_axis_rx     (pcie_ss_axis_rx_if           ),
         .pcie_ss_axis_tx     (pcie_ss_axis_tx_if           ),
         .pcie_ss_axis_txreq  (pcie_ss_axis_txreq_if        )
`ifdef INCLUDE_LOCAL_MEM
         ,.ext_mem_if          (afu_ext_mem_if)
`endif

         );



//-----------------------------------------------------------------------------------------------
// BPF - Board Peripheral Fabric. This is a 64-b AXI-Lite Qsys generated interconnect fabric which
// (with the APF) address maps and connects up the components that form the DFL list to the host. 
// This fabric is clocked by the clk_csr. The components connected on the BPF include the subsystems
// (PCIe,MEM), FME etc
// The address space is assigned in Qsys based on the number of bits needed by the slave
//-----------------------------------------------------------------------------------------------
   bpf 
   bpf (
          .clk_clk              (clk_csr                   ),
          .rst_n_reset_n        (rst_n_csr[0]              ),
          
          .bpf_apf_mst_awaddr   (bpf_apf_mst_if.awaddr     ),
          .bpf_apf_mst_awprot   (bpf_apf_mst_if.awprot     ),
          .bpf_apf_mst_awvalid  (bpf_apf_mst_if.awvalid    ),
          .bpf_apf_mst_awready  (bpf_apf_mst_if.awready    ),
          .bpf_apf_mst_wdata    (bpf_apf_mst_if.wdata      ),
          .bpf_apf_mst_wstrb    (bpf_apf_mst_if.wstrb      ),
          .bpf_apf_mst_wvalid   (bpf_apf_mst_if.wvalid     ),
          .bpf_apf_mst_wready   (bpf_apf_mst_if.wready     ),
          .bpf_apf_mst_bresp    (bpf_apf_mst_if.bresp      ),
          .bpf_apf_mst_bvalid   (bpf_apf_mst_if.bvalid     ),
          .bpf_apf_mst_bready   (bpf_apf_mst_if.bready     ),
          .bpf_apf_mst_araddr   (bpf_apf_mst_if.araddr     ),
          .bpf_apf_mst_arprot   (bpf_apf_mst_if.arprot     ),
          .bpf_apf_mst_arvalid  (bpf_apf_mst_if.arvalid    ),
          .bpf_apf_mst_arready  (bpf_apf_mst_if.arready    ),
          .bpf_apf_mst_rdata    (bpf_apf_mst_if.rdata      ),
          .bpf_apf_mst_rresp    (bpf_apf_mst_if.rresp      ),
          .bpf_apf_mst_rvalid   (bpf_apf_mst_if.rvalid     ),
          .bpf_apf_mst_rready   (bpf_apf_mst_if.rready     ),
          
          .bpf_apf_slv_awaddr   (bpf_apf_slv_if.awaddr     ),
          .bpf_apf_slv_awprot   (bpf_apf_slv_if.awprot     ),
          .bpf_apf_slv_awvalid  (bpf_apf_slv_if.awvalid    ),
          .bpf_apf_slv_awready  (bpf_apf_slv_if.awready    ),
          .bpf_apf_slv_wdata    (bpf_apf_slv_if.wdata      ),
          .bpf_apf_slv_wstrb    (bpf_apf_slv_if.wstrb      ),
          .bpf_apf_slv_wvalid   (bpf_apf_slv_if.wvalid     ),
          .bpf_apf_slv_wready   (bpf_apf_slv_if.wready     ),
          .bpf_apf_slv_bresp    (bpf_apf_slv_if.bresp      ),
          .bpf_apf_slv_bvalid   (bpf_apf_slv_if.bvalid     ),
          .bpf_apf_slv_bready   (bpf_apf_slv_if.bready     ),
          .bpf_apf_slv_araddr   (bpf_apf_slv_if.araddr     ),
          .bpf_apf_slv_arprot   (bpf_apf_slv_if.arprot     ),
          .bpf_apf_slv_arvalid  (bpf_apf_slv_if.arvalid    ),
          .bpf_apf_slv_arready  (bpf_apf_slv_if.arready    ),
          .bpf_apf_slv_rdata    (bpf_apf_slv_if.rdata      ),
          .bpf_apf_slv_rresp    (bpf_apf_slv_if.rresp      ),
          .bpf_apf_slv_rvalid   (bpf_apf_slv_if.rvalid     ),
          .bpf_apf_slv_rready   (bpf_apf_slv_if.rready     ),
                
          .bpf_fme_slv_awaddr   (bpf_fme_slv_if.awaddr     ),
          .bpf_fme_slv_awprot   (bpf_fme_slv_if.awprot     ),
          .bpf_fme_slv_awvalid  (bpf_fme_slv_if.awvalid    ),
          .bpf_fme_slv_awready  (bpf_fme_slv_if.awready    ),
          .bpf_fme_slv_wdata    (bpf_fme_slv_if.wdata      ),
          .bpf_fme_slv_wstrb    (bpf_fme_slv_if.wstrb      ),
          .bpf_fme_slv_wvalid   (bpf_fme_slv_if.wvalid     ),
          .bpf_fme_slv_wready   (bpf_fme_slv_if.wready     ),
          .bpf_fme_slv_bresp    (bpf_fme_slv_if.bresp      ),
          .bpf_fme_slv_bvalid   (bpf_fme_slv_if.bvalid     ),
          .bpf_fme_slv_bready   (bpf_fme_slv_if.bready     ),
          .bpf_fme_slv_araddr   (bpf_fme_slv_if.araddr     ),
          .bpf_fme_slv_arprot   (bpf_fme_slv_if.arprot     ),
          .bpf_fme_slv_arvalid  (bpf_fme_slv_if.arvalid    ),
          .bpf_fme_slv_arready  (bpf_fme_slv_if.arready    ),
          .bpf_fme_slv_rdata    (bpf_fme_slv_if.rdata      ),
          .bpf_fme_slv_rresp    (bpf_fme_slv_if.rresp      ),
          .bpf_fme_slv_rvalid   (bpf_fme_slv_if.rvalid     ),
          .bpf_fme_slv_rready   (bpf_fme_slv_if.rready     ),
         
          // PCIe Link0 csr tied for fabric, other links are tied off 
          .bpf_pcie_slv_awaddr  (bpf_pcie_slv_if[0].awaddr    ), 
          .bpf_pcie_slv_awprot  (bpf_pcie_slv_if[0].awprot    ), 
          .bpf_pcie_slv_awvalid (bpf_pcie_slv_if[0].awvalid   ), 
          .bpf_pcie_slv_awready (bpf_pcie_slv_if[0].awready   ), 
          .bpf_pcie_slv_wdata   (bpf_pcie_slv_if[0].wdata     ), 
          .bpf_pcie_slv_wstrb   (bpf_pcie_slv_if[0].wstrb     ), 
          .bpf_pcie_slv_wvalid  (bpf_pcie_slv_if[0].wvalid    ), 
          .bpf_pcie_slv_wready  (bpf_pcie_slv_if[0].wready    ), 
          .bpf_pcie_slv_bresp   (bpf_pcie_slv_if[0].bresp     ), 
          .bpf_pcie_slv_bvalid  (bpf_pcie_slv_if[0].bvalid    ), 
          .bpf_pcie_slv_bready  (bpf_pcie_slv_if[0].bready    ), 
          .bpf_pcie_slv_araddr  (bpf_pcie_slv_if[0].araddr    ), 
          .bpf_pcie_slv_arprot  (bpf_pcie_slv_if[0].arprot    ), 
          .bpf_pcie_slv_arvalid (bpf_pcie_slv_if[0].arvalid   ), 
          .bpf_pcie_slv_arready (bpf_pcie_slv_if[0].arready   ), 
          .bpf_pcie_slv_rdata   (bpf_pcie_slv_if[0].rdata     ), 
          .bpf_pcie_slv_rresp   (bpf_pcie_slv_if[0].rresp     ), 
          .bpf_pcie_slv_rvalid  (bpf_pcie_slv_if[0].rvalid    ), 
          .bpf_pcie_slv_rready  (bpf_pcie_slv_if[0].rready    ), 
 
          .bpf_emif_slv_awaddr   (bpf_emif_slv_if.awaddr  ),
          .bpf_emif_slv_awprot   (bpf_emif_slv_if.awprot  ),
          .bpf_emif_slv_awvalid  (bpf_emif_slv_if.awvalid ),
          .bpf_emif_slv_awready  (bpf_emif_slv_if.awready ),
          .bpf_emif_slv_wdata    (bpf_emif_slv_if.wdata   ),
          .bpf_emif_slv_wstrb    (bpf_emif_slv_if.wstrb   ),
          .bpf_emif_slv_wvalid   (bpf_emif_slv_if.wvalid  ),
          .bpf_emif_slv_wready   (bpf_emif_slv_if.wready  ),
          .bpf_emif_slv_bresp    (bpf_emif_slv_if.bresp   ),
          .bpf_emif_slv_bvalid   (bpf_emif_slv_if.bvalid  ),
          .bpf_emif_slv_bready   (bpf_emif_slv_if.bready  ),
          .bpf_emif_slv_araddr   (bpf_emif_slv_if.araddr  ),
          .bpf_emif_slv_arprot   (bpf_emif_slv_if.arprot  ),
          .bpf_emif_slv_arvalid  (bpf_emif_slv_if.arvalid ),
          .bpf_emif_slv_arready  (bpf_emif_slv_if.arready ),
          .bpf_emif_slv_rdata    (bpf_emif_slv_if.rdata   ),
          .bpf_emif_slv_rresp    (bpf_emif_slv_if.rresp   ),
          .bpf_emif_slv_rvalid   (bpf_emif_slv_if.rvalid  ),
          .bpf_emif_slv_rready   (bpf_emif_slv_if.rready  ),

          .bpf_fme_mst_awaddr   (bpf_fme_mst_if.awaddr     ),
          .bpf_fme_mst_awprot   (bpf_fme_mst_if.awprot     ),
          .bpf_fme_mst_awvalid  (bpf_fme_mst_if.awvalid    ),
          .bpf_fme_mst_awready  (bpf_fme_mst_if.awready    ),
          .bpf_fme_mst_wdata    (bpf_fme_mst_if.wdata      ),
          .bpf_fme_mst_wstrb    (bpf_fme_mst_if.wstrb      ),
          .bpf_fme_mst_wvalid   (bpf_fme_mst_if.wvalid     ),
          .bpf_fme_mst_wready   (bpf_fme_mst_if.wready     ),
          .bpf_fme_mst_bresp    (bpf_fme_mst_if.bresp      ),
          .bpf_fme_mst_bvalid   (bpf_fme_mst_if.bvalid     ),
          .bpf_fme_mst_bready   (bpf_fme_mst_if.bready     ),
          .bpf_fme_mst_araddr   (bpf_fme_mst_if.araddr     ),
          .bpf_fme_mst_arprot   (bpf_fme_mst_if.arprot     ),
          .bpf_fme_mst_arvalid  (bpf_fme_mst_if.arvalid    ),
          .bpf_fme_mst_arready  (bpf_fme_mst_if.arready    ),
          .bpf_fme_mst_rdata    (bpf_fme_mst_if.rdata      ),
          .bpf_fme_mst_rresp    (bpf_fme_mst_if.rresp      ),
          .bpf_fme_mst_rvalid   (bpf_fme_mst_if.rvalid     ),
          .bpf_fme_mst_rready   (bpf_fme_mst_if.rready     )

   );


// Only Link0 CSR connected to BPF fabric. Rest are tied off
generate
    for (genvar j=1; j<PCIE_NUM_LINKS; j++) begin :PCIE_CSR_TIEOFF
        always_comb
        begin  
            bpf_pcie_slv_if[j].awvalid  = 1'b0;
            bpf_pcie_slv_if[j].wvalid   = 1'b0;
            bpf_pcie_slv_if[j].bready   = 1'b0;  
            bpf_pcie_slv_if[j].arvalid  = 1'b0;
            bpf_pcie_slv_if[j].rready   = 1'b0;
        end
    end
endgenerate 

//-----------------------------------------------------------------------------------------------
// Local Memory Subsystem - This a standard wrapper for configured memory subsystems enabled by the project.
// The memory SS wraps the memory channels on the board and sets up the timing parameters etc. 
// It provides a standard AXI interface to connect to workloads.
//-----------------------------------------------------------------------------------------------
`ifdef INCLUDE_LOCAL_MEM
   agx5_ddr4_top #(
      .FEAT_ID          (12'h009),
      .FEAT_VER         (4'h1),
      .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_emif_slv_next_dfh_offset),
      .END_OF_LIST      (fabric_width_pkg::bpf_emif_slv_eol)
   ) mem_ss_top (
      .SYS_REFCLK(SYS_REFCLK),
      .clk       (clk_sys),
      .reset     (~rst_n_sys_mem),

       // AFU ext mem interfaces
      .afu_mem_if   (afu_ext_mem_if),

      .ddr4_mem_if_ref_clk(ddr4_mem_ref_clk),
 `ifdef HAS_IFC_AGX5_DDR4_SS_MEM_DDR4_IF
      .ddr4_mem_if  (ddr4_mem),
 `endif
 `ifdef HAS_IFC_AGX5_DDR4_SS_MEM_G1_DDR4_IF
      .ddr4_mem_if_group_1  (ddr4_mem_group_1),
 `endif

      // CSR interfaces
      .clk_csr     (clk_csr),
      .rst_n_csr   (rst_n_csr[0]),
      .csr_lite_if (bpf_emif_slv_if)
   );
`else
   // Placeholder logic incase MEM SS is not used
   dummy_csr #(
      .FEAT_ID          (12'h000),
      .FEAT_VER         (4'h1),
      .NEXT_DFH_OFFSET  (fabric_width_pkg::bpf_emif_slv_next_dfh_offset),
      .END_OF_LIST      (fabric_width_pkg::bpf_emif_slv_eol)
   ) emif_dummy_csr (
      .clk         (clk_csr),
      .rst_n       (rst_n_csr[0]),
      .csr_lite_if (bpf_emif_slv_if)
   );
`endif
endmodule
