class axi4_seq_item extends uvm_sequence_item;

	// ================= GLOBAL SIGNAL =========================
	bit ARESETn; 

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
 
  // Corrected do_print implementation
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);

    // Syntax: printer.print_field(name, value, size, radix);
    
    // --- Global ---
    printer.print_field("ARESETn",     ARESETn,     1,           UVM_BIN);

    // --- Write Address Channel ---
    printer.print_field("AWADDR",      AWADDR,      `ADDR_WIDTH, UVM_HEX);
    printer.print_field("AWPROT",      AWPROT,      3,           UVM_BIN);
    printer.print_field("AWVALID",     AWVALID,     1,           UVM_BIN);
    printer.print_field("AWREADY",     AWREADY,     1,           UVM_BIN);

    // --- Write Data Channel ---
    printer.print_field("WDATA",       WDATA,       `DATA_WIDTH, UVM_HEX);
    printer.print_field("WSTRB",       WSTRB,       4,           UVM_HEX);
    printer.print_field("WVALID",      WVALID,      1,           UVM_BIN);
    printer.print_field("WREADY",      WREADY,      1,           UVM_BIN);

    // --- Write Response Channel ---
    printer.print_field("BRESP",       BRESP,       2,           UVM_HEX);
    printer.print_field("BVALID",      BVALID,      1,           UVM_BIN);
    printer.print_field("BREADY",      BREADY,      1,           UVM_BIN);

    // --- Read Address Channel ---
    printer.print_field("ARADDR",      ARADDR,      `ADDR_WIDTH, UVM_HEX);
    printer.print_field("ARPROT",      ARPROT,      3,           UVM_BIN);
    printer.print_field("ARVALID",     ARVALID,     1,           UVM_BIN);
    printer.print_field("ARREADY",     ARREADY,     1,           UVM_BIN);

    // --- Read Data Channel ---
    printer.print_field("RDATA",       RDATA,       `DATA_WIDTH, UVM_HEX);
    printer.print_field("RRESP",       RRESP,       2,           UVM_HEX);
    printer.print_field("RVALID",      RVALID,      1,           UVM_BIN);
    printer.print_field("RREADY",      RREADY,      1,           UVM_BIN);

    // --- Others ---
    printer.print_field("EXT_IRQ_IN",  EXT_IRQ_IN,  1,           UVM_BIN);
    printer.print_field("LED",         LED,         4,           UVM_HEX);
    printer.print_field("SEG_CATHODE", SEG_CATHODE, 7,           UVM_HEX);
    printer.print_field("SEG_ANODE",   SEG_ANODE,   4,           UVM_HEX);
    printer.print_field("IRQ_OUT",     IRQ_OUT,     1,           UVM_BIN);
    
  endfunction
 
  virtual function string convert2string();
    string s;
    s = $sformatf("\n[AXI4_ITEM] AWADDR:%0h WDATA:%0h BRESP:%0h | ARADDR:%0h RDATA:%0h RRESP:%0h", 
                  AWADDR, WDATA, BRESP, ARADDR, RDATA, RRESP);
    return s;
  endfunction
endclass
