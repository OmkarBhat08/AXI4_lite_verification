class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard)

  uvm_tlm_analysis_fifo #(axi4_seq_item) item_fifo;

  // Internal register reference model
  bit [31:0] reg_led = 32'h0;
  bit [31:0] reg_seg = 32'h0;
  bit [31:0] reg_irq = 32'h0;

  bit        aw_rcvd, w_rcvd;
  bit [31:0] curr_awaddr;
  bit [31:0] curr_wdata;
  bit [3:0]  curr_wstrb;
  bit [31:0] curr_araddr;

  int outstanding_writes = 0;
  int outstanding_reads  = 0;

  bit [3:0]  prev_led = 4'hX;

  bit first_txn = 1'b1;
  
  bit prev_AWVALID, prev_AWREADY;
  bit [31:0] prev_AWADDR;
  
  bit prev_WVALID, prev_WREADY;
  bit [31:0] prev_WDATA;
  bit [3:0]  prev_WSTRB;
  
  bit prev_BVALID, prev_BREADY;
  bit [1:0]  prev_BRESP;
  
  bit prev_ARVALID, prev_ARREADY;
  bit [31:0] prev_ARADDR;
  
  bit prev_RVALID, prev_RREADY;
  bit [31:0] prev_RDATA;
  bit [1:0]  prev_RRESP;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    item_fifo = new("item_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_seq_item txn;
    super.run_phase(phase);

    `uvm_info("SCB_INIT", "Scoreboard Run Phase Started. AXI Protocol Checks Active.", UVM_LOW)

    forever begin
      item_fifo.get(txn);
      
      check_axi_protocol(txn);
      process_transaction(txn);
      save_previous_state(txn);

    end
  endtask

  // Protocol Check
  function void check_axi_protocol(axi4_seq_item txn);
    if(first_txn) begin
      first_txn = 1'b0;
      return; 
    end

    if(prev_AWVALID && !prev_AWREADY) begin
      if(!txn.AWVALID) 
        `uvm_error("AXI_PROT_ERR", "AWVALID deasserted before AWREADY was high!")
      if(txn.AWADDR !== prev_AWADDR) 
        `uvm_error("AXI_PROT_ERR", "AWADDR changed while AWVALID high and waiting for AWREADY!")
    end

    if(prev_WVALID && !prev_WREADY) begin
      if(!txn.WVALID) 
        `uvm_error("AXI_PROT_ERR", "WVALID deasserted before WREADY was high!")
      if(txn.WDATA !== prev_WDATA || txn.WSTRB !== prev_WSTRB) 
        `uvm_error("AXI_PROT_ERR", "WDATA/WSTRB changed while WVALID high and waiting for WREADY!")
    end

    if(prev_BVALID && !prev_BREADY) begin
      if(!txn.BVALID) 
        `uvm_error("AXI_PROT_ERR", "BVALID deasserted before BREADY was high!")
      if(txn.BRESP !== prev_BRESP) 
        `uvm_error("AXI_PROT_ERR", "BRESP changed while BVALID high and waiting for BREADY!")
    end

    if(prev_ARVALID && !prev_ARREADY) begin
      if(!txn.ARVALID) 
        `uvm_error("AXI_PROT_ERR", "ARVALID deasserted before ARREADY was high!")
      if(txn.ARADDR !== prev_ARADDR) 
        `uvm_error("AXI_PROT_ERR", "ARADDR changed while ARVALID high and waiting for ARREADY!")
    end

    if(prev_RVALID && !prev_RREADY) begin
      if(!txn.RVALID) 
        `uvm_error("AXI_PROT_ERR", "RVALID deasserted before RREADY was high!")
      if(txn.RDATA !== prev_RDATA || txn.RRESP !== prev_RRESP) 
        `uvm_error("AXI_PROT_ERR", "RDATA/RRESP changed while RVALID high and waiting for RREADY!")
    end

    if(txn.BVALID && outstanding_writes == 0 && !prev_BVALID) begin
      `uvm_error("AXI_PROT_ERR", "DUT asserted BVALID but there is no outstanding completed Write Address and Data Transaction!")
    end

    if(txn.RVALID && outstanding_reads == 0 && !prev_RVALID) begin
      `uvm_error("AXI_PROT_ERR", "DUT asserted RVALID but there is no outstanding Read Address Transaction!")
    end

    if(txn.BVALID) begin
      if(txn.BRESP !== 2'b00) begin
        `uvm_error("AXI_RESP_ERR", $sformatf("Write Response is not OKAY. Expected: 00, Actual: %0b", txn.BRESP))
      end
    end

    if(txn.RVALID) begin
      if(txn.RRESP !== 2'b00) begin
        `uvm_error("AXI_RESP_ERR", $sformatf("Read Response is not OKAY. Expected: 00, Actual: %0b", txn.RRESP))
      end
    end
  endfunction

  task process_transaction(axi4_seq_item txn);
    
    if(txn.AWVALID && txn.AWREADY) begin
      curr_awaddr = txn.AWADDR;
      aw_rcvd     = 1'b1;
    end

    if(txn.WVALID && txn.WREADY) begin
      curr_wdata = txn.WDATA;
      curr_wstrb = txn.WSTRB;
      w_rcvd     = 1'b1;
    end

    if(aw_rcvd && w_rcvd) begin
      outstanding_writes++;
      update_register_model();
      aw_rcvd = 1'b0; 
      w_rcvd  = 1'b0;
    end

    if(txn.BVALID && txn.BREADY) begin
      if(outstanding_writes > 0) outstanding_writes--;
    end

    if(txn.ARVALID && txn.ARREADY) begin
      curr_araddr = txn.ARADDR;
      outstanding_reads++;
    end

    if(txn.RVALID && txn.RREADY) begin
      if(outstanding_reads > 0) begin
        check_read_data(txn.RDATA);
        outstanding_reads--;
      end
    end

    if(txn.LED !== reg_led[3:0]) begin
      `uvm_error("SCB_LED_FAIL", $sformatf("DUT STATE MISMATCH! Physical LED: %0h | Expected (Reg): %0h", txn.LED, reg_led[3:0]))
    end else if(txn.LED !== prev_led) begin
      `uvm_info("SCB_LED_PASS", $sformatf("DUT STATE MATCH. Physical LED updated: %0h", txn.LED), UVM_LOW)
      prev_led = txn.LED;
    end
  endtask

  function void update_register_model();
    bit [31:0] target_reg;
    bit [31:0] updated_data;

    case (curr_awaddr)
      'h00: target_reg = reg_led;
      'h04: target_reg = reg_seg;
      'h08: target_reg = reg_irq;
      default: target_reg = 32'h0;
    endcase

    updated_data[7:0]   = curr_wstrb[0] ? curr_wdata[7:0]   : target_reg[7:0];
    updated_data[15:8]  = curr_wstrb[1] ? curr_wdata[15:8]  : target_reg[15:8];
    updated_data[23:16] = curr_wstrb[2] ? curr_wdata[23:16] : target_reg[23:16];
    updated_data[31:24] = curr_wstrb[3] ? curr_wdata[31:24] : target_reg[31:24];

    case (curr_awaddr)
      'h00: begin 
						  `uvm_info("SCB_REG", $sformatf("LED_REG <- 'h%0h", updated_data), UVM_LOW); 
					  	reg_led = updated_data;
					  end
      'h04: begin 
						  `uvm_info("SCB_REG", $sformatf("SEG_REG <- 'h%0h", updated_data), UVM_LOW);
						  reg_seg = updated_data;
						end
      'h08: if(curr_wstrb[0] && curr_wdata[0]) 
						  reg_irq[0] = 1'b0; 
    endcase
  endfunction

  function void check_read_data(logic [31:0] actual_rdata);
    bit [31:0] expected_rdata;
    case (curr_araddr)
      'h00: expected_rdata = reg_led;
      'h04: expected_rdata = reg_seg;
      'h08: expected_rdata = reg_irq;
      default: expected_rdata = 32'h0;
    endcase

    if(actual_rdata !== expected_rdata)
      `uvm_error("SCB_READ_FAIL", $sformatf("Read FAILED: Addr: 'h%0h | Exp: 'h%0h | Act: 'h%0h", curr_araddr, expected_rdata, actual_rdata))
    else
      `uvm_info("SCB_READ_PASS", $sformatf("Read PASSED: Addr: 'h%0h | Data: 'h%0h", curr_araddr, actual_rdata), UVM_LOW)
  endfunction

  function void save_previous_state(axi4_seq_item txn);
    prev_AWVALID = txn.AWVALID; prev_AWREADY = txn.AWREADY; prev_AWADDR  = txn.AWADDR;
    prev_WVALID  = txn.WVALID;  prev_WREADY  = txn.WREADY;  prev_WDATA   = txn.WDATA; prev_WSTRB = txn.WSTRB;
    prev_BVALID  = txn.BVALID;  prev_BREADY  = txn.BREADY;  prev_BRESP   = txn.BRESP;
    prev_ARVALID = txn.ARVALID; prev_ARREADY = txn.ARREADY; prev_ARADDR  = txn.ARADDR;
    prev_RVALID  = txn.RVALID;  prev_RREADY  = txn.RREADY;  prev_RDATA   = txn.RDATA; prev_RRESP = txn.RRESP;
  endfunction

endclass
