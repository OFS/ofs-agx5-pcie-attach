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

    logic async_rst_n;
    logic clk, rst_n;
    logic csr_clk, csr_rst_n;

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

    logic test0_en = 1'b0;
    logic test0_done;
    logic test1_en = 1'b0;
    logic test1_done;
    logic test2_en = 1'b0;
    logic test2_done;
    logic test3_en = 1'b0;
    logic test3_done;
    logic test4_en = 1'b0;
    logic test4_done;
    logic test5_en = 1'b0;
    logic test5_done;
    logic test6_en = 1'b0;
    logic test6_done;
    logic test7_en = 1'b0;
    logic test7_done;
    logic test8_en = 1'b0;
    logic test8_done;
    logic test9_en = 1'b0;
    logic test9_done;
    logic test10_en = 1'b0;
    logic test10_done;
    logic test11_en = 1'b0;
    logic test11_done;
    logic test12_en = 1'b0;
    logic test12_done;
    logic test13_en = 1'b0;
    logic test13_done;
    logic test14_en = 1'b0;
    logic test14_done;
    logic test15_en = 1'b0;
    logic test15_done;
    logic test16_en = 1'b0;
    logic test16_done;
    logic test17_en = 1'b0;
    logic test17_done;
    logic test18_en = 1'b0;
    logic test18_done;
    logic test19_en = 1'b0;
    logic test19_done;
    logic test20_en = 1'b0;
    logic test20_done;
    logic test21_en = 1'b0;
    logic test21_done;
    logic test22_en = 1'b0;
    logic test22_done;

`define RUN_TEST(test) \
    $display("Running %0s:", `"test`");  \
    test``_en = 1'b1;                    \
    async_rst_n = 1'b1;                  \
    fork begin                           \
        fork                             \
            wait(test``_done);           \
            begin                        \
                #(`TIMEOUT);             \
                $fatal(1, "ERROR: TIMEOUT!");   \
            end                          \
        join_any                         \
        disable fork;                    \
    end join                             \
    test``_en = 1'b0;                    \
    async_rst_n = 1'b0;                  \
    #1us

    initial begin
        //
        // Sequencer for all tests. If you are debugging one that fails,
        // earlier tests can be temporarily disabled by commenting out
        // RUN_TEST.
        //

        `RUN_TEST(test0);
        `RUN_TEST(test1);
        `RUN_TEST(test2);

        `RUN_TEST(test3);
        `RUN_TEST(test4);
        `RUN_TEST(test5);
        `RUN_TEST(test6);

        `RUN_TEST(test7);
        `RUN_TEST(test8);
        `RUN_TEST(test9);
        `RUN_TEST(test10);

        `RUN_TEST(test11);
        `RUN_TEST(test12);
        `RUN_TEST(test13);
        `RUN_TEST(test14);
        `RUN_TEST(test15);
        `RUN_TEST(test16);

        `RUN_TEST(test17);
        `RUN_TEST(test18);
        `RUN_TEST(test19);
        `RUN_TEST(test20);
        `RUN_TEST(test21);
        `RUN_TEST(test22);

        // The test aborts on failure, so reaching here means it passed
        $display("Test passed!");
        $finish;
    end

    // side-band to in-band module test
    test_sb2ib#(.DATA_WIDTH(512))  t0_sb2ib(.clk, .rst_n(rst_n && test0_en), .csr_clk, .csr_rst_n, .done(test0_done));
    test_sb2ib#(.DATA_WIDTH(1024)) t1_sb2ib(.clk, .rst_n(rst_n && test1_en), .csr_clk, .csr_rst_n, .done(test1_done));
    test_sb2ib#(.DATA_WIDTH(2048)) t2_sb2ib(.clk, .rst_n(rst_n && test2_en), .csr_clk, .csr_rst_n, .done(test2_done));

    // multiple headers per cycle to one header realignment test
    test_rx_seg_align#(.DATA_WIDTH(512),  .SB_HEADERS(1)) t3_rx_seg_align(.clk, .rst_n(rst_n && test3_en), .csr_clk, .csr_rst_n, .done(test3_done));
    test_rx_seg_align#(.DATA_WIDTH(512),  .SB_HEADERS(0)) t4_rx_seg_align(.clk, .rst_n(rst_n && test4_en), .csr_clk, .csr_rst_n, .done(test4_done));
    test_rx_seg_align#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t5_rx_seg_align(.clk, .rst_n(rst_n && test5_en), .csr_clk, .csr_rst_n, .done(test5_done));
    test_rx_seg_align#(.DATA_WIDTH(1024), .SB_HEADERS(0)) t6_rx_seg_align(.clk, .rst_n(rst_n && test6_en), .csr_clk, .csr_rst_n, .done(test6_done));

    // in-band to side-band module test
    test_ib2sb#(.DATA_WIDTH(512), .NUM_OF_SEG(1)) t7_ib2sb(.clk, .rst_n(rst_n && test7_en), .csr_clk, .csr_rst_n, .done(test7_done));
    test_ib2sb#(.DATA_WIDTH(512))  t8_ib2sb(.clk, .rst_n(rst_n && test8_en), .csr_clk, .csr_rst_n, .done(test8_done));
    test_ib2sb#(.DATA_WIDTH(1024)) t9_ib2sb(.clk, .rst_n(rst_n && test9_en), .csr_clk, .csr_rst_n, .done(test9_done));
    test_ib2sb#(.DATA_WIDTH(2048)) t10_ib2sb(.clk, .rst_n(rst_n && test10_en), .csr_clk, .csr_rst_n, .done(test10_done));

    test_rx_dual_stream#(.DATA_WIDTH(512), .NUM_OF_SEG(1), .SB_HEADERS(1)) t11_rx_dual_stream(.clk, .rst_n(rst_n && test11_en), .csr_clk, .csr_rst_n, .done(test11_done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .SB_HEADERS(1))  t12_rx_dual_stream(.clk, .rst_n(rst_n && test12_en), .csr_clk, .csr_rst_n, .done(test12_done));
    test_rx_dual_stream#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t13_rx_dual_stream(.clk, .rst_n(rst_n && test13_en), .csr_clk, .csr_rst_n, .done(test13_done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .NUM_OF_SEG(1), .SB_HEADERS(0)) t14_rx_dual_stream(.clk, .rst_n(rst_n && test14_en), .csr_clk, .csr_rst_n, .done(test14_done));
    test_rx_dual_stream#(.DATA_WIDTH(512), .SB_HEADERS(0))  t15_rx_dual_stream(.clk, .rst_n(rst_n && test15_en), .csr_clk, .csr_rst_n, .done(test15_done));
    test_rx_dual_stream#(.DATA_WIDTH(1024), .SB_HEADERS(0)) t16_rx_dual_stream(.clk, .rst_n(rst_n && test16_en), .csr_clk, .csr_rst_n, .done(test16_done));

    test_tx_merge#(.DATA_WIDTH(512), .SB_HEADERS(1)) t17_tx_merge(.clk, .rst_n(rst_n && test17_en), .csr_clk, .csr_rst_n, .done(test17_done));
    test_tx_merge#(.DATA_WIDTH(512), .SB_HEADERS(0)) t18_tx_merge(.clk, .rst_n(rst_n && test18_en), .csr_clk, .csr_rst_n, .done(test18_done));
    test_tx_merge#(.DATA_WIDTH(1024), .SB_HEADERS(1)) t19_tx_merge(.clk, .rst_n(rst_n && test19_en), .csr_clk, .csr_rst_n, .done(test19_done));
    test_tx_merge#(.DATA_WIDTH(1024), .SB_HEADERS(0)) t20_tx_merge(.clk, .rst_n(rst_n && test20_en), .csr_clk, .csr_rst_n, .done(test20_done));
    test_tx_merge#(.DATA_WIDTH(256), .SB_HEADERS(1)) t21_tx_merge(.clk, .rst_n(rst_n && test21_en), .csr_clk, .csr_rst_n, .done(test21_done));
    test_tx_merge#(.DATA_WIDTH(256), .SB_HEADERS(0)) t22_tx_merge(.clk, .rst_n(rst_n && test22_en), .csr_clk, .csr_rst_n, .done(test22_done));

endmodule
