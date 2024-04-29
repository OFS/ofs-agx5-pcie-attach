// Copyright (C) 2024 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// RX dual stream fork test -- separating CplD from other traffic
//
// RX credit tracking is tested in one case: in-band headers and
// NUM_OF_SEG == 1. That is the only case where the credit tracker
// is used in OFS.
//

module test_rx_dual_stream
  #(
    parameter DATA_WIDTH = 512,
    parameter NUM_OF_SEG = DATA_WIDTH / 256,
    parameter SB_HEADERS = 1,
    parameter string FILE_PREFIX = "test_stream_rx_dual"
    )
   (
    input  bit clk,
    input  bit rst_n,
    input  bit csr_clk,
    input  bit csr_rst_n,

    output logic done
    );

    localparam HDR_WIDTH = 256;
    localparam string SB_STRING = SB_HEADERS ? "sb" : "ib";

    int log_in_fd;
    int log_out_cpld_fd;
    int log_out_req_fd;

    rand_tlp_pkg::rand_tlp tlp;
    rand_tlp_pkg::rand_tlp_stream#(.DATA_WIDTH(DATA_WIDTH),
                                   .NUM_OF_SEG(NUM_OF_SEG),
                                   .SB_HEADERS(SB_HEADERS),
                                   .MAX_SOP_PER_CYCLE(NUM_OF_SEG)) tlp_stream_in;

    rand_tlp_pkg::rand_tlp tlp_out_cpld;
    rand_tlp_pkg::bus_to_tlp#(.DATA_WIDTH(DATA_WIDTH),
                              .NUM_OF_SEG(NUM_OF_SEG),
                              .SB_HEADERS(SB_HEADERS)) tlp_stream_out_cpld;

    rand_tlp_pkg::rand_tlp tlp_out_req;
    rand_tlp_pkg::bus_to_tlp#(.DATA_WIDTH(DATA_WIDTH),
                              .NUM_OF_SEG(NUM_OF_SEG),
                              .SB_HEADERS(SB_HEADERS)) tlp_stream_out_req;

    int cnt;
    logic stop_stream;

    // Reference queue, used to compare the input stream to the output
    rand_tlp_pkg::rand_tlp tlp_ref_queue_cpld[$];
    rand_tlp_pkg::rand_tlp tlp_ref_cpld;
    rand_tlp_pkg::rand_tlp tlp_ref_queue_req[$];
    rand_tlp_pkg::rand_tlp tlp_ref_req;

    initial begin
        log_in_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_in.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        log_out_cpld_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_cpld_out.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        log_out_req_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_req_out.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        tlp_stream_in = new();
        tlp_stream_out_cpld = new();
        tlp_stream_out_req = new();
    end


    // ====================================================================
    //
    //  Source stream of random TLP packets.
    //
    // ====================================================================

    logic in_tready;
    logic in_tvalid;
    logic [DATA_WIDTH-1:0] in_tdata;
    logic [DATA_WIDTH/8-1:0] in_tkeep;
    logic in_tlast;
    logic [NUM_OF_SEG-1:0] in_tuser_vendor;
    logic [NUM_OF_SEG-1:0] in_tuser_last_segment;
    logic [NUM_OF_SEG-1:0] in_tuser_hvalid;
    logic [NUM_OF_SEG-1:0][HDR_WIDTH-1:0] in_tuser_hdr;

    always_ff @(posedge clk) begin
        if (rst_n && (in_tready || !in_tvalid)) begin
            tlp_stream_in.next_cycle(stop_stream);
            in_tvalid <= tlp_stream_in.tvalid;
            in_tdata <= tlp_stream_in.tdata;
            in_tkeep <= tlp_stream_in.tkeep;
            in_tlast <= tlp_stream_in.tlast;
            in_tuser_vendor <= tlp_stream_in.tuser_vendor;
            in_tuser_last_segment <= tlp_stream_in.tuser_last_segment;
            in_tuser_hvalid <= tlp_stream_in.tuser_hvalid;
            in_tuser_hdr <= tlp_stream_in.tuser_hdr;
        end

        if (!rst_n) begin
            in_tvalid <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (in_tvalid && in_tready) begin
                if (|(in_tuser_hvalid)) begin
                    $fwrite(log_in_fd, "%0t: hvalid b%b hdr %h\n", $time,
                            in_tuser_hvalid,
                            in_tuser_hdr);
                end
                $fwrite(log_in_fd, "%0t: last %b last_seg b%b data %h keep %h\n", $time,
                        in_tlast,
                        in_tuser_last_segment,
                        in_tdata,
                        in_tkeep);
            end

            while (tlp_stream_in.tlp_queue.size() > 0) begin
                tlp = tlp_stream_in.tlp_queue.pop_front();
                if (tlp.tlp_type == tlp.TLP_CPLD)
                    tlp_ref_queue_cpld.push_back(tlp);
                else
                    tlp_ref_queue_req.push_back(tlp);
                $fwrite(log_in_fd, "\n%0t: %0s\n", $time, tlp.sfmt());

                cnt <= cnt + 1;
                if (cnt == 10000-1)
                    stop_stream <= 1'b1;
            end
        end

        if (!rst_n) begin
            cnt <= 0;
            stop_stream <= 1'b0;
        end
    end


    // ====================================================================
    //
    //  DUT
    //
    // ====================================================================

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg [NUM_OF_SEG-1:0] axi_in_seg_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(axi_in_seg_tuser))) axi_in(clk, rst_n);

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg [NUM_OF_SEG-1:0] out_cpld_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(out_cpld_tuser))) split_cpld(clk, rst_n);
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(out_cpld_tuser))) out_cpld(clk, rst_n);

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg [NUM_OF_SEG-1:0] out_req_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(out_req_tuser))) split_req(clk, rst_n);
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(out_req_tuser))) out_req(clk, rst_n);

    for (genvar i = 0; i < NUM_OF_SEG; i += 1) begin
        // ofs_fim_pcie_ss_rx_dual_stream expects the tuser values in a struct
        assign axi_in_seg_tuser[i].vendor = in_tuser_vendor[i];
        assign axi_in_seg_tuser[i].last_segment = in_tuser_last_segment[i];
        assign axi_in_seg_tuser[i].hvalid = in_tuser_hvalid[i];
        // The hdr field is ignored when in-band headers are in use
        assign axi_in_seg_tuser[i].hdr = in_tuser_hdr[i];
    end

    assign axi_in.tvalid = in_tvalid;
    assign axi_in.tlast = in_tlast;
    assign axi_in.tuser_vendor = axi_in_seg_tuser;
    assign axi_in.tdata = in_tdata;
    assign axi_in.tkeep = in_tkeep;

    ofs_fim_pcie_ss_rx_dual_stream
      #(
        .NUM_OF_SEG(NUM_OF_SEG),
        .SB_HEADERS(SB_HEADERS)
        )
      rx_dual_stream
       (
        .stream_in(axi_in),
        .stream_out_cpld(split_cpld),
        .stream_out_req(split_req)
        );

    assign in_tready = axi_in.tready;


    //
    // RX credit tracking. Monitor traffic and return credits to the PCIe SS.
    // The AXI-S input and output streams are simply wired together.
    //
    generate
        //
        // Because of the RX pipeline in OFS, the credit tracking code
        // assumes in-band headers and one segment. Only test that case.
        //
        if (SB_HEADERS == 0 && NUM_OF_SEG == 1) begin : crdt
            logic rxcrdt_tvalid;
            logic [18:0] rxcrdt_tdata;

            ofs_fim_pcie_ss_rxcrdt
              #(
                .TDATA_WIDTH(DATA_WIDTH),
                .NUM_OF_SEG(NUM_OF_SEG),
                .SB_HEADERS(SB_HEADERS),
                .BUFFER_SB_HEADERS(1),
                .HDR_WIDTH(HDR_WIDTH)
                )
              rx_crdt
               (
                .stream_in_cpld(split_cpld),
                .stream_in_req(split_req),
                .stream_out_cpld(out_cpld),
                .stream_out_req(out_req),

                .rxcrdt_clk(csr_clk),
                .rxcrdt_rst_n(csr_rst_n),
                .rxcrdt_tvalid,
                .rxcrdt_tdata
                );

            always_ff @(posedge csr_clk) begin
                if (csr_rst_n && rxcrdt_tvalid) begin
                    $fwrite(log_in_fd, "%0t: CRDT %h\n", $time, rxcrdt_tdata);
                end
            end
        end else begin : no_crdt
            ofs_fim_axis_pipeline #(.PL_DEPTH(0))
                conn_cpld (.clk, .rst_n, .axis_s(split_cpld), .axis_m(out_cpld));
            ofs_fim_axis_pipeline #(.PL_DEPTH(0))
                conn_req (.clk, .rst_n, .axis_s(split_req), .axis_m(out_req));
        end
    endgenerate


    logic [NUM_OF_SEG-1:0] out_cpld_tuser_vendor;
    logic [NUM_OF_SEG-1:0] out_cpld_tuser_last_segment;
    logic [NUM_OF_SEG-1:0] out_cpld_tuser_hvalid;
    logic [NUM_OF_SEG-1:0][HDR_WIDTH-1:0] out_cpld_tuser_hdr;

    logic [NUM_OF_SEG-1:0] out_req_tuser_vendor;
    logic [NUM_OF_SEG-1:0] out_req_tuser_last_segment;
    logic [NUM_OF_SEG-1:0] out_req_tuser_hvalid;
    logic [NUM_OF_SEG-1:0][HDR_WIDTH-1:0] out_req_tuser_hdr;

    assign out_cpld_tuser = out_cpld.tuser_vendor;
    assign out_req_tuser = out_req.tuser_vendor;
    for (genvar i = 0; i < NUM_OF_SEG; i += 1) begin
        assign out_cpld_tuser_vendor[i] = out_cpld_tuser[i].vendor;
        assign out_cpld_tuser_last_segment[i] = out_cpld_tuser[i].last_segment;
        assign out_cpld_tuser_hvalid[i] = out_cpld_tuser[i].hvalid;
        assign out_cpld_tuser_hdr[i] = out_cpld_tuser[i].hdr;

        assign out_req_tuser_vendor[i] = out_req_tuser[i].vendor;
        assign out_req_tuser_last_segment[i] = out_req_tuser[i].last_segment;
        assign out_req_tuser_hvalid[i] = out_req_tuser[i].hvalid;
        assign out_req_tuser_hdr[i] = out_req_tuser[i].hdr;
    end

    // Random back-pressure
    always_ff @(posedge clk) begin
        out_cpld.tready <= ($urandom() & 4'hf) != 4'hf;
        out_req.tready <= ($urandom() & 4'hf) != 4'hf;
    end


    // ====================================================================
    //
    //  Compare output of the DUT to the source stream
    //
    // ====================================================================

    always_ff @(posedge clk) begin
        if (rst_n && out_cpld.tvalid && out_cpld.tready) begin
            if (|(out_cpld_tuser_hvalid)) begin
                $fwrite(log_out_cpld_fd, "%0t: hvalid b%b hdr %h\n", $time,
                        out_cpld_tuser_hvalid,
                        out_cpld_tuser_hdr);
            end
            $fwrite(log_out_cpld_fd, "%0t: last %b last_seg b%b data %h keep %h\n", $time,
                    out_cpld.tlast,
                    out_cpld_tuser_last_segment,
                    out_cpld.tdata,
                    out_cpld.tkeep);

            tlp_stream_out_cpld.push(out_cpld.tdata, out_cpld.tkeep, out_cpld.tlast,
                                     out_cpld_tuser_vendor, out_cpld_tuser_last_segment,
                                     out_cpld_tuser_hvalid, out_cpld_tuser_hdr);
        end

        if (rst_n && out_req.tvalid && out_req.tready) begin
            if (|(out_req_tuser_hvalid)) begin
                $fwrite(log_out_req_fd, "%0t: hvalid b%b hdr %h\n", $time,
                        out_req_tuser_hvalid,
                        out_req_tuser_hdr);
            end
            $fwrite(log_out_req_fd, "%0t: last %b last_seg b%b data %h keep %h\n", $time,
                    out_req.tlast,
                    out_req_tuser_last_segment,
                    out_req.tdata,
                    out_req.tkeep);

            tlp_stream_out_req.push(out_req.tdata, out_req.tkeep, out_req.tlast,
                                    out_req_tuser_vendor, out_req_tuser_last_segment,
                                    out_req_tuser_hvalid, out_req_tuser_hdr);
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            while (tlp_stream_out_cpld.tlp_queue.size() > 0) begin
                tlp_out_cpld = tlp_stream_out_cpld.tlp_queue.pop_front();
                $fwrite(log_out_cpld_fd, "%0t: %0s\n", $time, tlp_out_cpld.sfmt());

                assert(tlp_ref_queue_cpld.size() > 0) else
                    $fatal(1, "ERROR: Output CplD TLP with no corresponding input!");
                tlp_ref_cpld = tlp_ref_queue_cpld.pop_front();
                tlp_out_cpld.compare(tlp_ref_cpld);
            end
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            while (tlp_stream_out_req.tlp_queue.size() > 0) begin
                tlp_out_req = tlp_stream_out_req.tlp_queue.pop_front();
                $fwrite(log_out_req_fd, "%0t: %0s\n", $time, tlp_out_req.sfmt());

                assert(tlp_ref_queue_req.size() > 0) else
                    $fatal(1, "Output Req TLP with no corresponding input!");
                tlp_ref_req = tlp_ref_queue_req.pop_front();
                tlp_out_req.compare(tlp_ref_req);
            end
        end
    end

    // Delay finish by 512 cycles so the credit counting logic can emit the final
    // counts.
    logic [8:0] done_cnt;
    always_ff @(posedge clk) begin
        if (!stop_stream || (tlp_ref_queue_cpld.size() != 0) || (tlp_ref_queue_req.size() != 0))
            done_cnt <= 1;
        else if (done_cnt != 0)
            done_cnt <= done_cnt + 1;
    end

    always_ff @(posedge clk) begin
        if (!done && (done_cnt == 0) && stop_stream && (tlp_ref_queue_cpld.size() == 0) && (tlp_ref_queue_req.size() == 0)) begin
            $fwrite(log_out_cpld_fd, "\nPass rx_dual_stream data width %0d, num seg %0d, %0s headers, %0d packets\n",
                    DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $fwrite(log_out_req_fd, "\nPass rx_dual_stream data width %0d, num seg %0d, %0s headers, %0d packets\n",
                    DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $display("  Pass rx_dual_stream data width %0d, num seg %0d, %0s headers, %0d packets",
                     DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $fflush(log_in_fd);
            $fflush(log_out_cpld_fd);
            $fflush(log_out_req_fd);
            done <= 1'b1;
        end

        if (!rst_n) begin
            done <= 1'b0;
        end
    end

endmodule
