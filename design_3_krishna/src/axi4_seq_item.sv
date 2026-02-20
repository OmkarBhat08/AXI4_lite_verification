class axi4_seq_item extends uvm_sequence_item;

  // ================= WRITE ADDRESS CHANNEL =================
  rand bit [`ADDR_WIDTH-1:0]   AWADDR;
  rand bit [2:0]               AWPROT;
  rand bit                     AWVALID;
  logic                        AWREADY;

  // ================= WRITE DATA CHANNEL =================
  rand bit [`DATA_WIDTH-1:0]   WDATA;
  rand bit [3:0]               WSTRB;
  rand bit                     WVALID;
  logic                        WREADY;

  // ================= WRITE RESPONSE CHANNEL =================
  logic [1:0]                  BRESP;
  logic                        BVALID;
  rand bit                     BREADY;

  // ================= READ ADDRESS CHANNEL =================
  rand bit [`ADDR_WIDTH-1:0]   ARADDR;
  rand bit [2:0]               ARPROT;
  rand bit                     ARVALID;
  logic                        ARREADY;

  // ================= READ DATA CHANNEL =================
  logic [`DATA_WIDTH-1:0]      RDATA;
  logic [1:0]                  RRESP;
  logic                        RVALID;
  rand bit                     RREADY;

  // ================= EXTERNAL INTERRUPT =================
  rand bit                     EXT_IRQ_IN;

  // ================= OUTPUTS =================
  logic [3:0]                  LED;
  logic [6:0]                  SEG_CATHODE;
  logic [3:0]                  SEG_ANODE;
  logic                        IRQ_OUT;


  `uvm_object_utils_begin(axi4_seq_item)

    `uvm_field_int(AWADDR, UVM_ALL_ON)
    `uvm_field_int(AWPROT, UVM_ALL_ON)
    `uvm_field_int(AWVALID, UVM_ALL_ON)
    `uvm_field_int(AWREADY, UVM_ALL_ON)

    `uvm_field_int(WDATA, UVM_ALL_ON)
    `uvm_field_int(WSTRB, UVM_ALL_ON)
    `uvm_field_int(WVALID, UVM_ALL_ON)
    `uvm_field_int(WREADY, UVM_ALL_ON)

    `uvm_field_int(BRESP, UVM_ALL_ON)
    `uvm_field_int(BVALID, UVM_ALL_ON)
    `uvm_field_int(BREADY, UVM_ALL_ON)

    `uvm_field_int(ARADDR, UVM_ALL_ON)
    `uvm_field_int(ARPROT, UVM_ALL_ON)
    `uvm_field_int(ARVALID, UVM_ALL_ON)
    `uvm_field_int(ARREADY, UVM_ALL_ON)

    `uvm_field_int(RDATA, UVM_ALL_ON)
    `uvm_field_int(RRESP, UVM_ALL_ON)
    `uvm_field_int(RVALID, UVM_ALL_ON)
    `uvm_field_int(RREADY, UVM_ALL_ON)

    `uvm_field_int(EXT_IRQ_IN, UVM_ALL_ON)

    `uvm_field_int(LED, UVM_ALL_ON)
    `uvm_field_int(SEG_CATHODE, UVM_ALL_ON)
    `uvm_field_int(SEG_ANODE, UVM_ALL_ON)
    `uvm_field_int(IRQ_OUT, UVM_ALL_ON)

  `uvm_object_utils_end


  function new(string name = "");
    super.new(name);
  endfunction

endclass
