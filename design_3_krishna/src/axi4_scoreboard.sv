class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard)

  uvm_tlm_analysis_fifo #(axi4_seq_item) item_fifo;

  bit [31:0] reg_led = 32'h0;
  bit [31:0] reg_seg = 32'h0;
  bit [31:0] reg_irq = 32'h0;

  bit [31:0] reg_led_arr [5];
  bit [31:0] reg_seg_arr [5];
  bit [31:0] reg_irq_arr [5];

  bit aw_rcvd, w_rcvd;
  bit [31:0] curr_awaddr;
  bit [31:0] curr_wdata;
  bit [3:0]  curr_wstrb;
  bit [31:0] curr_araddr;

  int writes = 0;
  int reads = 0;

  bit first_txn = 1'b1;
  bit prev_BVALID, prev_BREADY;
  bit [1:0] prev_BRESP;
  bit prev_RVALID, prev_RREADY;
  bit [31:0] prev_RDATA;
  bit [1:0]  prev_RRESP;

  int seg_counter = 0;
  bit [1:0] seg_digit_sel = 2'b00;
  bit [3:0] exp_led = 4'h0;
  bit [3:0] prev_led = 4'hX;

  int debounce_counter = 0;
  bit [1:0] ext_irq_sync = 2'b00;
  bit ext_irq_stable = 1'b0;
  bit ext_irq_d1 = 1'b0;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
    item_fifo = new("item_fifo", this);
  endfunction

  task run_phase(uvm_phase phase);
    axi4_seq_item txn;
    super.run_phase(phase);

    forever begin
      item_fifo.get(txn);

      if(txn.ARESETn === 1'b0) begin
        handle_reset();
        store_prev_val(txn);
        continue;
      end

      check_slave_axi_protocol(txn); 
      process_axi_transaction(txn); 
      update_arrlines();          
      update_peripheral_timers(txn);
      check_peripherals(txn);      
      store_prev_val(txn);        
    end
  endtask

  function void handle_reset();
    `uvm_info("SCB_RESET", "Active-low reset detected! Clearing all internal states and reference models.", UVM_LOW)
    reg_led = 32'h0;
    reg_seg = 32'h0;
    reg_irq = 32'h0;

    foreach(reg_led_arr[i]) reg_led_arr[i] = 32'h0;
    foreach(reg_seg_arr[i]) reg_seg_arr[i] = 32'h0;
    foreach(reg_irq_arr[i]) reg_irq_arr[i] = 32'h0;

    aw_rcvd = 1'b0;
    w_rcvd = 1'b0;
    curr_awaddr = 32'h0;
    curr_wdata = 32'h0;
    curr_wstrb = 4'h0;
    curr_araddr = 32'h0;

    writes = 0;
    reads = 0;

    first_txn = 1'b1;

    seg_counter = 0;
    seg_digit_sel = 2'b00;
    exp_led = 4'h0;
    prev_led = 4'hX;

    debounce_counter = 0;
    ext_irq_sync = 2'b00;
    ext_irq_stable = 1'b0;
    ext_irq_d1 = 1'b0;
  endfunction

  function void update_arrlines();
    for (int i = 4; i > 0; i--) begin
      reg_led_arr[i] = reg_led_arr[i-1];
      reg_seg_arr[i] = reg_seg_arr[i-1];
      reg_irq_arr[i] = reg_irq_arr[i-1];
    end
    reg_led_arr[0] = reg_led;
    reg_seg_arr[0] = reg_seg;
    reg_irq_arr[0] = reg_irq;
  endfunction

  function void check_peripherals(axi4_seq_item txn);
    bit [3:0] current_digit;
    bit [6:0] exp_cathode;
    bit [3:0] exp_anode;

    if(txn.LED !== exp_led) begin
      `uvm_error("SCB_LED_FAIL", $sformatf("LED Mismatch! Expected: 'h%0h | Actual: 'h%0h", exp_led, txn.LED))
    end
    else if(txn.LED !== prev_led) begin
      `uvm_info("SCB_LED_PASS", $sformatf("LED Output updated: 'h%0h", txn.LED), UVM_LOW)
      prev_led = txn.LED;
    end

    case(seg_digit_sel)
      2'b00: current_digit = reg_seg_arr[3][3:0];
      2'b01: current_digit = reg_seg_arr[3][7:4];
      2'b10: current_digit = reg_seg_arr[3][11:8];
      2'b11: current_digit = reg_seg_arr[3][15:12];
    endcase

    case(current_digit)
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

    case(seg_digit_sel)
      2'b00: exp_anode = 4'b1110;
      2'b01: exp_anode = 4'b1101;
      2'b10: exp_anode = 4'b1011;
      2'b11: exp_anode = 4'b0111;
    endcase

    if(txn.SEG_CATHODE !== exp_cathode) begin
      `uvm_error("SCB_SEG_CATHODE_FAIL", $sformatf("Cathode Mismatch! Digit: 'h%0h | Expected: 'h%0h | Actual: 'h%0h", current_digit, exp_cathode, txn.SEG_CATHODE))
    end

    if(txn.SEG_ANODE !== exp_anode) begin
      `uvm_error("SCB_SEG_ANODE_FAIL", $sformatf("Anode Mismatch! Expected: 'h%0h | Actual: 'h%0h", exp_anode, txn.SEG_ANODE))
    end

    if(txn.IRQ_OUT !== reg_irq_arr[3][0]) begin
      `uvm_error("SCB_IRQ_FAIL", $sformatf("IRQ_OUT Mismatch! Expected (Reg 0): 'h%0h | Actual: 'h%0h", reg_irq_arr[3][0], txn.IRQ_OUT))
    end
  endfunction

  function void update_peripheral_timers(axi4_seq_item txn);
    exp_led = reg_led_arr[4][3:0];

    if(seg_counter == `COUNTER_MAX) begin
      seg_counter = 0;
      seg_digit_sel = seg_digit_sel + 2'b01;
    end
    else begin
      seg_counter = seg_counter + 1;
    end

    ext_irq_sync = {ext_irq_sync[0], txn.EXT_IRQ_IN};

    if(ext_irq_sync[1] == ext_irq_stable) begin
      debounce_counter = 0;
    end
    else begin
      if(debounce_counter == `IRQ_COUNTER_MAX) begin
        ext_irq_stable = ext_irq_sync[1];
        debounce_counter = 0;
      end
      else begin
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
      aw_rcvd = 1'b1;
    end

    if(txn.WVALID && txn.WREADY) begin
      curr_wdata = txn.WDATA;
      curr_wstrb = txn.WSTRB;
      w_rcvd = 1'b1;
    end

    if(aw_rcvd && w_rcvd) begin
      writes++;
      update_register_model();
      aw_rcvd = 1'b0;
      w_rcvd  = 1'b0;
    end

    if(txn.BVALID && txn.BREADY) begin
      if(writes > 0) writes--;
      `uvm_info("SCB_AXI_WR", "AXI Write Response Handshake Completed (BVALID & BREADY).", UVM_HIGH)
    end

    if(txn.ARVALID && txn.ARREADY) begin
      curr_araddr = txn.ARADDR;
      reads++;
    end

    if(txn.RVALID && txn.RREADY) begin
      if(reads > 0) begin
        check_read_data(txn.RDATA);
        reads--;
        `uvm_info("SCB_AXI_RD", "AXI Read Response Handshake Completed (RVALID & RREADY).", UVM_HIGH)
      end
    end
  endtask

  function void update_register_model();
    bit [31:0] target_reg;
    bit [31:0] updated_data;

    case(curr_awaddr)
      'h00: target_reg = reg_led;
      'h04: target_reg = reg_seg;
      'h08: target_reg = reg_irq;
      default: target_reg = 32'h0;
    endcase

    updated_data[7:0]   = curr_wstrb[0] ? curr_wdata[7:0]   : target_reg[7:0];
    updated_data[15:8]  = curr_wstrb[1] ? curr_wdata[15:8]  : target_reg[15:8];
    updated_data[23:16] = curr_wstrb[2] ? curr_wdata[23:16] : target_reg[23:16];
    updated_data[31:24] = curr_wstrb[3] ? curr_wdata[31:24] : target_reg[31:24];

    case(curr_awaddr)
      'h00: begin
             `uvm_info("SCB_REG_PASS", $sformatf("SUCCESSFUL WRITE: LED_REG addr : ['h%0h] updated to 'h%0h", curr_awaddr, updated_data), UVM_LOW);
             reg_led = updated_data;
            end
      'h04: begin
             `uvm_info("SCB_REG_PASS", $sformatf("SUCCESSFUL WRITE: SEG_REG addr : ['h%0h] updated to 'h%0h", curr_awaddr, updated_data), UVM_LOW);
             reg_seg = updated_data;
            end
      'h08: if(curr_wstrb[0] && curr_wdata[0]) begin
             `uvm_info("SCB_REG_PASS", "PASSFUL WRITE: IRQ_REG Write-1-to-Clear triggered! Clearing IRQ.", UVM_LOW);
             reg_irq[0] = 1'b0;
            end
      default: begin
         `uvm_warning("SCB_INV_ADDR", $sformatf("INVALID WRITE ADDRESS: Attempted to write data 'h%0h to reserved address 'h%0h", curr_wdata, curr_awaddr))
         end
    endcase
  endfunction

  function void check_read_data(logic [31:0] actual_rdata);
    bit [31:0] exp_rdata;
    case (curr_araddr)
      'h00: exp_rdata = reg_led;
      'h04: exp_rdata = reg_seg;
      'h08: exp_rdata = reg_irq;
      default: begin
          `uvm_warning("SCB_INV_ADDR", $sformatf("INVALID READ ADDRESS: Attempted to read from reserved address 'h%0h. Expecting Slave to return 0x0.", curr_araddr))
          exp_rdata = 32'h0;
         end
    endcase

    if(actual_rdata !== exp_rdata)
      `uvm_error("SCB_READ_FAIL", $sformatf("READ FAILED Addr: 'h%0h | Exp: 'h%0h | Act: 'h%0h", curr_araddr, exp_rdata, actual_rdata))
    else
      `uvm_info("SCB_READ_PASS", $sformatf("PASSFUL READ: Addr: 'h%0h matched expected data: 'h%0h", curr_araddr, actual_rdata), UVM_LOW)
  endfunction

  function void check_slave_axi_protocol(axi4_seq_item txn);
    if(first_txn) begin
      `uvm_info("SCB_FIRST_TXN", "First transaction recorded. Skipping protocol stability checks to establish a baseline.", UVM_LOW)
      first_txn = 1'b0;
      return;
    end

    if(prev_BVALID && !prev_BREADY) begin
      if(!txn.BVALID) `uvm_error("AXI_SLAVE_ERR", "Slave deasserted BVALID before master was BREADY!")
      if(txn.BRESP !== prev_BRESP) `uvm_error("AXI_SLAVE_ERR", "Slave changed BRESP while waiting for BREADY!")
    end

    if(prev_RVALID && !prev_RREADY) begin
      if(!txn.RVALID) `uvm_error("AXI_SLAVE_ERR", "Slave deasserted RVALID before master was RREADY!")
      if(txn.RDATA !== prev_RDATA || txn.RRESP !== prev_RRESP) `uvm_error("AXI_SLAVE_ERR", "Slave changed RDATA/RRESP while waiting for RREADY!")
    end

    if(txn.BVALID && writes == 0 && !prev_BVALID)
      `uvm_error("AXI_SLAVE_ERR", "Slave asserted BVALID without outstanding Write transaction.")

    if(txn.RVALID && reads == 0 && !prev_RVALID)
      `uvm_error("AXI_SLAVE_ERR", "Slave asserted RVALID without outstanding Read transaction.")

    if(txn.BVALID && txn.BRESP !== 2'b00)
      `uvm_error("AXI_SLAVE_ERR", "Slave Write Response is not OKAY.")

    if(txn.RVALID && txn.RRESP !== 2'b00)
      `uvm_error("AXI_SLAVE_ERR", "Slave Read Response is not OKAY.")
  endfunction

  function void store_prev_val(axi4_seq_item txn);
    prev_BVALID = txn.BVALID;
    prev_BREADY = txn.BREADY;
    prev_BRESP = txn.BRESP;
    prev_RVALID = txn.RVALID;
    prev_RREADY = txn.RREADY;
    prev_RDATA = txn.RDATA;
    prev_RRESP = txn.RRESP;
  endfunction

endclass
