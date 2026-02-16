class axi_rd_seq_item extends uvm_sequence_item;

  rand bit [ADDR_WIDTH-1:0] S_ARADDR;
  rand bit        S_ARVALID;
  rand bit        S_ARREADY;

  rand bit        S_RREADY;

  logic [DATA_WIDTH-1:0]    S_RDATA;
  logic           S_RVALID;
  logic [1:0]     S_RRESP;

  logic [7:0]     LED_OUT;
  logic [7:0]     SEVENSEG_OUT;
  logic           IRQ_OUT;

  `uvm_object_utils_begin(rd_seq_item)

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

  function new(string name = "rd_seq_item");
    super.new(name);
  endfunction

endclass

