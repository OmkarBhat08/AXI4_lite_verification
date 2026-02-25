`include "uvm_macros.svh"  
`include "axi4_package.sv"
`include "axi4_interface.sv"
// `include "axi4_assertions.sv"
`include "../design/axi4_design.v"

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
  axi4_if axi_if (ACLK, ARESETn);


  // ================= DUT =================
  axi_lite_slave dut (
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

    .LED           (axi_if.LED),
    .SEG_CATHODE   (axi_if.SEG_CATHODE),
    .SEG_ANODE     (axi_if.SEG_ANODE),
    .IRQ_OUT       (axi_if.IRQ_OUT),

    .EXT_IRQ_IN    (axi_if.EXT_IRQ_IN)
  );


  // ================= ASSERTION BIND =================
  // bind axi_lite_slave axi4_assertions assertions_inst (

  //   .ACLK          (ACLK),
  //   .ARESETn       (ARESETN),

  //   .AWADDR        (AWADDR),
  //   .AWPROT        (AWPROT),
  //   .AWVALID       (AWVALID),
  //   .AWREADY       (AWREADY),

  //   .WDATA         (WDATA),
  //   .WSTRB         (WSTRB),
  //   .WVALID        (WVALID),
  //   .WREADY        (WREADY),

  //   .BRESP         (BRESP),
  //   .BVALID        (BVALID),
  //   .BREADY        (BREADY),

  //   .ARADDR        (ARADDR),
  //   .ARPROT        (ARPROT),
  //   .ARVALID       (ARVALID),
  //   .ARREADY       (ARREADY),

  //   .RDATA         (RDATA),
  //   .RRESP         (RRESP),
  //   .RVALID        (RVALID),
  //   .RREADY        (RREADY),

  //   .LED           (LED),
  //   .SEG_CATHODE   (SEG_CATHODE),
  //   .SEG_ANODE     (SEG_ANODE),
  //   .IRQ_OUT       (IRQ_OUT),

  //   .EXT_IRQ_IN    (EXT_IRQ_IN)
  // );


  // ================= UVM START =================
  initial begin
    uvm_config_db #(virtual axi4_if)::set(null, "*", "vif", axi_if);
    run_test("axi4_base_test");
  end

endmodule
