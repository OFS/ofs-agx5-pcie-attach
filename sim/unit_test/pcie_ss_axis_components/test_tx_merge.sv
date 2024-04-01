// Copyright (C) 2024 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// TX merge -- combine TX and TXREQ into a single stream.
//
// The input streams may have SOP only at bit 0.
//

module test_tx_merge
  #(
    parameter DATA_WIDTH = 512,
    parameter NUM_OF_SEG = DATA_WIDTH / 256,
    parameter SB_HEADERS = 1,
    parameter string FILE_PREFIX = "test_stream_tx_merge"
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

    int log_in_tx_fd;
    int log_in_txreq_fd;
    int log_out_fd;

    rand_tlp_pkg::rand_tlp tlp_in_tx;
    rand_tlp_pkg::rand_tlp_stream#(.DATA_WIDTH(DATA_WIDTH),
                                   .NUM_OF_SEG(1),
                                   .SB_HEADERS(SB_HEADERS)) tlp_stream_in_tx;

    rand_tlp_pkg::rand_tlp tlp_in_txreq;
    rand_tlp_pkg::rand_tlp_stream#(.DATA_WIDTH(DATA_WIDTH),
                                   .NUM_OF_SEG(1),
                                   .SB_HEADERS(SB_HEADERS)) tlp_stream_in_txreq;

    rand_tlp_pkg::rand_tlp tlp_out;
    rand_tlp_pkg::bus_to_tlp#(.DATA_WIDTH(DATA_WIDTH),
                              .NUM_OF_SEG(NUM_OF_SEG),
                              .SB_HEADERS(SB_HEADERS)) tlp_stream_out;

    int cnt;
    logic stop_stream;

    // Reference queue, used to compare the input stream to the output
    rand_tlp_pkg::rand_tlp tlp_ref_queue_tx[$];
    rand_tlp_pkg::rand_tlp tlp_ref_queue_txreq[$];
    rand_tlp_pkg::rand_tlp tlp_ref;

    initial begin
        log_in_tx_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_tx_in.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        log_in_txreq_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_txreq_in.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        log_out_fd = $fopen($sformatf("%0s_%0d_%0d_%0s_out.tsv", FILE_PREFIX, DATA_WIDTH, NUM_OF_SEG, SB_STRING), "w");
        tlp_stream_in_tx = new(1, 0);
        tlp_stream_in_txreq = new(1, 1, 1, rand_tlp_pkg::rand_tlp::TLP_NO_DATA);
        tlp_stream_out = new();
    end


    // ====================================================================
    //
    //  Source streams of random TLP packets.
    //
    // ====================================================================

    logic in_tx_tready;
    logic in_tx_tvalid;
    logic [DATA_WIDTH-1:0] in_tx_tdata;
    logic [DATA_WIDTH/8-1:0] in_tx_tkeep;
    logic in_tx_tlast;
    logic [NUM_OF_SEG-1:0] in_tx_tuser_vendor;
    logic [NUM_OF_SEG-1:0] in_tx_tuser_last_segment;
    logic [NUM_OF_SEG-1:0] in_tx_tuser_hvalid;
    logic [NUM_OF_SEG-1:0][HDR_WIDTH-1:0] in_tx_tuser_hdr;

    always_ff @(posedge clk) begin
        if (rst_n && (in_tx_tready || !in_tx_tvalid)) begin
            tlp_stream_in_tx.next_cycle(stop_stream);
            in_tx_tvalid <= tlp_stream_in_tx.tvalid;
            in_tx_tdata <= tlp_stream_in_tx.tdata;
            in_tx_tkeep <= tlp_stream_in_tx.tkeep;
            in_tx_tlast <= tlp_stream_in_tx.tlast;
            in_tx_tuser_vendor <= { '0, tlp_stream_in_tx.tuser_vendor };
            in_tx_tuser_hvalid <= { '0, tlp_stream_in_tx.tuser_hvalid };
            in_tx_tuser_hdr <= { '0, tlp_stream_in_tx.tuser_hdr };

            // Figure out which segment is last (assuming one is)
            in_tx_tuser_last_segment <= '0;
            for (int i = NUM_OF_SEG-1; i >= 0; i = i - 1) begin
                if (tlp_stream_in_tx.tkeep[(i * DATA_WIDTH/NUM_OF_SEG) / 8] || ((i == 0) && tlp_stream_in_tx.tuser_hvalid)) begin
                    in_tx_tuser_last_segment[i] <= tlp_stream_in_tx.tlast;
                    break;
                end
            end
        end

        if (!rst_n) begin
            in_tx_tvalid <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (in_tx_tvalid && in_tx_tready) begin
                if (|(in_tx_tuser_hvalid)) begin
                    $fwrite(log_in_tx_fd, "%0t: hvalid b%b hdr %h\n", $time,
                            in_tx_tuser_hvalid,
                            in_tx_tuser_hdr);
                end
                $fwrite(log_in_tx_fd, "%0t: last %b last_seg b%b data %h keep %h\n", $time,
                        in_tx_tlast,
                        in_tx_tuser_last_segment,
                        in_tx_tdata,
                        in_tx_tkeep);
            end

            while (tlp_stream_in_tx.tlp_queue.size() > 0) begin
                tlp_in_tx = tlp_stream_in_tx.tlp_queue.pop_front();
                tlp_ref_queue_tx.push_back(tlp_in_tx);
                $fwrite(log_in_tx_fd, "\n%0t: %0s\n", $time, tlp_in_tx.sfmt());

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


    logic in_txreq_tready;
    logic in_txreq_tvalid;
    logic [DATA_WIDTH-1:0] in_txreq_tdata;
    logic [DATA_WIDTH/8-1:0] in_txreq_tkeep;
    logic in_txreq_tlast;
    logic [NUM_OF_SEG-1:0] in_txreq_tuser_vendor;
    logic [NUM_OF_SEG-1:0] in_txreq_tuser_last_segment;
    logic [NUM_OF_SEG-1:0] in_txreq_tuser_hvalid;
    logic [NUM_OF_SEG-1:0][HDR_WIDTH-1:0] in_txreq_tuser_hdr;

    always_ff @(posedge clk) begin
        if (rst_n && (in_txreq_tready || !in_txreq_tvalid)) begin
            tlp_stream_in_txreq.next_cycle(stop_stream);
            in_txreq_tvalid <= tlp_stream_in_txreq.tvalid;
            in_txreq_tdata <= tlp_stream_in_txreq.tdata;
            in_txreq_tkeep <= tlp_stream_in_txreq.tkeep;
            in_txreq_tlast <= tlp_stream_in_txreq.tlast;
            in_txreq_tuser_vendor <= { '0, tlp_stream_in_txreq.tuser_vendor };
            in_txreq_tuser_last_segment <= { '0, tlp_stream_in_txreq.tlast };
            in_txreq_tuser_hvalid <= { '0, tlp_stream_in_txreq.tuser_hvalid };
            in_txreq_tuser_hdr <= { '0, tlp_stream_in_txreq.tuser_hdr };
        end

        if (!rst_n) begin
            in_txreq_tvalid <= 1'b0;
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            if (in_txreq_tvalid && in_txreq_tready) begin
                if (|(in_txreq_tuser_hvalid)) begin
                    $fwrite(log_in_txreq_fd, "%0t: hvalid b%b hdr %h\n", $time,
                            in_txreq_tuser_hvalid,
                            in_txreq_tuser_hdr);
                end
                $fwrite(log_in_txreq_fd, "%0t: last %b last_seg b%b data %h keep %h\n", $time,
                        in_txreq_tlast,
                        in_txreq_tuser_last_segment,
                        in_txreq_tdata,
                        in_txreq_tkeep);
            end

            while (tlp_stream_in_txreq.tlp_queue.size() > 0) begin
                tlp_in_txreq = tlp_stream_in_txreq.tlp_queue.pop_front();
                tlp_ref_queue_txreq.push_back(tlp_in_txreq);
                $fwrite(log_in_txreq_fd, "\n%0t: %0s\n", $time, tlp_in_txreq.sfmt());
            end
        end
    end


    // ====================================================================
    //
    //  DUT
    //
    // ====================================================================

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg [NUM_OF_SEG-1:0] axi_in_tx_seg_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(axi_in_tx_seg_tuser))) axi_in_tx(clk, rst_n);

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg [NUM_OF_SEG-1:0] axi_in_txreq_seg_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(axi_in_txreq_seg_tuser))) axi_in_txreq(clk, rst_n);

    ofs_fim_pcie_ss_shims_pkg::t_tuser_seg [NUM_OF_SEG-1:0] axi_out_tuser;
    pcie_ss_axis_if#(.DATA_W(DATA_WIDTH), .USER_W($bits(axi_out_tuser))) axi_out(clk, rst_n);

    for (genvar i = 0; i < NUM_OF_SEG; i += 1) begin
        // ofs_fim_pcie_ss_tx_merge expects the tuser values in a struct
        assign axi_in_tx_seg_tuser[i].vendor = in_tx_tuser_vendor[i];
        assign axi_in_tx_seg_tuser[i].last_segment = in_tx_tuser_last_segment[i];
        assign axi_in_tx_seg_tuser[i].hvalid = in_tx_tuser_hvalid[i];
        // The hdr field is ignored when in-band headers are in use
        assign axi_in_tx_seg_tuser[i].hdr = in_tx_tuser_hdr[i];
    end

    assign axi_in_tx.tvalid = in_tx_tvalid;
    assign axi_in_tx.tlast = in_tx_tlast;
    assign axi_in_tx.tuser_vendor = axi_in_tx_seg_tuser;
    assign axi_in_tx.tdata = in_tx_tdata;
    assign axi_in_tx.tkeep = in_tx_tkeep;

    for (genvar i = 0; i < NUM_OF_SEG; i += 1) begin
        // ofs_fim_pcie_ss_tx_merge expects the tuser values in a struct
        assign axi_in_txreq_seg_tuser[i].vendor = in_txreq_tuser_vendor[i];
        assign axi_in_txreq_seg_tuser[i].last_segment = in_txreq_tuser_last_segment[i];
        assign axi_in_txreq_seg_tuser[i].hvalid = in_txreq_tuser_hvalid[i];
        // The hdr field is ignored when in-band headers are in use
        assign axi_in_txreq_seg_tuser[i].hdr = in_txreq_tuser_hdr[i];
    end

    assign axi_in_txreq.tvalid = in_txreq_tvalid;
    assign axi_in_txreq.tlast = in_txreq_tlast;
    assign axi_in_txreq.tuser_vendor = axi_in_txreq_seg_tuser;
    assign axi_in_txreq.tdata = in_txreq_tdata;
    assign axi_in_txreq.tkeep = in_txreq_tkeep;

    ofs_fim_pcie_ss_tx_merge
      #(
        .NUM_OF_SEG(NUM_OF_SEG)
        )
      tx_merge
       (
        .axi_st_txreq_in(axi_in_txreq),
        .axi_st_tx_in(axi_in_tx),
        .axi_st_tx_out(axi_out)
        );

    assign in_tx_tready = axi_in_tx.tready;
    assign in_txreq_tready = axi_in_txreq.tready;


    logic [NUM_OF_SEG-1:0] axi_out_tuser_vendor;
    logic [NUM_OF_SEG-1:0] axi_out_tuser_last_segment;
    logic [NUM_OF_SEG-1:0] axi_out_tuser_hvalid;
    logic [NUM_OF_SEG-1:0][HDR_WIDTH-1:0] axi_out_tuser_hdr;

    assign axi_out_tuser = axi_out.tuser_vendor;
    for (genvar i = 0; i < NUM_OF_SEG; i += 1) begin
        assign axi_out_tuser_vendor[i] = axi_out_tuser[i].vendor;
        assign axi_out_tuser_last_segment[i] = axi_out_tuser[i].last_segment;
        assign axi_out_tuser_hvalid[i] = axi_out_tuser[i].hvalid;
        assign axi_out_tuser_hdr[i] = axi_out_tuser[i].hdr;
    end

    // Random back-pressure
    always_ff @(posedge clk) begin
        axi_out.tready <= ($urandom() & 4'hf) != 4'hf;
    end


    // ====================================================================
    //
    //  Compare output of the DUT to the source stream
    //
    // ====================================================================

    always_ff @(posedge clk) begin
        if (rst_n && axi_out.tvalid && axi_out.tready) begin
            if (|(axi_out_tuser_hvalid)) begin
                $fwrite(log_out_fd, "%0t: hvalid b%b hdr %h\n", $time,
                        axi_out_tuser_hvalid,
                        axi_out_tuser_hdr);
            end
            $fwrite(log_out_fd, "%0t: last %b last_seg b%b data %h keep %h\n", $time,
                    axi_out.tlast,
                    axi_out_tuser_last_segment,
                    axi_out.tdata,
                    axi_out.tkeep);

            tlp_stream_out.push(axi_out.tdata, axi_out.tkeep, axi_out.tlast,
                                axi_out_tuser_vendor, axi_out_tuser_last_segment,
                                axi_out_tuser_hvalid, axi_out_tuser_hdr);
        end
    end

    always_ff @(posedge clk) begin
        if (rst_n) begin
            while (tlp_stream_out.tlp_queue.size() > 0) begin
                tlp_out = tlp_stream_out.tlp_queue.pop_front();
                $fwrite(log_out_fd, "%0t: %0s\n", $time, tlp_out.sfmt());

                // Reads from the TX stream have 0 in tag_h. Reads from the
                // TXREQ stream have 1 in tag_h.
                if ((tlp_out.tlp_type != rand_tlp_pkg::rand_tlp::TLP_NO_DATA) ||
                    !tlp_out.req_hdr.tag_h)
                begin
                    assert(tlp_ref_queue_tx.size() > 0) else
                        $fatal(1, "ERROR: Output TX TLP with no corresponding input!");
                    tlp_ref = tlp_ref_queue_tx.pop_front();
                    tlp_out.compare(tlp_ref);
                end else begin
                    assert(tlp_ref_queue_txreq.size() > 0) else
                        $fatal(1, "ERROR: Output TXREQ TLP with no corresponding input!");
                    tlp_ref = tlp_ref_queue_txreq.pop_front();
                    tlp_out.compare(tlp_ref);
                end
            end
        end
    end

    always_ff @(posedge clk) begin
        if (!done && stop_stream && (tlp_ref_queue_tx.size() == 0) && (tlp_ref_queue_txreq.size() == 0)) begin
            $fwrite(log_out_fd, "\nPass tx_merge data width %0d, num seg %0d, %0s headers, %0d packets\n",
                    DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $display("  Pass tx_merge data width %0d, num seg %0d, %0s headers, %0d packets",
                     DATA_WIDTH, NUM_OF_SEG, SB_STRING, cnt);
            $fflush(log_in_tx_fd);
            $fflush(log_in_txreq_fd);
            $fflush(log_out_fd);
            done <= 1'b1;
        end

        if (!rst_n) begin
            done <= 1'b0;
        end
    end

endmodule
