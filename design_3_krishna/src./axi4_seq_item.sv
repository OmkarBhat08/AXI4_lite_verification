class axi4_seq_item extends uvm_sequence_item;

  // ================= AXI WRITE ADDRESS CHANNEL =================
  rand bit [`ADDR_WIDTH:0]   S_AXI_AWADDR;
  rand bit [2:0]   S_AXI_AWPROT;
  rand bit         S_AXI_AWVALID;
  logic            S_AXI_AWREADY;

  // ================= AXI WRITE DATA CHANNEL =================
  rand bit [`DATA_WIDTH:0]  S_AXI_WDATA;
  rand bit [3:0]   S_AXI_WSTRB;
  rand bit         S_AXI_WVALID;
  logic            S_AXI_WREADY;

  // ================= AXI WRITE RESPONSE CHANNEL =================
  logic [1:0]      S_AXI_BRESP;
  logic            S_AXI_BVALID;
  rand bit         S_AXI_BREADY;

  // ================= AXI READ ADDRESS CHANNEL =================
  rand bit [`ADDR_WIDTH:0]   S_AXI_ARADDR;
  rand bit [2:0]   S_AXI_ARPROT;
  rand bit         S_AXI_ARVALID;
  logic            S_AXI_ARREADY;

  // ================= AXI READ DATA CHANNEL =================
  logic [`DATA_WIDTH:0]     S_AXI_RDATA;
  logic [1:0]      S_AXI_RRESP;
  logic            S_AXI_RVALID;
  rand bit         S_AXI_RREADY;

  // ================= EXTERNAL OUTPUTS =================
  logic [3:0]      LED;
  logic [6:0]      SEG_CATHODE;
  logic [3:0]      SEG_ANODE;
  logic            IRQ_OUT;


  `uvm_object_utils_begin(axi_lite_slave_seq_item)

    `uvm_field_int(S_AXI_AWADDR, UVM_ALL_ON)
    `uvm_field_int(S_AXI_AWPROT, UVM_ALL_ON)
    `uvm_field_int(S_AXI_AWVALID, UVM_ALL_ON)
    `uvm_field_int(S_AXI_AWREADY, UVM_ALL_ON)

    `uvm_field_int(S_AXI_WDATA, UVM_ALL_ON)
    `uvm_field_int(S_AXI_WSTRB, UVM_ALL_ON)
    `uvm_field_int(S_AXI_WVALID, UVM_ALL_ON)
    `uvm_field_int(S_AXI_WREADY, UVM_ALL_ON)

    `uvm_field_int(S_AXI_BRESP, UVM_ALL_ON)
    `uvm_field_int(S_AXI_BVALID, UVM_ALL_ON)
    `uvm_field_int(S_AXI_BREADY, UVM_ALL_ON)

    `uvm_field_int(S_AXI_ARADDR, UVM_ALL_ON)
    `uvm_field_int(S_AXI_ARPROT, UVM_ALL_ON)
    `uvm_field_int(S_AXI_ARVALID, UVM_ALL_ON)
    `uvm_field_int(S_AXI_ARREADY, UVM_ALL_ON)

    `uvm_field_int(S_AXI_RDATA, UVM_ALL_ON)
    `uvm_field_int(S_AXI_RRESP, UVM_ALL_ON)
    `uvm_field_int(S_AXI_RVALID, UVM_ALL_ON)
    `uvm_field_int(S_AXI_RREADY, UVM_ALL_ON)

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
