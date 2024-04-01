   // Copyright (C) 2020 Intel Corporation.
   // SPDX-License-Identifier: MIT
//---------------------------------------------------------
// Test module for the simulation. 
//---------------------------------------------------------

import host_bfm_types_pkg::*;

module unit_test #(
   parameter SOC_ATTACH = 0,
   parameter LINK_NUMBER = 0,
   parameter type pf_type = default_pfs, 
   parameter pf_type pf_list = '{1'b1}, 
   parameter type vf_type = default_vfs, 
   parameter vf_type vf_list = '{0}
)(
   input logic clk,
   input logic rst_n,
   input logic csr_clk,
   input logic csr_rst_n
);

import pfvf_class_pkg::*;
import host_memory_class_pkg::*;
import tag_manager_class_pkg::*;
import pfvf_status_class_pkg::*;
import packet_class_pkg::*;
import host_axis_send_class_pkg::*;
import host_axis_receive_class_pkg::*;
import host_transaction_class_pkg::*;
import host_bfm_class_pkg::*;
import host_flr_class_pkg::*;
import test_csr_defs::*;


//---------------------------------------------------------
// PFVF Structs 
//---------------------------------------------------------
pfvf_struct pfvf;

//---------------------------------------------------------
//  BEGIN: Test Tasks and Utilities
//---------------------------------------------------------
parameter MAX_TEST = 100;
parameter TIMEOUT = 10.0ms;
parameter RP_MAX_TAGS = 64;
localparam NUMBER_OF_LINKS = `OFS_FIM_IP_CFG_PCIE_SS_NUM_LINKS;
localparam string unit_test_name = "FLR Test";

//---------------------------------------------------------
// Mailbox 
//---------------------------------------------------------
mailbox #(host_bfm_types_pkg::mbx_message_t) mbx = new();
host_bfm_types_pkg::mbx_message_t mbx_msg;


typedef struct packed {
   logic result;
   logic [1024*8-1:0] name;
} t_test_info;

typedef enum bit [1:0] {MWR, MRD, CPLD, CPL} e_tlp_type;
typedef enum bit {ADDR32, ADDR64} e_addr_mode;
typedef enum bit {BIG_ENDIAN, LITTLE_ENDIAN} e_endian;

int err_count = 0;
logic [31:0] test_id;
t_test_info [MAX_TEST-1:0] test_summary;
logic reset_test;
logic [7:0] checker_err_count;
logic test_done;
logic all_tests_done;
logic test_result;

//---------------------------------------------------------
//  Test Utilities
//---------------------------------------------------------
function void incr_err_count();
   err_count++;
endfunction


function int get_err_count();
   return err_count;
endfunction


//---------------------------------------------------------
//  Test Tasks
//---------------------------------------------------------
task incr_test_id;
begin
   test_id = test_id + 1;
end
endtask

task post_test_util;
   input logic [31:0] old_test_err_count;
   output logic result;
begin
   if (get_err_count() > old_test_err_count) 
   begin
      result = 1'b0;
   end else begin
      result = 1'b1;
   end

   repeat (10) @(posedge clk);

   @(posedge clk);
      reset_test = 1'b1;
   repeat (5) @(posedge clk);
   reset_test = 1'b0;

   if (result) 
   begin
      $display("\nTest status: OK");
      test_summary[test_id].result = 1'b1;
   end 
   else 
   begin
      $display("\nTest status: FAILED");
      test_summary[test_id].result = 1'b0;
   end
   incr_test_id(); 
end
endtask


task print_test_header;
   input [1024*8-1:0] test_name;
   input logic        vf_active;
   input logic [2:0]  pfn;
   input logic [10:0] vfn;
begin
   $display("\n********************************************************");
   $display(" Running TEST(%0d) : %0s (vf_active=%0d, pfn=%0d vfn=%0d", test_id, test_name, vf_active, pfn, vfn);
   $display("********************************************************");   
   test_summary[test_id].name = test_name;
end
endtask


// Deassert AFU reset
task deassert_afu_reset;
   int count;
   logic [63:0] scratch;
   logic [31:0] wdata;
   logic        error;
   logic [31:0] PORT_CONTROL;
begin
   count = 0;
   PORT_CONTROL = 32'h71000 + 32'h38;
   //De-assert Port Reset 
   $display("\nDe-asserting Port Reset...");
   pfvf = '{0,0,0};
   host_bfm_top.host_bfm.set_pfvf_setting(pfvf);
   host_bfm_top.host_bfm.read64(PORT_CONTROL, scratch);
   wdata = scratch[31:0];
   wdata[0] = 1'b0;
   host_bfm_top.host_bfm.write32(PORT_CONTROL, wdata);
   #5000000 host_bfm_top.host_bfm.read64(PORT_CONTROL, scratch);
   if (scratch[4] != 1'b0) begin
      $display("\nERROR: Port Reset Ack Asserted!");
      incr_err_count();
      $finish;       
   end
   $display("\nAFU is out of reset ...");
   host_bfm_top.host_bfm.revert_to_last_pfvf_setting();
end
endtask

//---------------------------------------------------------
//  END: Test Tasks and Utilities
//---------------------------------------------------------

//---------------------------------------------------------
// Initials for Sim Setup
//---------------------------------------------------------
initial 
begin
   reset_test = 1'b0;
   test_id = '0;
   test_done = 1'b0;
   all_tests_done = 1'b0;
   test_result = 1'b0;
end


initial 
begin
   fork: timeout_thread begin
      $display("Begin Timeout Thread.  Test will timeout in %0t\n", TIMEOUT);
     // timeout thread, wait for TIMEOUT period to pass
     #(TIMEOUT);
     // The test hasn't finished within TIMEOUT Period
     @(posedge clk);
     $display ("TIMEOUT, test_pass didn't go high in %0t\n", TIMEOUT);
     disable timeout_thread;
   end
 
   wait (test_done==1) begin
      // Test summary
      $display("\n");
      $display("***************************");
      $display("  Test summary for link %0d", LINK_NUMBER);
      $display("***************************");
      for (int i=0; i < test_id; i=i+1) 
      begin
         if (test_summary[i].result)
            $display("   %0s (id=%0d) - pass", test_summary[i].name, i);
         else
            $display("   %0s (id=%0d) - FAILED", test_summary[i].name, i);
      end

      if(get_err_count() == 0) 
      begin
          $display("");
          $display("");
          $display("-----------------------------------------------------");
          $display("Test passed!");
          $display("Test:%s for--> Link:%0d", unit_test_name, LINK_NUMBER);
          $display("-----------------------------------------------------");
          $display("");
          $display("");
          $display("      '||''|.      |      .|'''.|   .|'''.|  ");
          $display("       ||   ||    |||     ||..  '   ||..  '  ");
          $display("       ||...|'   |  ||     ''|||.    ''|||.  ");
          $display("       ||       .''''|.  .     '|| .     '|| ");
          $display("      .||.     .|.  .||. |'....|'  |'....|'  ");
          $display("");
          $display("");
      end 
      else 
      begin
          if (get_err_count() != 0) 
          begin
             $display("");
             $display("");
             $display("-----------------------------------------------------");
             $display("Test FAILED! %d errors reported.\n", get_err_count());
             $display("Test:%s for--> Link:%0d", unit_test_name, LINK_NUMBER);
             $display("-----------------------------------------------------");
             $display("");
             $display("");
             $display("      '||''''|     |     '||' '||'      ");
             $display("       ||  .      |||     ||   ||       ");
             $display("       ||''|     |  ||    ||   ||       ");
             $display("       ||       .''''|.   ||   ||       ");
             $display("      .||.     .|.  .||. .||. .||.....| ");
             $display("");
             $display("");
          end
       end
   end
   join_any    
   if (LINK_NUMBER == 0)
   begin
      wait (all_tests_done);
      $finish();  
   end
end

generate
   if (LINK_NUMBER != 0)
   begin // This block covers the scenario where there is more than one link and link N needs to coordinate execution with link0.
      always begin : main   
         #10000;
         $display(">>> Link #1: Sending READY to Link0.  Waiting for release.");
         host_gen_block0.pcie_top_host0.unit_test.mbx.put(READY);
         mbx_msg = START;
         while (mbx_msg != GO)
         begin
            $display("Mailbox #1 State: %s", mbx_msg.name());
            mbx.get(mbx_msg);
         end
         $display(">>> Running %s on Link %0d...", unit_test_name, LINK_NUMBER);
         main_test(test_result);
         $display(">>> %s on Link %0d Completed.", unit_test_name, LINK_NUMBER);
         test_done = 1'b1;
         host_gen_block0.pcie_top_host0.unit_test.mbx.put(DONE);
      end
   end
   else
   begin
      if (NUMBER_OF_LINKS > 1)
      begin // This block covers the scenario where there is more than one link and link0 needs to communicate with the other links.
         always begin : main   
            #10000;
            wait (rst_n);
            wait (csr_rst_n);
            //-------------------------
            // deassert port reset
            //-------------------------
            deassert_afu_reset();
            //-------------------------
            // Test scenarios 
            //-------------------------
            $display(">>> Running %s on Link 0...", unit_test_name);
            main_test(test_result);
            $display(">>> %s on Link 0 Completed.", unit_test_name);
            test_done = 1'b1;
            #1000
            $display(">>> Link #0: Getting status from Link #1 Mailbox, testing for READY");
            mbx.try_get(mbx_msg);
            $display(">>> Link #0: Link #1 shows status as %s.", mbx_msg.name());
            $display(">>> Link #0: %s complete.  Sending GO to Link #1.", unit_test_name);
            mbx_msg = READY;
            host_gen_block1.pcie_top_host1.unit_test.mbx.put(GO);
            while (mbx_msg != DONE)
            begin
               $display("Mailbox #0 State: %s", mbx_msg.name());
               mbx.get(mbx_msg);
            end
            all_tests_done = 1'b1;
         end
      end
      else
      begin  // This block covers the scenario where there is only one link and no mailbox communication is required.
         always begin : main   
            #10000;
            wait (rst_n);
            wait (csr_rst_n);
            //-------------------------
            // deassert port reset
            //-------------------------
            deassert_afu_reset();
            //-------------------------
            // Test scenarios 
            //-------------------------
            $display(">>> Running %s on Link 0...", unit_test_name);
            main_test(test_result);
            $display(">>> %s on Link 0 Completed.", unit_test_name);
            test_done = 1'b1;
            all_tests_done = 1'b1;
         end
      end
   end
endgenerate


//---------------------------------------------------------
//  Unit Test Procedure
//---------------------------------------------------------
task main_test;
   output logic test_result;

   string test_name;
   PFVFClass#(pf_type, vf_type, pf_list, vf_list) test_flr;
   pfvf_struct test_flr_type;
   HostFLREvent#(pf_type, vf_type, pf_list, vf_list) flr;
   logic [31:0] old_test_err_count;

   begin
      $display("Entering %s." ,unit_test_name);
      @(posedge clk iff (rst_n === 1'b1));
      repeat (20) @(posedge clk);
      test_flr = new(0,0,0);
      test_flr.get_pfvf_first(test_flr_type);
      print_test_header("flr_test", '0, '0, '0);
      old_test_err_count = get_err_count();
      do
      begin
         automatic pfvf_struct flr_pfvf = test_flr_type;
         fork
            host_flr_top.flr_manager.send_flr(flr_pfvf);
         join_none
      end while (test_flr.get_pfvf_next(test_flr_type));
      wait fork;
      while (host_flr_top.flr_manager.num_all_outstanding_flrs() > 0 )
      begin
         @(posedge clk);
      end
      $display(">>> All Sent FLRs <<<");
      host_flr_top.flr_manager.print_all_sent_flrs();
      $display("");
      if(host_flr_top.flr_manager.num_all_outstanding_flrs() > 0) begin
         $display("ERROR: test has %0d outstanding FLR requests", host_flr_top.flr_manager.num_all_outstanding_flrs());
         $display(">>> All Outstanding FLRs <<<");
         host_flr_top.flr_manager.print_all_outstanding_flrs();
         incr_err_count();
      end
      $display("");
      if(host_flr_top.flr_manager.num_all_unmatched_responses() > 0) begin
         $display("ERROR: test has %0d unmatched FLR responses", host_flr_top.flr_manager.num_all_unmatched_responses());
         $display(">>> All Unmatched FLR Responses <<<");
         host_flr_top.flr_manager.print_all_unmatched_responses();
         incr_err_count();
      end
      $display("");

      post_test_util(old_test_err_count, test_result);
      
      repeat (10) @(posedge clk);
   end
endtask


endmodule
