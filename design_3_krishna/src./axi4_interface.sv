`include "define.sv"

interface inf (input bit ACLK,input bit ARESETn);

  // ================= WRITE ADDRESS CHANNEL =================
  bit   [`ADDR_WIDTH-1:0]  AWADDR;
  bit   [2:0]              AWPROT;
  bit                      AWVALID;
  logic                    AWREADY;

  // ================= WRITE DATA CHANNEL =================
  bit   [`DATA_WIDTH-1:0]  WDATA;
  bit   [3:0]              WSTRB;
  bit                      WVALID;
  logic                    WREADY;

  // ================= WRITE RESPONSE CHANNEL =================
  logic [1:0]              BRESP;
  logic                    BVALID;
  bit                      BREADY;

  // ================= READ ADDRESS CHANNEL =================
  bit   [`ADDR_WIDTH-1:0]  ARADDR;
  bit   [2:0]              ARPROT;
  bit                      ARVALID;
  logic                    ARREADY;

  // ================= READ DATA CHANNEL =================
  logic [`DATA_WIDTH-1:0]  RDATA;
  logic [1:0]              RRESP;
  logic                    RVALID;
  bit                      RREADY;

  // ================= EXTERNAL INTERRUPT =================
  bit                      EXT_IRQ_IN;

  // ================= OUTPUTS =================
  logic [3:0]              LED;
  logic [6:0]              SEG_CATHODE;
  logic [3:0]              SEG_ANODE;
  logic                    IRQ_OUT;


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

    output EXT_IRQ_IN;

  endclocking


  // ================= MONITOR CLOCKING BLOCK =================
  clocking mon_cb @(posedge ACLK);
    
    default input #0 output #0;
    
    input AWADDR, AWPROT, AWVALID, AWREADY;
    input WDATA, WSTRB, WVALID, WREADY;
    input BRESP, BVALID, BREADY;

    input ARADDR, ARPROT, ARVALID, ARREADY;
    input RDATA, RRESP, RVALID, RREADY;

    input EXT_IRQ_IN;
    input LED, SEG_CATHODE, SEG_ANODE, IRQ_OUT;

  endclocking


  modport DRV (clocking drv_cb);
  modport MON (clocking mon_cb);

endinterface
