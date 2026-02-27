class axi4_seq_item extends uvm_sequence_item;
  // ================= GLOBAL SIGNALS =================
	logic ARESETn;

  // ================= WRITE ADDRESS =================
  rand bit [`ADDR_WIDTH-1:0]            AWADDR;
  rand bit [2:0]                        AWPROT;
  rand bit                              AWVALID;
  bit                                   AWREADY;

  // ================= WRITE DATA =================
  rand bit [`DATA_WIDTH-1:0]            WDATA;
  rand bit [3:0]                        WSTRB;
  rand bit                              WVALID;
  bit                                    WREADY;

  // ================= WRITE RESPONSE =================
  bit [1:0]                             BRESP;
  bit                                   BVALID;
  rand bit                              BREADY;

  // ================= READ ADDRESS =================
  rand bit [`ADDR_WIDTH-1:0]            ARADDR;
  rand bit [2:0]                        ARPROT;
  rand bit                              ARVALID;
  bit                                   ARREADY;

  // ================= READ DATA =================
  bit [`DATA_WIDTH-1:0]                 RDATA;
  bit [1:0]                             RRESP;
  bit                                   RVALID;
  rand bit                              RREADY;

  // ================= EXTERNAL INTERRUPT =================
  rand bit                              ext_irq_in;

  // ================= OUTPUTS =================
  bit [7:0]                             leds;
  bit [6:0]                             seg_cathode;
  bit [3:0]                             seg_anode;
  bit                                   irq_out;


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

    `uvm_field_int(ext_irq_in, UVM_ALL_ON)

    `uvm_field_int(leds, UVM_ALL_ON)
    `uvm_field_int(seg_cathode, UVM_ALL_ON)
    `uvm_field_int(seg_anode, UVM_ALL_ON)
    `uvm_field_int(irq_out, UVM_ALL_ON)

  `uvm_object_utils_end


  function new(string name = "");
    super.new(name);
  endfunction

endclass
