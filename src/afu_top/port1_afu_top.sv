// Copyright (C) 2022 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
// AFU module instantiates host PCIe attached User Logic
//-----------------------------------------------------------------------------

`ifdef INCLUDE_HSSI
   `include "ofs_fim_eth_plat_defines.svh"
`endif 

module port1_afu_top 
   import ofs_fim_cfg_pkg::*;
   import pcie_ss_axis_pkg::*;
`ifdef INCLUDE_HSSI
   import ofs_fim_eth_if_pkg::*;
`endif
#(
   parameter AFU_MEM_CHANNEL = 0		 
)(
   input wire                            SYS_REFCLK,
   input wire                            clk,
   input wire                            rst_n,
   input wire                            clk_div2,
   input wire                            clk_div4,
   
   input wire                            clk_csr,
   input wire                            rst_n_csr,
   input wire                            pwr_good_csr_clk_n,
   input wire                            clk_50m,
   input wire                            rst_n_50m,

   // FLR 
   input  t_axis_pcie_flr                pcie_flr_req,
   output t_axis_pcie_flr                pcie_flr_rsp,
   output logic                          pr_parity_error,
   input  t_pcie_tag_mode                tag_mode,


   // PCIE subsystem TX/RX interface
   pcie_ss_axis_if.sink                  pcie_ss_axis_rxreq,
   pcie_ss_axis_if.sink                  pcie_ss_axis_rx,
   pcie_ss_axis_if.source                pcie_ss_axis_tx,
   pcie_ss_axis_if.source                pcie_ss_axis_txreq,

   // output for port_gasket 
   output t_axis_pcie_flr                pg_flr_req,
   input  t_axis_pcie_flr                pg_flr_rsp,
   output logic                          pg_flr_rst_n,

   pcie_ss_axis_if.source                pg_axis_rx_a,
   pcie_ss_axis_if.source                pg_axis_rx_b,
   pcie_ss_axis_if.sink                  pg_axis_tx_a,
   pcie_ss_axis_if.sink                  pg_axis_tx_b

);

import ofs_fim_cfg_pkg::*;
import top_cfg_pkg::*;
//-----------------------------------------------------------------------------------------------
// Local configuration
//-----------------------------------------------------------------------------------------------
localparam MM_ADDR_WIDTH      = ofs_fim_cfg_pkg::MMIO_ADDR_WIDTH;
localparam MM_DATA_WIDTH      = ofs_fim_cfg_pkg::MMIO_DATA_WIDTH;

localparam PCIE_TDATA_WIDTH   = ofs_fim_cfg_pkg::PCIE_TDATA_WIDTH;
localparam PCIE_TUSER_WIDTH   = ofs_fim_cfg_pkg::PCIE_TUSER_WIDTH;

localparam NUM_MUX_PORTS      = top_cfg_pkg::NUM_TOP_PORTS;
localparam NUM_RTABLE_ENTRIES = top_cfg_pkg::NUM_TOP_RTABLE_ENTRIES;
localparam t_top_pf_vf_entry_info PFVF_ROUTING_TABLE = top_cfg_pkg::TOP_PF_VF_RTABLE;


//-----------------------------------------------------------------------------------------------
// Internal signals
//-----------------------------------------------------------------------------------------------
// AXI-ST TLP interfaces
pcie_ss_axis_if #(
   .DATA_W (PCIE_TDATA_WIDTH),
   .USER_W (PCIE_TUSER_WIDTH))
   // Host channel transformation interface
   mx2ho_tx_port    (.clk(clk), .rst_n(rst_n)),
   ho2mx_rxreq_port (.clk(clk), .rst_n(rst_n)),
   // Tag remapper
   ho2mx_rx_remap    (.clk(clk), .rst_n(rst_n)),
   mx2ho_tx_remap[2] (.clk(clk), .rst_n(rst_n)),
   ho2mx_rxreq_remap (.clk(clk), .rst_n(rst_n)),
   // PF/VF Mux "A" ports
   mx2fn_rx_a_port [NUM_MUX_PORTS-1:0](.clk(clk), .rst_n(rst_n)),
   fn2mx_tx_a_port [NUM_MUX_PORTS-1:0](.clk(clk), .rst_n(rst_n)),
   // PF/VF Mux "B" ports
   mx2fn_rx_b_port [NUM_MUX_PORTS-1:0](.clk(clk), .rst_n(rst_n)),
   fn2mx_tx_b_port [NUM_MUX_PORTS-1:0](.clk(clk), .rst_n(rst_n));

// TX request interface (only DMRd, DMIntr)
pcie_ss_axis_if #(
    .DATA_W (pcie_ss_hdr_pkg::HDR_WIDTH),
    .USER_W (PCIE_TUSER_WIDTH)
 ) mx2ho_txreq_port (.clk (clk), .rst_n(rst_n));

logic [1:0] pf_vf_fifo_err;
logic [1:0] pf_vf_fifo_perr;

logic       sel_mmio_rsp;
logic       read_flush_done;
logic       afu_softreset;

//-----------------------------------------------------------------------------------------------
// Preserve clocks
//-----------------------------------------------------------------------------------------------
// Make sure all clocks are consumed, in case AFUs don't use them,
// to avoid Quartus problems.
(* noprune *) logic clk_div2_q1, clk_div2_q2;

always_ff @(posedge clk_div2) begin
   clk_div2_q1 <= clk_div2_q2;
   clk_div2_q2 <= !clk_div2_q1;
end

//-----------------------------------------------------------------------------------------------
//                                  Modules instances
//-----------------------------------------------------------------------------------------------
// PF/VF Top-level routing Table 
//
//

//-----------------------------------------------------------------------------------------------
// AFU Peripheral Fabric (APF)
//-----------------------------------------------------------------------------------------------
// This is the AXI-Lite interconnect fabric associated with PF0. It contains AFU feature interfaces 
// local to this hierarchy (protocol checker, port gasket, etc.) that are part of the device feature
// list (DFL), A board peripheral fabric (BPF) interface that exposes board (top) level features in
// a separate memory map partition (FME, HSSI, Memory, etc.), and services the interconnect 
// requirements of the OFS FIM (BPF to PF0 MSIX mailbox, Management Component Transport Protocol 
// (MCTP) messages to board management, etc.)
//   
// The fabrics are generated using scripts with a text file, with the components and the address 
// map, as the input. Please refer to the README in $OFS_ROOTDIR/src/pd_qsys for more details. This
// script also generates the fabric_width_pkg used below so that the widths of address busses are 
// consistent with the input specified. 
// In order to remove/add components to the DFL list, modify the qsys fabric in 
// src/pd_qsys to add/delete the component and then edit the list below to add/remove the interface. 
// If adding a component connect up the port to the new instance.
//-----------------------------------------------------------------------------------------------

//  AXI4-lite interfaces
ofs_fim_axi_lite_if #(.AWADDR_WIDTH(16), .ARADDR_WIDTH(16))                       apf_achk_slv_if();


//-----------------------------------------------------------------------------------------------
// FLR routing
//-----------------------------------------------------------------------------------------------
// Route FLR requests to their respective PF/VF ports.
//-----------------------------------------------------------------------------------------------
t_axis_pcie_flr afu_flr_req [NUM_MUX_PORTS-1:0];
t_axis_pcie_flr afu_flr_rsp [NUM_MUX_PORTS-1:0];

flr_mux #(
   .NUM_PORT           (NUM_MUX_PORTS),
   .NUM_RTABLE_ENTRIES (NUM_RTABLE_ENTRIES),
   .PFVF_ROUTING_TABLE (PFVF_ROUTING_TABLE)
) flr_mux_inst (
   .clk       (clk_csr),
   .rst_n     (rst_n_csr),
   .h_flr_req (pcie_flr_req),
   .h_flr_rsp (pcie_flr_rsp),
   .a_flr_req (afu_flr_req),
   .a_flr_rsp (afu_flr_rsp)
);

//-----------------------------------------------------------------------------------------------
// PCIe ATS (address translation service) default invalidation handler
//-----------------------------------------------------------------------------------------------
// When ATS is enabled on a function, the host will send invalidation requests
// whenever a portion of the address space changes. ATS invalidation responses
// are required or the host may crash. After reset, the default module instantiated
// here responds to ATS invalidations on all functions. If an ATS request from
// the FPGA is seen on the AFU to host i_tx_if, the ats_inval module here stops
// responding for the function until the next function-level reset. As soon as
// a function requests a translation it becomes responsible for responding to
// ATS invalidations.
//
// When ATS is not enabled in the design the module just wires together the tx
// and rxreq interfaces.
//
// The module is instantiated very close to the PCIe device to ensure that ATS
// invalidations are generated even when the FIM is in an error state.
//-----------------------------------------------------------------------------------------------
pcie_ss_axis_if#(.DATA_W(PCIE_TDATA_WIDTH),
                 .USER_W(PCIE_TUSER_WIDTH)) intf2ats_tx(.clk, .rst_n);
pcie_ss_axis_if#(.DATA_W(PCIE_TDATA_WIDTH),
                 .USER_W(PCIE_TUSER_WIDTH)) ats2intf_rx(.clk, .rst_n);

ofs_fim_pcie_ats_inval_cpl ats_inval
  (
   .clk          (clk),
   .rst_n        (rst_n),
   // Clocks for pcie_flr_req
   .clk_csr      (clk_csr),
   .rst_n_csr    (rst_n_csr),

   // Function-level reset requests, used to reenable ATS invalidation responses
   // until an ATS request is seen from an AFU. No FLR response is generated
   // here.
   .pcie_flr_req (pcie_flr_req),

   // PCIe SS connections -- only those needed for PU-encoded ATS messages
   .o_tx_if      (pcie_ss_axis_tx),
   .i_rxreq_if   (pcie_ss_axis_rxreq),
   // FIM connections
   .i_tx_if      (intf2ats_tx),
   .o_rxreq_if   (ats2intf_rx)
   );

//-----------------------------------------------------------------------------------------------
// AFU Interface and Protocol Checker
//-----------------------------------------------------------------------------------------------
// Provides protection to the host PCIe channel from erroneous downstream behavior including:
//    - Malformed requests
//    - Data overrun/underrun
//    - Unsolicited completions   
//    - Completion timeouts
//-----------------------------------------------------------------------------------------------
afu_intf #(
   .ENABLE (1'b1),
   // The tag mapper is free to use all available tags in the
   // PCIe SS, independent of the limit imposed on AFUs by
   // ofs_pcie_ss_cfg_pkg::PCIE_EP_MAX_TAGS. The maximum tag
   // value has to take into account that 10 bit mode tags
   // shift to 256 and above.
   .PCIE_EP_MAX_TAGS (ofs_pcie_ss_cfg_pkg::PCIE_TILE_MAX_TAGS + 256)
) afu_intf_inst (
   .clk                (clk),
   .rst_n              (rst_n),
                       
   .clk_csr            (clk_csr), // Clock 100 MHz
   .rst_n_csr          (rst_n_csr),
   .pwr_good_csr_clk_n (pwr_good_csr_clk_n),
   
   .i_afu_softreset    ('0),

   .o_sel_mmio_rsp     ( sel_mmio_rsp    ),
   .o_read_flush_done  ( read_flush_done ),
   
   .h2a_axis_rx        ( ats2intf_rx ),

   .a2h_axis_tx        ( intf2ats_tx ),
   .a2h_axis_txreq     ( pcie_ss_axis_txreq ),
                       
   .csr_if             ( apf_achk_slv_if ),
                       
   .afu_axis_rx        ( ho2mx_rxreq_port ),
   .afu_axis_tx        ( mx2ho_tx_port ),
   .afu_axis_txreq     ( mx2ho_txreq_port )
);

assign apf_achk_slv_if.awvalid = 'd0;
assign apf_achk_slv_if.wvalid = 'd0;
assign apf_achk_slv_if.arvalid = 'd0;
assign apf_achk_slv_if.bready = 'd1;
assign apf_achk_slv_if.rready = 'd1;


//-----------------------------------------------------------------------------------------------
// AFU host fabric
//-----------------------------------------------------------------------------------------------
//    - Host channel interface transformations
//    - PF/VF Routing
//-----------------------------------------------------------------------------------------------

// Transformations required by the host PCIe interface: 
//    - Tag remapping: remap posted transaction tags to a unique tag from a shared tag pool.
//
//    - routing & arbitration: Route DMRd from "B" Port to TXREQ
//                             arbitrate other traffic channels to TX
afu_host_channel afu_host_channel_inst (
   .clk            (clk),
   .rst_n          (rst_n),
   .ho2mx_rx_port  (pcie_ss_axis_rx),
   .mx2ho_tx_port,
   .mx2ho_txreq_port,
   .ho2mx_rx_remap,
   .ho2mx_rxreq_port,
   .ho2mx_rxreq_remap,
   .mx2ho_tx_remap,
   .tag_mode
);

// Primary PF/VF MUX ("A" ports). Map individual TX A ports from
// AFUs down to a single, merged A channel. The RX port from host
// to FPGA is demultiplexed and individual connections are forwarded
// to AFUs.
pf_vf_mux_w_params  #(
   .MUX_NAME("A"),
   .NUM_PORT(NUM_MUX_PORTS),
   .NUM_RTABLE_ENTRIES(NUM_RTABLE_ENTRIES),
   .PFVF_ROUTING_TABLE(PFVF_ROUTING_TABLE)
) pf_vf_mux_a (
   .clk             (clk               ),
   .rst_n           (rst_n             ),
   .ho2mx_rx_port   (ho2mx_rxreq_remap ), // MMIO req & wr commits
   .mx2ho_tx_port   (mx2ho_tx_remap[0] ),
   .mx2fn_rx_port   (mx2fn_rx_a_port ),
   .fn2mx_tx_port   (fn2mx_tx_a_port   ),
   .out_fifo_err    (pf_vf_fifo_err[0] ),
   .out_fifo_perr   (pf_vf_fifo_perr[0])
);

// Secondary PF/VF MUX ("B" ports). Only TX is implemented, since a
// single RX stream is sufficient. The RX input to the MUX is tied off.
// AFU B TX ports are multiplexed into a single TX B channel that is
// passed to the A/B MUX above.
pf_vf_mux_w_params   #(
   .MUX_NAME ("B"),
   .NUM_PORT(NUM_MUX_PORTS),
   .NUM_RTABLE_ENTRIES(NUM_RTABLE_ENTRIES),
   .PFVF_ROUTING_TABLE(PFVF_ROUTING_TABLE)
) pf_vf_mux_b (
   .clk             (clk               ),
   .rst_n           (rst_n             ),
   .ho2mx_rx_port   (ho2mx_rx_remap    ),
   .mx2ho_tx_port   (mx2ho_tx_remap[1] ),
   .mx2fn_rx_port   (mx2fn_rx_b_port   ),
   .fn2mx_tx_port   (fn2mx_tx_b_port   ),
   .out_fifo_err    (pf_vf_fifo_err[1] ),
   .out_fifo_perr   (pf_vf_fifo_perr[1])
);

//-----------------------------------------------------------------------------------------------
// PCIe Streaming-to-AXI-Lite (ST2MM)
//-----------------------------------------------------------------------------------------------
// ST2MM translates the PCIe Subsystem TLP-over-AXI-ST channel to AXI-Lite transfers. This feature 
// is required to be routed to PF0, which is reflected in the default routing configuration:
// top_cfg_pkg::TOP_PF_VF_RTABLE
//
// This block maps all MMIO transfers to the `axi_m_if` port which manages device features connected
// to APF/BPF. Management Component Transport Protocol (MCTP) messages are mapped to the 
// `axi_m_pmci_vdm_if` port and routed through the peripheral fabric components to the PMCI feature
// VDM_OFFSET address region.
//-----------------------------------------------------------------------------------------------
/*
st2mm #(
   .PF_NUM          (0),
   .VF_NUM          (0),
   .VF_ACTIVE       (0),
   .MM_ADDR_WIDTH   (MM_ADDR_WIDTH),
   .MM_DATA_WIDTH   (MM_DATA_WIDTH),
   .PMCI_BASEADDR   (fabric_width_pkg::bpf_pmci_slv_baseaddress),
   .TX_VDM_OFFSET   (16'h2000), 
   .RX_VDM_OFFSET   (16'h2000), 
   .READ_ALLOWANCE  (1),
   .WRITE_ALLOWANCE (1),
   .FEAT_ID         (12'h14),
   .FEAT_VER        (4'h0),
   .END_OF_LIST     (1'b1),
   .NEXT_DFH_OFFSET (fabric_width_pkg::apf_st2mm_slv_next_dfh_offset)
) st2mm (
   .clk               (clk                         ),
   .rst_n             (rst_n                       ),
   .clk_csr           (clk_csr                     ),
   .rst_n_csr         (rst_n_csr                   ),
   .axis_rx_if        (mx2fn_rx_a_port[PF0_MGMT_PID]),
   .axis_tx_if        (fn2mx_tx_a_port[PF0_MGMT_PID]),
   .axi_m_pmci_vdm_if (apf_mctp_mst_if             ),
   .axi_m_if          (apf_st2mm_mst_if            ),
   .axi_s_if          (apf_st2mm_slv_if            )   
);
*/
  he_null #(
            .PF_ID     (0),
            .VF_ID     (0),
            .VF_ACTIVE (0)
         ) he_null_prr (
            .clk     (clk),
            .rst_n   (rst_n[i]),
            .i_rx_if (mx2fn_rx_a_port[PF0_MGMT_PID]),
            .o_tx_if (fn2mx_tx_a_port[PF0_MGMT_PID])
         );

// Tie-off TX/RX B port
assign fn2mx_tx_b_port[PF0_MGMT_PID].tvalid = 1'b0;
assign mx2fn_rx_b_port[PF0_MGMT_PID].tready = 1'b1;

// FLR has no meaning for PF0 management, but must propagate to VFs in pg_afu
logic pf0_flr_rst_n;
flr_rst_mgr #(
   .NUM_PF (1),
   .NUM_VF (0),
   .MAX_NUM_VF (0)
) pf0_flr (
   .clk_sys      (clk),
   .rst_n_sys    (rst_n),
   .clk_csr      (clk_csr),
   .rst_n_csr    (rst_n_csr),
   .pcie_flr_req (afu_flr_req[PF0_MGMT_PID]),
   .pcie_flr_rsp (afu_flr_rsp[PF0_MGMT_PID]),
   .pf_flr_rst_n (pf0_flr_rst_n)
);

assign pg_flr_rst_n = (top_cfg_pkg::PG_VFS > 0) ? pf0_flr_rst_n : 1'b1;

//-----------------------------------------------------------------------------------------------
// Static Region (SR) AFU (fim_afu_instances)
//-----------------------------------------------------------------------------------------------
// This block implements the static region AFU. In the reference implementation separate 
// physical interfaces are created for each function mapped to this region. They are ST2MM (PF0) 
// and HE-LB (PF1). For the SoC attach design the host attached side only implements static region 
// logic.
//-----------------------------------------------------------------------------------------------
generate if(top_cfg_pkg::NUM_SR_PORTS > 0) begin : sr_afu
   fim_afu_instances #(
      .NUM_PF             (top_cfg_pkg::FIM_NUM_PF),
      .NUM_VF             (top_cfg_pkg::FIM_NUM_VF),
      .MAX_NUM_VF         (top_cfg_pkg::FIM_MAX_NUM_VF),
      .NUM_MUX_PORTS      (top_cfg_pkg::NUM_SR_RTABLE_ENTRIES),
      .PFVF_ROUTING_TABLE (top_cfg_pkg::SR_PF_VF_RTABLE)
   ) fim_afu_instances (
      .clk               (clk),
      .rst_n             (rst_n),

      .clk_csr           (clk_csr),
      .rst_n_csr         (rst_n_csr),

      .flr_req           (afu_flr_req[SR_SHARED_PFVF_PID]),
      .flr_rsp           (afu_flr_rsp[SR_SHARED_PFVF_PID]),

      .afu_axi_rx_a_if   (mx2fn_rx_a_port[SR_SHARED_PFVF_PID]),
      .afu_axi_tx_a_if   (fn2mx_tx_a_port[SR_SHARED_PFVF_PID]),
      .afu_axi_rx_b_if   (mx2fn_rx_b_port[SR_SHARED_PFVF_PID]),
      .afu_axi_tx_b_if   (fn2mx_tx_b_port[SR_SHARED_PFVF_PID])
   );
end : sr_afu
endgenerate
   

assign pg_flr_req = afu_flr_req[PG_SHARED_VF_PID];
assign afu_flr_rsp[PG_SHARED_VF_PID] = pg_flr_rsp;

//rx_a
assign mx2fn_rx_a_port[PG_SHARED_VF_PID].tready = pg_axis_rx_a.tready;
assign pg_axis_rx_a.tvalid = mx2fn_rx_a_port[PG_SHARED_VF_PID].tvalid;
assign pg_axis_rx_a.tlast = mx2fn_rx_a_port[PG_SHARED_VF_PID].tlast;
assign pg_axis_rx_a.tuser_vendor = mx2fn_rx_a_port[PG_SHARED_VF_PID].tuser_vendor;
assign pg_axis_rx_a.tdata = mx2fn_rx_a_port[PG_SHARED_VF_PID].tdata;
assign pg_axis_rx_a.tkeep = mx2fn_rx_a_port[PG_SHARED_VF_PID].tkeep;

//rx_b
assign mx2fn_rx_b_port[PG_SHARED_VF_PID].tready = pg_axis_rx_b.tready;
assign pg_axis_rx_b.tvalid = mx2fn_rx_b_port[PG_SHARED_VF_PID].tvalid;
assign pg_axis_rx_b.tlast = mx2fn_rx_b_port[PG_SHARED_VF_PID].tlast;
assign pg_axis_rx_b.tuser_vendor = mx2fn_rx_b_port[PG_SHARED_VF_PID].tuser_vendor;
assign pg_axis_rx_b.tdata = mx2fn_rx_b_port[PG_SHARED_VF_PID].tdata;
assign pg_axis_rx_b.tkeep = mx2fn_rx_b_port[PG_SHARED_VF_PID].tkeep;

//tx_a
assign pg_axis_tx_a.tready = fn2mx_tx_a_port[PG_SHARED_VF_PID].tready;
assign fn2mx_tx_a_port[PG_SHARED_VF_PID].tvalid = pg_axis_tx_a.tvalid;
assign fn2mx_tx_a_port[PG_SHARED_VF_PID].tlast = pg_axis_tx_a.tlast;
assign fn2mx_tx_a_port[PG_SHARED_VF_PID].tuser_vendor = pg_axis_tx_a.tuser_vendor;
assign fn2mx_tx_a_port[PG_SHARED_VF_PID].tdata = pg_axis_tx_a.tdata;
assign fn2mx_tx_a_port[PG_SHARED_VF_PID].tkeep = pg_axis_tx_a.tkeep;

//tx_b
assign pg_axis_tx_b.tready = fn2mx_tx_b_port[PG_SHARED_VF_PID].tready;
assign fn2mx_tx_b_port[PG_SHARED_VF_PID].tvalid = pg_axis_tx_b.tvalid;
assign fn2mx_tx_b_port[PG_SHARED_VF_PID].tlast = pg_axis_tx_b.tlast;
assign fn2mx_tx_b_port[PG_SHARED_VF_PID].tuser_vendor = pg_axis_tx_b.tuser_vendor;
assign fn2mx_tx_b_port[PG_SHARED_VF_PID].tdata = pg_axis_tx_b.tdata;
assign fn2mx_tx_b_port[PG_SHARED_VF_PID].tkeep = pg_axis_tx_b.tkeep;

endmodule
