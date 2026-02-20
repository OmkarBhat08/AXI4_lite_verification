interface inf(input bit ACLK,input bit ARESETN);

  // ================= WRITE ADDRESS CHANNEL =================
  bit   [`ADDR_WIDTH-1:0]  S_AXI_AWADDR;
  bit   [2:0]              S_AXI_AWPROT;
  bit                      S_AXI_AWVALID;
  logic                    S_AXI_AWREADY;

  // ================= WRITE DATA CHANNEL =================
  bit   [`DATA_WIDTH-1:0]  S_AXI_WDATA;
  bit   [3:0]              S_AXI_WSTRB;
  bit                      S_AXI_WVALID;
  logic                    S_AXI_WREADY;

  // ================= WRITE RESPONSE CHANNEL =================
  logic [1:0]              S_AXI_BRESP;
  logic                    S_AXI_BVALID;
  bit                      S_AXI_BREADY;

  // ================= READ ADDRESS CHANNEL =================
  bit   [`ADDR_WIDTH-1:0]   S_AXI_ARADDR;
  bit   [2:0]              S_AXI_ARPROT;
  bit                      S_AXI_ARVALID;
  logic                    S_AXI_ARREADY;

  // ================= READ DATA CHANNEL =================
  logic [`DATA_WIDTH-1:0]   S_AXI_RDATA;
  logic [1:0]              S_AXI_RRESP;
  logic                    S_AXI_RVALID;
  bit                      S_AXI_RREADY;

  // ================= EXTERNAL SIGNALS =================
  bit                      EXT_IRQ_IN;

  logic [3:0]              LED;
  logic [6:0]              SEG_CATHODE;
  logic [3:0]              SEG_ANODE;
  logic                    IRQ_OUT;


  // =========================================================
  // DRIVER CLOCKING BLOCK
  // =========================================================
  clocking drv_cb @(posedge ACLK);
    default input #0 output #0;
    
    output S_AXI_AWADDR, S_AXI_AWPROT, S_AXI_AWVALID;
    input  S_AXI_AWREADY;

    output S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WVALID;
    input  S_AXI_WREADY;

    input  S_AXI_BRESP, S_AXI_BVALID;
    output S_AXI_BREADY;

    output S_AXI_ARADDR, S_AXI_ARPROT, S_AXI_ARVALID;
    input  S_AXI_ARREADY;

    input  S_AXI_RDATA, S_AXI_RRESP, S_AXI_RVALID;
    output S_AXI_RREADY;

    output EXT_IRQ_IN;

    input  LED, SEG_CATHODE, SEG_ANODE, IRQ_OUT;

  endclocking


  // =========================================================
  // MONITOR CLOCKING BLOCK
  // =========================================================
  clocking mon_cb @(posedge ACLK);
    default input #0 output #0;
    input S_AXI_AWADDR, S_AXI_AWPROT, S_AXI_AWVALID, S_AXI_AWREADY;
    input S_AXI_WDATA, S_AXI_WSTRB, S_AXI_WVALID, S_AXI_WREADY;
    input S_AXI_BRESP, S_AXI_BVALID, S_AXI_BREADY;

    input S_AXI_ARADDR, S_AXI_ARPROT, S_AXI_ARVALID, S_AXI_ARREADY;
    input S_AXI_RDATA, S_AXI_RRESP, S_AXI_RVALID, S_AXI_RREADY;

    input EXT_IRQ_IN;

    input LED, SEG_CATHODE, SEG_ANODE, IRQ_OUT;

  endclocking


  modport DRV (clocking drv_cb);
  modport MON (clocking mon_cb);

endinterface
