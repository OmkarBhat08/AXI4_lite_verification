class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard)

  uvm_tlm_analysis_fifo #(axi4_seq_item) item_fifo;

  bit [31:0] reg_led = 32'h0;
  bit [31:0] reg_seg = 32'h0;
  bit [31:0] reg_irq = 32'h0;

  bit [31:0] curr_awaddr;
  bit [31:0] curr_wdata;
  bit [31:0] curr_araddr;
  bit [3:0] curr_wstrb;

  int outstanding_writes = 0;
  int outstanding_reads  = 0;

  bit ext_irq_stable = 1'b0;
  bit ext_irq_d1 = 1'b0;
  bit first_txn = 1'b1;
  bit aw_rcvd, w_rcvd;
  bit prev_AWVALID, prev_AWREADY; 
  bit prev_WVALID, prev_WREADY;
	bit prev_BVALID, prev_BREADY;  
	bit prev_ARVALID, prev_ARREADY; 
  bit prev_RVALID, prev_RREADY;  
	bit [31:0] prev_WDATA; 
	bit [31:0] prev_ARADDR;
	bit [31:0] prev_RDATA; 
	bit [31:0] prev_AWADDR;
	bit [3:0] prev_WSTRB;  
  bit [3:0] exp_led = 4'h0;
  bit [3:0] prev_led = 4'hX;
	bit [1:0] prev_RRESP;
	bit [1:0] prev_BRESP;
  bit [1:0] ext_irq_sync = 2'b00;
  bit [1:0] seg_digit_sel = 2'b00;

  int CLK_FREQ_HZ = 100_000_000;
  int REFRESH_RATE_HZ = 1000;
  int DEBOUNCE_MS = 20;

  int COUNTER_MAX = (CLK_FREQ_HZ / (REFRESH_RATE_HZ * 4)) - 1; // 24999
  int IRQ_COUNTER_MAX = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS - 1;// 1999999

  int seg_counter = 0;
  int debounce_counter = 0;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    item_fifo = new("item_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_seq_item txn;
    super.run_phase(phase);

    `uvm_info("SCB_INIT", "Scoreboard Run Phase Started. AXI & Peripheral Checks Active.", UVM_LOW)

    forever begin
      item_fifo.get(txn);
      
      check_axi_protocol(txn);
      process_axi_transaction(txn);
      check_peripherals(txn);
      update_peripheral_timers(txn);
      save_previous_state(txn);
    end
  endtask

  function void check_peripherals(axi4_seq_item txn);
    bit [3:0] current_digit;
    bit [6:0] exp_cathode;
    bit [3:0] exp_anode;

    if(txn.LED !== exp_led) begin
      `uvm_error("SCB_LED_FAIL", $sformatf("LED Mismatch! Expected: %0h | Actual: %0h", exp_led, txn.LED))
    end else if(txn.LED !== prev_led) begin
      `uvm_info("SCB_LED_PASS", $sformatf("LED Output updated: %0h", txn.LED), UVM_LOW)
      prev_led = txn.LED;
    end

    case (seg_digit_sel)
      2'b00: current_digit = reg_seg[3:0];
      2'b01: current_digit = reg_seg[7:4];
      2'b10: current_digit = reg_seg[11:8];
      2'b11: current_digit = reg_seg[15:12];
    endcase

    case (current_digit)
      4'h0: exp_cathode = 7'b1000000;
      4'h1: exp_cathode = 7'b1111001;
      4'h2: exp_cathode = 7'b0100100;
      4'h3: exp_cathode = 7'b0110000;
      4'h4: exp_cathode = 7'b0011001;
      4'h5: exp_cathode = 7'b0010010;
      4'h6: exp_cathode = 7'b0000010;
      4'h7: exp_cathode = 7'b1111000;
      4'h8: exp_cathode = 7'b0000000;
      4'h9: exp_cathode = 7'b0010000;
      4'hA: exp_cathode = 7'b0001000;
      4'hB: exp_cathode = 7'b0000011;
      4'hC: exp_cathode = 7'b1000110;
      4'hD: exp_cathode = 7'b0100001;
      4'hE: exp_cathode = 7'b0000110;
      4'hF: exp_cathode = 7'b0001110;
      default: exp_cathode = 7'b1111111;
    endcase

    case (seg_digit_sel)
      2'b00: exp_anode = 4'b1110;
      2'b01: exp_anode = 4'b1101;
      2'b10: exp_anode = 4'b1011;
      2'b11: exp_anode = 4'b0111;
    endcase

    if(txn.SEG_CATHODE !== exp_cathode) begin
      `uvm_error("SCB_SEG_CATHODE_FAIL", $sformatf("Cathode Mismatch! Digit: %0h | Expected: %7b | Actual: %7b", current_digit, exp_cathode, txn.SEG_CATHODE))
    end

    if(txn.SEG_ANODE !== exp_anode) begin
      `uvm_error("SCB_SEG_ANODE_FAIL", $sformatf("Anode Mismatch! Expected: %4b | Actual: %4b", exp_anode, txn.SEG_ANODE))
    end

    if(txn.IRQ_OUT !== reg_irq[0]) begin
      `uvm_error("SCB_IRQ_FAIL", $sformatf("IRQ_OUT Mismatch! Expected (Reg 0): %0b | Actual: %0b", reg_irq[0], txn.IRQ_OUT))
    end
  endfunction

  function void update_peripheral_timers(axi4_seq_item txn);
    exp_led = reg_led[3:0];

    if(seg_counter == COUNTER_MAX) begin
      seg_counter = 0;
      seg_digit_sel = seg_digit_sel + 2'b01;
    end else begin
      seg_counter = seg_counter + 1;
    end

    ext_irq_sync = {ext_irq_sync[0], txn.EXT_IRQ_IN};
    if(ext_irq_sync[1] == ext_irq_stable) begin
      debounce_counter = 0;
    end else begin
      if(debounce_counter == IRQ_COUNTER_MAX) begin
        ext_irq_stable = ext_irq_sync[1]; 
        debounce_counter = 0;
      end else begin
        debounce_counter++;
      end
    end

    ext_irq_d1 = ext_irq_stable;
    if(ext_irq_stable == 1'b1 && ext_irq_d1 == 1'b0) begin
      `uvm_info("SCB_IRQ", "Valid 20ms Button Press Edge Detected! Setting IRQ Register Bit 0.", UVM_LOW)
      reg_irq[0] = 1'b1;
    end
  endfunction

  task process_axi_transaction(axi4_seq_item txn);
    
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
      'h00: begin `uvm_info("SCB_REG", $sformatf("LED_REG <- 'h%0h", updated_data), UVM_LOW); reg_led = updated_data; end
      'h04: begin `uvm_info("SCB_REG", $sformatf("SEG_REG <- 'h%0h", updated_data), UVM_LOW); reg_seg = updated_data; end
      'h08: if(curr_wstrb[0] && curr_wdata[0]) begin
              `uvm_info("SCB_REG", "IRQ_REG Write-1-to-Clear triggered! Clearing IRQ.", UVM_LOW);
              reg_irq[0] = 1'b0; 
            end
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
      `uvm_error("SCB_READ_FAIL", $sformatf("Read FAILED! Addr: 'h%0h | Exp: 'h%0h | Act: 'h%0h", curr_araddr, expected_rdata, actual_rdata))
    else
      `uvm_info("SCB_READ_PASS", $sformatf("Read PASSED! Addr: 'h%0h | Data: 'h%0h", curr_araddr, actual_rdata), UVM_LOW)
  endfunction

  function void check_axi_protocol(axi4_seq_item txn);
    if(first_txn) begin
      first_txn = 1'b0;
      return; 
    end

    if(prev_AWVALID && !prev_AWREADY) begin
      if(!txn.AWVALID) `uvm_error("AXI_PROT_ERR", "AWVALID deasserted before AWREADY was high!")
      if(txn.AWADDR !== prev_AWADDR) `uvm_error("AXI_PROT_ERR", "AWADDR changed while waiting for AWREADY!")
    end

    if(prev_WVALID && !prev_WREADY) begin
      if(!txn.WVALID) `uvm_error("AXI_PROT_ERR", "WVALID deasserted before WREADY was high!")
      if(txn.WDATA !== prev_WDATA || txn.WSTRB !== prev_WSTRB) `uvm_error("AXI_PROT_ERR", "WDATA/WSTRB changed!")
    end

    if(prev_BVALID && !prev_BREADY) begin
      if(!txn.BVALID) `uvm_error("AXI_PROT_ERR", "BVALID deasserted before BREADY was high!")
      if(txn.BRESP !== prev_BRESP) `uvm_error("AXI_PROT_ERR", "BRESP changed while waiting for BREADY!")
    end

    if(prev_ARVALID && !prev_ARREADY) begin
      if(!txn.ARVALID) `uvm_error("AXI_PROT_ERR", "ARVALID deasserted before ARREADY was high!")
      if(txn.ARADDR !== prev_ARADDR) `uvm_error("AXI_PROT_ERR", "ARADDR changed while waiting for ARREADY!")
    end

    if(prev_RVALID && !prev_RREADY) begin
      if(!txn.RVALID) `uvm_error("AXI_PROT_ERR", "RVALID deasserted before RREADY was high!")
      if(txn.RDATA !== prev_RDATA || txn.RRESP !== prev_RRESP) `uvm_error("AXI_PROT_ERR", "RDATA/RRESP changed!")
    end

    if(txn.BVALID && outstanding_writes == 0 && !prev_BVALID) `uvm_error("AXI_PROT_ERR", "Invalid BVALID.")
    if(txn.RVALID && outstanding_reads == 0 && !prev_RVALID)  `uvm_error("AXI_PROT_ERR", "Invalid RVALID.")
    if(txn.BVALID && txn.BRESP !== 2'b00) `uvm_error("AXI_RESP_ERR", "Write Response not OKAY.")
    if(txn.RVALID && txn.RRESP !== 2'b00) `uvm_error("AXI_RESP_ERR", "Read Response not OKAY.")
  endfunction

  function void save_previous_state(axi4_seq_item txn);
    prev_AWVALID = txn.AWVALID; 
		prev_AWREADY = txn.AWREADY; 
		prev_AWADDR  = txn.AWADDR;
    prev_WVALID  = txn.WVALID;  
		prev_WREADY  = txn.WREADY;  
		prev_WDATA   = txn.WDATA; 
		prev_WSTRB = txn.WSTRB;
    prev_BVALID  = txn.BVALID;
		prev_BREADY  = txn.BREADY;  
	  prev_BRESP   = txn.BRESP;
    prev_ARVALID = txn.ARVALID; 
		prev_ARREADY = txn.ARREADY; 
		prev_ARADDR  = txn.ARADDR;
    prev_RVALID  = txn.RVALID;  
		prev_RREADY  = txn.RREADY;  
		prev_RDATA   = txn.RDATA; 
		prev_RRESP = txn.RRESP;
  endfunction

endclass
