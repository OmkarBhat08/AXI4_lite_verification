//`timescale 1ns/1ps

import uvm_pkg::*;
`include "uvm_macros.svh"
`include "axi4_package.sv"
`include "axi4_interface.sv"
//`include "axi4_design.v"

module top;

  import axi4_pkg::*; 
  import uvm_pkg::*;
  
  bit ACLK;
  bit ARESETn;

  initial ACLK = 0;
  always #5 ACLK = ~ACLK;
  
  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
  end

  initial begin
    ARESETn = 0;
    #20;
    ARESETn = 1;
  end

  inf axi_if (ACLK, ARESETn);


  // ---------------- DUT ----------------
  axi_ledseg_irq dut (
    .ACLK         (ACLK),
    .ARESETn      (ARESETn),

    .S_AWADDR     (axi_if.S_AWADDR),
    .S_AWVALID    (axi_if.S_AWVALID),
    .S_AWREADY    (axi_if.S_AWREADY),

    .S_WDATA      (axi_if.S_WDATA),
    .S_WSTRB      (axi_if.S_WSTRB),
    .S_WVALID     (axi_if.S_WVALID),
    .S_WREADY     (axi_if.S_WREADY),

    .S_BREADY     (axi_if.S_BREADY),
    .S_BVALID     (axi_if.S_BVALID),
    .S_BRESP      (axi_if.S_BRESP),

    .S_ARADDR     (axi_if.S_ARADDR),
    .S_ARVALID    (axi_if.S_ARVALID),
    .S_ARREADY    (axi_if.S_ARREADY),

    .S_RREADY     (axi_if.S_RREADY),
    .S_RDATA      (axi_if.S_RDATA),
    .S_RVALID     (axi_if.S_RVALID),
    .S_RRESP      (axi_if.S_RRESP),

    .LED_OUT      (axi_if.LED_OUT),
    .SEVENSEG_OUT (axi_if.SEVENSEG_OUT),
    .IRQ_OUT      (axi_if.IRQ_OUT)
  );

// ---------------- Bind Assertions ----------------
// bind inf axi4_assertions ASSERT (
//   .ACLK         (ACLK),
//   .ARESETn      (ARESETn),

//   .S_AWADDR     (S_AWADDR),
//   .S_AWVALID    (S_AWVALID),
//   .S_AWREADY    (S_AWREADY),

//   .S_WDATA      (S_WDATA),
//   .S_WSTRB      (S_WSTRB),
//   .S_WVALID     (S_WVALID),
//   .S_WREADY     (S_WREADY),

//   .S_BREADY     (S_BREADY),
//   .S_BVALID     (S_BVALID),
//   .S_BRESP      (S_BRESP),

//   .S_ARADDR     (S_ARADDR),
//   .S_ARVALID    (S_ARVALID),
//   .S_ARREADY    (S_ARREADY),

//   .S_RREADY     (S_RREADY),
//   .S_RDATA      (S_RDATA),
//   .S_RVALID     (S_RVALID),
//   .S_RRESP      (S_RRESP),

//   .LED_OUT      (LED_OUT),
//   .SEVENSEG_OUT (SEVENSEG_OUT),
//   .IRQ_OUT      (IRQ_OUT)
// );

  // ---------------- Setting up config db ----------------
  initial begin
    uvm_config_db #(virtual inf)::set(null, "*", "vif", axi_if);
  //run_test("axi4_regression_test");
//     run_test("axi4_base_test");
//     run_test("axi4_reset_test");
    run_test("axi4_valid_write_handshake_test");
   //  run_test("axi4_address_before_data_test");
//        run_test("axi4_data_before_address_test");
     //run_test("axi4_response_check_test");
 //   run_test("axi4_BVALID_hold_test");
      //run_test("axi4_back_to_back_write_test");
        //un_test("axi4_multiple_outstanding_write_test");
//      run_test("axi4_invalid_address_write_test");
//        run_test("axi4_unaligned_address_write_test");
    //      run_test("axi4_led_write_read_test");
   // run_test("axi4_concurrent_write_read_test");
  end

endmodule
