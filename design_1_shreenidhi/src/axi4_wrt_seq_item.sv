class axi4_wrt_seq_item extends uvm_sequence_item;

  rand bit [ADDR_WIDTH-1:0] S_AWADDR;
  rand bit        S_AWVALID;
  rand bit        S_AWREADY;

  rand bit [DATA_WIDTH:0] S_WDATA;
  rand bit [3:0]  S_WSTRB;
  rand bit        S_WVALID;
  rand bit        S_WREADY;

  rand bit        S_BREADY;

  logic           S_BVALID;
  logic [1:0]     S_BRESP;

  logic [7:0]     LED_OUT;
  logic [7:0]     SEVENSEG_OUT;
  logic           IRQ_OUT;

  `uvm_object_utils_begin(axi4_wrt_seq_item)

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

    `uvm_field_int(LED_OUT, UVM_ALL_ON)
    `uvm_field_int(SEVENSEG_OUT, UVM_ALL_ON)
    `uvm_field_int(IRQ_OUT, UVM_ALL_ON)

  `uvm_object_utils_end

  function new(string name = "");
    super.new(name);
  endfunction

endclass

