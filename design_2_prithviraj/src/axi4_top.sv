`include "uvm_macros.svh"  
`include "axi4_package.sv"
`include "axi4_interface.sv"
// `include "axi4_assertions.sv"
`include "axi_peripheral_top.v"

module top;

  import uvm_pkg::*;
  import axi4_pkg::*;
  // ================= CLOCK & RESET =================
  bit ACLK;
  bit ARESETn;

  initial ACLK = 0;
  always #5 ACLK = ~ACLK;

  initial begin
    ARESETn = 0;
    #20;
    ARESETn = 1;
  end


  // ================= INTERFACE =================
   inf axi_if (ACLK, ARESETn);

  // ================= DUT =================
  axi_peripheral_top dut (

    .S_AXI_ACLK    (ACLK),
    .S_AXI_ARESETN (ARESETn),

    .S_AXI_AWADDR  (axi_if.AWADDR),
    .S_AXI_AWPROT  (axi_if.AWPROT),
    .S_AXI_AWVALID (axi_if.AWVALID),
    .S_AXI_AWREADY (axi_if.AWREADY),

    .S_AXI_WDATA   (axi_if.WDATA),
    .S_AXI_WSTRB   (axi_if.WSTRB),
    .S_AXI_WVALID  (axi_if.WVALID),
    .S_AXI_WREADY  (axi_if.WREADY),

    .S_AXI_BRESP   (axi_if.BRESP),
    .S_AXI_BVALID  (axi_if.BVALID),
    .S_AXI_BREADY  (axi_if.BREADY),

    .S_AXI_ARADDR  (axi_if.ARADDR),
    .S_AXI_ARPROT  (axi_if.ARPROT),
    .S_AXI_ARVALID (axi_if.ARVALID),
    .S_AXI_ARREADY (axi_if.ARREADY),

    .S_AXI_RDATA   (axi_if.RDATA),
    .S_AXI_RRESP   (axi_if.RRESP),
    .S_AXI_RVALID  (axi_if.RVALID),
    .S_AXI_RREADY  (axi_if.RREADY),

    .leds          (axi_if.leds),
    .seg_cathode   (axi_if.seg_cathode),
    .seg_anode     (axi_if.seg_anode),
    .irq_out       (axi_if.irq_out),

    .ext_irq_in    (axi_if.ext_irq_in)
  );


  // // ================= ASSERTION BIND =================
  // bind axi_lite_slave axi4_assertions assertions_inst (
  //   .ACLK        (S_AXI_ACLK),
  //   .ARESETn     (S_AXI_ARESETN),

  //   .AWADDR      (S_AXI_AWADDR),
  //   .AWVALID     (S_AXI_AWVALID),
  //   .AWREADY     (S_AXI_AWREADY),

  //   .WDATA       (S_AXI_WDATA),
  //   .WVALID      (S_AXI_WVALID),
  //   .WREADY      (S_AXI_WREADY),

  //   .BRESP       (S_AXI_BRESP),
  //   .BVALID      (S_AXI_BVALID),
  //   .BREADY      (S_AXI_BREADY),

  //   .ARADDR      (S_AXI_ARADDR),
  //   .ARVALID     (S_AXI_ARVALID),
  //   .ARREADY     (S_AXI_ARREADY),

  //   .RDATA       (S_AXI_RDATA),
  //   .RVALID      (S_AXI_RVALID),
  //   .RREADY      (S_AXI_RREADY)
  // );


  // ================= UVM CONFIG =================
  initial begin
    uvm_config_db #(virtual axi4_if)::set(null, "*", "vif", axi_if);
    run_test("axi4_base_test");
  end

endmodule
