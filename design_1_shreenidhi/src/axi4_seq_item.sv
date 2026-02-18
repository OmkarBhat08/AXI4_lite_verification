class axi4_seq_item extends uvm_sequence_item;

  // ---------------- WRITE ADDRESS CHANNEL ----------------
  rand bit [ADDR_WIDTH-1:0] S_AWADDR;
  rand bit                  S_AWVALID;
  rand bit                  S_AWREADY;

  // ---------------- WRITE DATA CHANNEL ----------------
  //INPUTS
  rand bit [DATA_WIDTH-1:0] S_WDATA;
  rand bit [3:0]            S_WSTRB;
  rand bit                  S_WVALID;
  //OUTPUS
  logic                     S_WREADY;

  // ---------------- WRITE RESPONSE CHANNEL ----------------
  //INPUTS TO SLAVE
  rand bit        S_BREADY;
  //OUTPUTS FROM MASTER
  logic           S_BVALID;
  logic [1:0]     S_BRESP;

  // ---------------- READ ADDRESS CHANNEL ----------------
  rand bit [31:0] S_ARADDR;
  rand bit        S_ARVALID;
  rand bit        S_ARREADY;

  // ---------------- READ DATA CHANNEL ----------------
  rand bit        S_RREADY;
  logic [31:0]    S_RDATA;
  logic           S_RVALID;
  logic [1:0]     S_RRESP;

  // ---------------- EXTERNAL OUTPUTS ----------------
  logic [7:0]     LED_OUT;
  logic [7:0]     SEVENSEG_OUT;
  logic           IRQ_OUT;

  `uvm_object_utils_begin(axi4_seq_item)

    `uvm_field_int(S_AWADDR, UVM_ALL_ON)
    `uvm_field_int(S_AWVALID, UVM_ALL_ON)
    `uvm_field_int(S_AWREADY, UVM_ALL_ON)

    `uvm_field_int(S_WDATA, UVM_ALL_ON)
    `uvm_field_int(S_WSTRB, UVM_ALL_ON)
    `uvm_field_int(S_WVALID, UVM_ALL_ON)
    `uvm_field_int(S_WREADY, UVM_ALL_ON)

    `uvm_field_int(S_BREADY, UVM_ALL_ON)
    `uvm_field_int(S_BVALID, UVM_ALL_ON)
    `uvm_field_int(S_BRESP, UVM_ALL_ON)

    `uvm_field_int(S_ARADDR, UVM_ALL_ON)
    `uvm_field_int(S_ARVALID, UVM_ALL_ON)
    `uvm_field_int(S_ARREADY, UVM_ALL_ON)

    `uvm_field_int(S_RREADY, UVM_ALL_ON)
    `uvm_field_int(S_RDATA, UVM_ALL_ON)
    `uvm_field_int(S_RVALID, UVM_ALL_ON)
    `uvm_field_int(S_RRESP, UVM_ALL_ON)

    `uvm_field_int(LED_OUT, UVM_ALL_ON)
    `uvm_field_int(SEVENSEG_OUT, UVM_ALL_ON)
    `uvm_field_int(IRQ_OUT, UVM_ALL_ON)

  `uvm_object_utils_end


  function new(string name = "axi4_seq_item");
    super.new(name);
  endfunction

endclass
