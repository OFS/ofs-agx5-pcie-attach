// Copyright (C) 2024 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Packet realignment test. Cycles with multiple headers or headers not in
// the first segment are remapped to single header packets starting at 0.
//

module test_rx_seg_align
  #(
    parameter DATA_WIDTH = 512,
    parameter NUM_OF_SEG = DATA_WIDTH / 256,
    parameter SB_HEADERS = 1,
    parameter string FILE_PREFIX = "test_stream_rx_seg_align"
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
    int log_out_fd;

    rand_tlp_pkg::rand_tlp tlp;
    rand_tlp_pkg::rand_tlp_stream#(.DATA_WIDTH(DATA_WIDTH),
                                   .NUM_OF_SEG(NUM_OF_SEG),
                                   .SB_HEADERS(SB_HEADERS),
                                   .MAX_SOP_PER_CYCLE(NUM_OF_SEG)) tlp_stream_in;

    rand_tlp_pkg::rand_tlp tlp_out;
    rand_tlp_pkg::bus_to_tlp#(.DATA_WIDTH(DATA_WIDTH),
                              // The output of the test has 1 segment
                              .NUM_OF_SEG(1),
                              .SB_HEADERS(SB_HEADERS)) tlp_stream_out;

    int cnt;
    logic stop_stream;

    // Reference queue, used to compare the input stream to the output
    rand_tlp_pkg::rand_tlp tlp_ref_queue[$];
    rand_tlp_pkg::rand_tlp tlp_ref;

    initial begin
        log_in_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_in.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        log_out_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_out.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        tlp_stream_in = new();
        tlp_stream_out = new();
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
                tlp_ref_queue.push_back(tlp);
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

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg out_aligned_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(out_aligned_tuser))) out_aligned(clk, rst_n);

    for (genvar i = 0; i < NUM_OF_SEG; i += 1) begin
        // ofs_fim_pcie_ss_rx_seg_align expects the tuser values in a struct
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

    ofs_fim_pcie_ss_rx_seg_align
      #(
        .NUM_OF_SEG(NUM_OF_SEG)
        )
      rx_seg_align
       (
        .stream_in(axi_in),
        .stream_out(out_aligned)
        );

    assign in_tready = axi_in.tready;
    assign out_aligned_tuser = out_aligned.tuser_vendor;

    // Random back-pressure
    always_ff @(posedge clk) begin
        out_aligned.tready <= ($urandom() & 4'hf) != 4'hf;
    end


    // ====================================================================
    //
    //  Compare output of the DUT to the source stream
    //
    // ====================================================================

    logic out_sop;

    always_ff @(posedge clk) begin
        if (rst_n && out_aligned.tvalid && out_aligned.tready) begin
            $fwrite(log_out_fd, "%0t: last %b data %h keep %h tuser %h\n", $time,
                    out_aligned.tlast, out_aligned.tdata, out_aligned.tkeep,
                    out_aligned.tuser_vendor);

            tlp_stream_out.push(out_aligned.tdata, out_aligned.tkeep, out_aligned.tlast,
                                out_aligned_tuser.vendor, out_aligned.tlast,
                                out_aligned_tuser.hvalid, out_aligned_tuser.hdr);

            out_sop <= out_aligned.tlast;
        end

        if (!rst_n) begin
            out_sop <= 1'b1;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            while (tlp_stream_out.tlp_queue.size() > 0) begin
                tlp_out = tlp_stream_out.tlp_queue.pop_front();
                $fwrite(log_out_fd, "%0t: %0s\n", $time, tlp_out.sfmt());

                assert(tlp_ref_queue.size() > 0) else
                    $fatal(1, "ERROR: Output TLP with no corresponding input!");
                tlp_ref = tlp_ref_queue.pop_front();
                tlp_out.compare(tlp_ref);
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!done && stop_stream && (tlp_ref_queue.size() == 0)) begin
            $fwrite(log_out_fd, "\nPass seg_align data width %0d, num seg %0d, %0s headers, %0d packets\n",
                    DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $display("  Pass seg_align data width %0d, num seg %0d, %0s headers, %0d packets",
                     DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $fflush(log_in_fd);
            $fflush(log_out_fd);
            done <= 1'b1;
        end

        if (!rst_n) begin
            done <= 1'b0;
        end
    end

endmodule
