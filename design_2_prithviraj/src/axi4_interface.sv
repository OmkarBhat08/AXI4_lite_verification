`include "define.sv"

interface axi4_if (input bit ACLK,input bit ARESETn);

  // ================= WRITE ADDRESS =================
  bit   [`ADDR_WIDTH-1:0] AWADDR;
  bit   [2:0]            AWPROT;
  bit                    AWVALID;
  logic                  AWREADY;

  // ================= WRITE DATA =================
  bit   [`DATA_WIDTH-1:0] WDATA;
  bit   [3:0]            WSTRB;
  bit                    WVALID;
  logic                  WREADY;

  // ================= WRITE RESPONSE =================
  logic [1:0]            BRESP;
  logic                  BVALID;
  bit                    BREADY;

  // ================= READ ADDRESS =================
  bit   [`ADDR_WIDTH-1:0] ARADDR;
  bit   [2:0]            ARPROT;
  bit                    ARVALID;
  logic                  ARREADY;

  // ================= READ DATA =================
  logic [`DATA_WIDTH-1:0] RDATA;
  logic [1:0]            RRESP;
  logic                  RVALID;
  bit                    RREADY;

  // ================= EXTERNAL INTERRUPT =================
  bit                    ext_irq_in;

  // ================= OUTPUTS =================
  logic [3:0]            leds;
  logic [6:0]            seg_cathode;
  logic [3:0]            seg_anode;
  logic                  irq_out;


  // ================= DRIVER CLOCKING BLOCK =================
  clocking drv_cb @(posedge ACLK);

    default input #0 output #0;
    
    output AWADDR, AWPROT, AWVALID;
    input  AWREADY;

    output WDATA, WSTRB, WVALID;
    input  WREADY;

    input  BRESP, BVALID;
    output BREADY;

    output ARADDR, ARPROT, ARVALID;
    input  ARREADY;

    input  RDATA, RRESP, RVALID;
    output RREADY;

    output ext_irq_in;

  endclocking


  // ================= MONITOR CLOCKING BLOCK =================
  clocking mon_cb @(posedge ACLK);
    
    default input #0 output #0;

    input AWADDR, AWPROT, AWVALID, AWREADY;
    input WDATA, WSTRB, WVALID, WREADY;
    input BRESP, BVALID, BREADY;

    input ARADDR, ARPROT, ARVALID, ARREADY;
    input RDATA, RRESP, RVALID, RREADY;

    input ext_irq_in;
    input leds, seg_cathode, seg_anode, irq_out;

  endclocking


  modport DRV (clocking drv_cb);
  modport MON (clocking mon_cb);

endinterface
