`include "define.sv"
interface inf(input bit ACLK, input bit ARESETn);

// ---------------- WRITE ADDRESS CHANNEL ----------------
  bit  [ADDR_WIDTH-1:0]  S_AWADDR;
  bit                    S_AWVALID;
  logic                  S_AWREADY;

// ---------------- WRITE DATA CHANNEL ----------------
  bit  [DATA_WIDTH-1:0]  S_WDATA;
  bit  [3:0]             S_WSTRB;
  bit                    S_WVALID;
  logic                  S_WREADY;

// ---------------- WRITE RESPONSE CHANNEL ----------------
  bit                    S_BREADY;
  logic                  S_BVALID;
  logic [1:0]            S_BRESP;

// ---------------- READ ADDRESS CHANNEL ----------------
  bit  [ADDR_WIDTH-1:0]  S_ARADDR;
  bit                    S_ARVALID;
  logic                  S_ARREADY;

// ---------------- READ DATA CHANNEL ----------------
  bit                    S_RREADY;
  logic [DATA_WIDTH-1:0] S_RDATA;
  logic                  S_RVALID;
  logic [1:0]            S_RRESP;

// ---------------- EXTERNAL OUTPUTS ----------------
  logic [7:0]            LED_OUT;
  logic [7:0]            SEVENSEG_OUT;
  logic                  IRQ_OUT;


// ================= CLOCKING BLOCK FOR DRIVER =================
clocking drv_cb @(posedge ACLK);

  default input #0 output #0;

  output S_AWADDR, S_AWVALID;
  input  S_AWREADY;

  output S_WDATA, S_WSTRB, S_WVALID;
  input  S_WREADY;

  output S_BREADY;
  input  S_BVALID, S_BRESP;

  output S_ARADDR, S_ARVALID;
  input  S_ARREADY;

  output S_RREADY;
  input  S_RDATA, S_RVALID, S_RRESP;

  input  LED_OUT, SEVENSEG_OUT, IRQ_OUT;

endclocking


// ================= CLOCKING BLOCK FOR MONITOR =================
clocking mon_cb @(posedge ACLK);

  default input #0 output #0;
  
  input S_AWADDR, S_AWVALID, S_AWREADY;
  input S_WDATA, S_WSTRB, S_WVALID, S_WREADY;
  input S_BREADY, S_BVALID, S_BRESP;

  input S_ARADDR, S_ARVALID, S_ARREADY;
  input S_RREADY, S_RDATA, S_RVALID, S_RRESP;

  input LED_OUT, SEVENSEG_OUT, IRQ_OUT;

endclocking


// ================= MODPORTS =================
modport DRV (clocking drv_cb);
modport MON (clocking mon_cb);

endinterface

