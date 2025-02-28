// Copyright (C) 2024 Intel Corporation.
// SPDX-License-Identifier: MIT

//
// Description
//-----------------------------------------------------------------------------
//
//   Top level testbench with OFS top level module instantiated as DUT
//
//-----------------------------------------------------------------------------

module top_tb ();

//Timeout in 1ms
`ifdef SIM_TIMEOUT
    `define TIMEOUT `SIM_TIMEOUT
`else
    `define TIMEOUT 1000000000
`endif

    initial begin
`ifdef VCD_ON  
   `ifndef VCD_OFF
        $vcdpluson;
        $vcdplusmemon();
   `endif 
`endif
    end

    bit async_rst_n;
    bit clk, rst_n;
    bit csr_clk, csr_rst_n;

    always #100 clk = ~clk;
    always #210 csr_clk = ~csr_clk;

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        csr_clk = 1'b0;
        csr_rst_n = 1'b0;
        async_rst_n = 1'b0;
    end

    always @(posedge clk) rst_n <= async_rst_n;
    always @(posedge csr_clk) csr_rst_n <= async_rst_n;

    // Control structure for each test
    typedef struct packed {
        logic en;
        logic done;
    } t_test_ctrl;


    // side-band to in-band module test
    localparam NUM_TESTS_sb2ib = 4;
    t_test_ctrl ctrl_sb2ib[NUM_TESTS_sb2ib] = '{NUM_TESTS_sb2ib{'0}};

    test_sb2ib#(.DATA_WIDTH(256))  t0_sb2ib(.clk, .rst_n(rst_n && ctrl_sb2ib[0].en), .csr_clk, .csr_rst_n, .done(ctrl_sb2ib[0].done));
    test_sb2ib#(.DATA_WIDTH(512))  t1_sb2ib(.clk, .rst_n(rst_n && ctrl_sb2ib[1].en), .csr_clk, .csr_rst_n, .done(ctrl_sb2ib[1].done));
    test_sb2ib#(.DATA_WIDTH(1024)) t2_sb2ib(.clk, .rst_n(rst_n && ctrl_sb2ib[2].en), .csr_clk, .csr_rst_n, .done(ctrl_sb2ib[2].done));
    test_sb2ib#(.DATA_WIDTH(2048)) t3_sb2ib(.clk, .rst_n(rst_n && ctrl_sb2ib[3].en), .csr_clk, .csr_rst_n, .done(ctrl_sb2ib[3].done));


    // multiple headers per cycle to one header realignment test
    localparam NUM_TESTS_rx_seg_align = 6;
    t_test_ctrl ctrl_rx_seg_align[NUM_TESTS_rx_seg_align] = '{NUM_TESTS_rx_seg_align{'0}};

    test_rx_seg_align#(.DATA_WIDTH(256),  .SB_HEADERS(1)) t0_rx_seg_align(.clk, .rst_n(rst_n && ctrl_rx_seg_align[0].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_seg_align[0].done));
    test_rx_seg_align#(.DATA_WIDTH(256),  .SB_HEADERS(0)) t1_rx_seg_align(.clk, .rst_n(rst_n && ctrl_rx_seg_align[1].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_seg_align[1].done));
    test_rx_seg_align#(.DATA_WIDTH(512),  .SB_HEADERS(1)) t2_rx_seg_align(.clk, .rst_n(rst_n && ctrl_rx_seg_align[2].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_seg_align[2].done));
    test_rx_seg_align#(.DATA_WIDTH(512),  .SB_HEADERS(0)) t3_rx_seg_align(.clk, .rst_n(rst_n && ctrl_rx_seg_align[3].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_seg_align[3].done));
    test_rx_seg_align#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t4_rx_seg_align(.clk, .rst_n(rst_n && ctrl_rx_seg_align[4].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_seg_align[4].done));
    test_rx_seg_align#(.DATA_WIDTH(1024), .SB_HEADERS(0)) t5_rx_seg_align(.clk, .rst_n(rst_n && ctrl_rx_seg_align[5].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_seg_align[5].done));


    // in-band to side-band module test
    localparam NUM_TESTS_ib2sb = 5;
    t_test_ctrl ctrl_ib2sb[NUM_TESTS_ib2sb] = '{NUM_TESTS_ib2sb{'0}};

    test_ib2sb#(.DATA_WIDTH(256))  t0_ib2sb(.clk, .rst_n(rst_n && ctrl_ib2sb[0].en), .csr_clk, .csr_rst_n, .done(ctrl_ib2sb[0].done));
    test_ib2sb#(.DATA_WIDTH(512), .NUM_OF_SEG(1)) t1_ib2sb(.clk, .rst_n(rst_n && ctrl_ib2sb[1].en), .csr_clk, .csr_rst_n, .done(ctrl_ib2sb[1].done));
    test_ib2sb#(.DATA_WIDTH(512))  t2_ib2sb(.clk, .rst_n(rst_n && ctrl_ib2sb[2].en), .csr_clk, .csr_rst_n, .done(ctrl_ib2sb[2].done));
    test_ib2sb#(.DATA_WIDTH(1024)) t3_ib2sb(.clk, .rst_n(rst_n && ctrl_ib2sb[3].en), .csr_clk, .csr_rst_n, .done(ctrl_ib2sb[3].done));
    test_ib2sb#(.DATA_WIDTH(2048)) t4_ib2sb(.clk, .rst_n(rst_n && ctrl_ib2sb[4].en), .csr_clk, .csr_rst_n, .done(ctrl_ib2sb[4].done));


    // rx dual stream splitter
    localparam NUM_TESTS_rx_dual_stream = 8;
    t_test_ctrl ctrl_rx_dual_stream[NUM_TESTS_rx_dual_stream] = '{NUM_TESTS_rx_dual_stream{'0}};

    test_rx_dual_stream#(.DATA_WIDTH(256), .SB_HEADERS(1)) t0_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[0].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[0].done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .NUM_OF_SEG(1), .SB_HEADERS(1)) t1_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[1].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[1].done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .SB_HEADERS(1))  t2_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[2].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[2].done));
    test_rx_dual_stream#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t3_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[3].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[3].done));
    test_rx_dual_stream#(.DATA_WIDTH(256), .SB_HEADERS(0)) t4_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[4].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[4].done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .NUM_OF_SEG(1), .SB_HEADERS(0)) t5_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[5].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[5].done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .SB_HEADERS(0))  t6_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[6].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[6].done));
    test_rx_dual_stream#(.DATA_WIDTH(1024), .SB_HEADERS(0)) t7_rx_dual_stream(.clk, .rst_n(rst_n && ctrl_rx_dual_stream[7].en), .csr_clk, .csr_rst_n, .done(ctrl_rx_dual_stream[7].done));


    // merge dual tx streams into one
    localparam NUM_TESTS_tx_merge = 6;
    t_test_ctrl ctrl_tx_merge[NUM_TESTS_tx_merge] = '{NUM_TESTS_tx_merge{'0}};

    test_tx_merge#(.DATA_WIDTH(256), .SB_HEADERS(1)) t0_tx_merge(.clk, .rst_n(rst_n && ctrl_tx_merge[0].en), .csr_clk, .csr_rst_n, .done(ctrl_tx_merge[0].done));
    test_tx_merge#(.DATA_WIDTH(256), .SB_HEADERS(0)) t1_tx_merge(.clk, .rst_n(rst_n && ctrl_tx_merge[1].en), .csr_clk, .csr_rst_n, .done(ctrl_tx_merge[1].done));
    test_tx_merge#(.DATA_WIDTH(512), .SB_HEADERS(1)) t2_tx_merge(.clk, .rst_n(rst_n && ctrl_tx_merge[2].en), .csr_clk, .csr_rst_n, .done(ctrl_tx_merge[2].done));
    test_tx_merge#(.DATA_WIDTH(512), .SB_HEADERS(0)) t3_tx_merge(.clk, .rst_n(rst_n && ctrl_tx_merge[3].en), .csr_clk, .csr_rst_n, .done(ctrl_tx_merge[3].done));
    test_tx_merge#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t4_tx_merge(.clk, .rst_n(rst_n && ctrl_tx_merge[4].en), .csr_clk, .csr_rst_n, .done(ctrl_tx_merge[4].done));
    test_tx_merge#(.DATA_WIDTH(1024), .SB_HEADERS(0)) t5_tx_merge(.clk, .rst_n(rst_n && ctrl_tx_merge[5].en), .csr_clk, .csr_rst_n, .done(ctrl_tx_merge[5].done));


    // Width and header position aren't relevant. The bus isn't being monitored.
    localparam NUM_TESTS_cpl_metering = 3;
    t_test_ctrl ctrl_cpl_metering[NUM_TESTS_cpl_metering] = '{NUM_TESTS_cpl_metering{'0}};

    test_cpl_metering#(.DATA_WIDTH(256), .SB_HEADERS(0)) t0_cpl_metering(.clk, .rst_n(rst_n && ctrl_cpl_metering[0].en), .csr_clk, .csr_rst_n, .done(ctrl_cpl_metering[0].done));
    test_cpl_metering#(.DATA_WIDTH(512), .SB_HEADERS(0)) t1_cpl_metering(.clk, .rst_n(rst_n && ctrl_cpl_metering[1].en), .csr_clk, .csr_rst_n, .done(ctrl_cpl_metering[1].done));
    test_cpl_metering#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t2_cpl_metering(.clk, .rst_n(rst_n && ctrl_cpl_metering[2].en), .csr_clk, .csr_rst_n, .done(ctrl_cpl_metering[2].done));


`define RUN_TEST_GROUP(group) \
    for (int n = 0; n < NUM_TESTS_``group; n += 1) begin \
        $display("Running %0s[%0d]:", `"group`", n);     \
        ctrl_``group``[n].en = 1'b1;                     \
        async_rst_n = 1'b1;                              \
        fork begin                                       \
            fork                                         \
                wait(ctrl_``group``[n].done);            \
                begin                                    \
                    #(`TIMEOUT);                         \
                    $fatal(1, "ERROR: TIMEOUT!");        \
                end                                      \
            join_any                                     \
            disable fork;                                \
        end join                                         \
        #1us;                                            \
        ctrl_``group``[n].en = 1'b0;                     \
        async_rst_n = 1'b0;                              \
        #1us;                                            \
    end

    initial begin
        //
        // Sequencer for all tests. If you are debugging one that fails,
        // earlier tests can be temporarily disabled by commenting out
        // RUN_TEST.
        //
        #2us

        `RUN_TEST_GROUP(sb2ib)
        `RUN_TEST_GROUP(rx_seg_align)
        `RUN_TEST_GROUP(ib2sb)
        `RUN_TEST_GROUP(rx_dual_stream)
        `RUN_TEST_GROUP(tx_merge)
        `RUN_TEST_GROUP(cpl_metering)

        // The test aborts on failure, so reaching here means it passed
        $display("Test passed!");
        $finish;
    end

endmodule
