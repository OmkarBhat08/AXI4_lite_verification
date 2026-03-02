class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard)

  uvm_tlm_analysis_fifo #(axi4_seq_item) mon_fifo;
  axi4_seq_item txn;

  virtual inf vif;
  
  bit [31:0] led_reg;
  bit [31:0] sevenseg_reg;
  bit [31:0]irq_status_reg;
  bit [7:0]  led_prev;

 
  bit [31:0] wr_addr_q;
  bit [31:0] wr_data_q;
  bit [3:0]  wr_strb_q;
  bit        wr_addr_valid;
  bit        wr_data_valid;

  bit [31:0] rd_addr_q;
  bit        rd_addr_valid;


  int pass_count;
  int fail_count;


  function new(string name="axi4_scoreboard",
               uvm_component parent);
    super.new(name,parent);
    mon_fifo = new("mon_fifo", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     if(!uvm_config_db#(virtual inf)::get(this,"","vif",vif))
    `uvm_fatal("SB","VIF not set in scoreboard")

    pass_count = 0;
    fail_count = 0;
  endfunction

  
  function void reset_model();
    led_reg        = 0;
    sevenseg_reg   = 0;
    irq_status_reg = 0;
    led_prev       = 0;

    wr_addr_valid  = 0;
    wr_data_valid  = 0;
    rd_addr_valid  = 0;
  endfunction


 task run_phase(uvm_phase phase);

  reset_model();
 
  forever begin
    mon_fifo.get(txn);


    // RESET 
   
   if(!vif.ARESETn) begin
      reset_model();
      check_reset(txn);
    end

    //normal axi logic
 
    else begin

      
// WRITE ADDRESS
if(txn.S_AWVALID && txn.S_AWREADY) begin
  wr_addr_q     = txn.S_AWADDR;
  wr_addr_valid = 1;
end

// WRITE DATA
if(txn.S_WVALID && txn.S_WREADY) begin
  wr_data_q     = txn.S_WDATA;
  wr_strb_q     = txn.S_WSTRB;
  wr_data_valid = 1;
end

// WRITE rsp
if(txn.S_BVALID && txn.S_BREADY) begin

  if(txn.S_BRESP != 2'b00) begin
    fail_count++;
    `uvm_error("WRITE_FAIL_BRESP",
      $sformatf("BRESP error: %0b", txn.S_BRESP));
  end
  else if(wr_addr_valid && wr_data_valid) begin
    update_model(wr_addr_q, wr_data_q, wr_strb_q);
    check_write(txn);
  end

  wr_addr_valid = 0;
  wr_data_valid = 0;
end

    
      // READ ADDRESS
      
      if(txn.S_ARVALID && txn.S_ARREADY) begin
        rd_addr_q     = txn.S_ARADDR;
        rd_addr_valid = 1;
      end

      
      // READ COMPLETE
   
      if(txn.S_RVALID && txn.S_RREADY) begin

        if(txn.S_RRESP != 2'b00) begin
          fail_count++;
          `uvm_error("READ_FAIL",
            $sformatf("READ | ADDR=%08h | RRESP ERROR | RRESP=%02b",
                      rd_addr_q, txn.S_RRESP));
        end
        else if(rd_addr_valid) begin
          check_read(rd_addr_q, txn.S_RDATA, txn);
        end
        rd_addr_valid = 0;
      end

    end // end of normal logic

  end // forever

endtask


  // RESET CHECK

  function void check_reset(axi4_seq_item txn);

    if(txn.LED_OUT==0 &&
       txn.SEVENSEG_OUT==0 &&
       txn.IRQ_OUT==0) begin

      pass_count++;
      `uvm_info("RESET_PASS",
                $sformatf("RESET | LED=%0h SEG=%0h IRQ=%0b",
                  txn.LED_OUT,
                  txn.SEVENSEG_OUT,
                  txn.IRQ_OUT),
        UVM_LOW);
    end
    else begin
      fail_count++;
      `uvm_error("RESET_FAIL",
                 $sformatf("RESET | LED=%0h SEG=%0h IRQ=%0b",
                  txn.LED_OUT,
                  txn.SEVENSEG_OUT,
                  txn.IRQ_OUT));
    end

  endfunction


  // UPDATE MODEL
 
  function void update_model(bit [31:0] addr,
                             bit [31:0] data,
                             bit [3:0]  wstrb);

    case(addr)

      32'h0: begin
  led_prev = led_reg[7:0];

  if(wstrb[0])
    led_reg[7:0] = data[7:0];

  if(wstrb[1])
    led_reg[15:8] = data[15:8];

  if(wstrb[2])
    led_reg[23:16] = data[23:16];

  if(wstrb[3])
    led_reg[31:24] = data[31:24];

  if(led_reg==8'hFF &&
     led_prev!=8'hFF)
    irq_status_reg[0]=1;
end

      32'h4: begin
        if(wstrb[0])
          sevenseg_reg[7:0]= data[7:0];

  if(wstrb[1])
    sevenseg_reg[15:8]= data[15:8];

  if(wstrb[2])
    sevenseg_reg[23:16] = data[23:16];

  if(wstrb[3])
    sevenseg_reg[31:24] = data[31:24];
      end

      32'h8: begin
        if(data[0])
          irq_status_reg[0]=0; // W1C
      end

    endcase

  endfunction


  
  // WRITE CHECK

  function void check_write(axi4_seq_item txn);

    bit [31:0] expected;
    bit [31:0] actual;

    case(wr_addr_q)

      32'h0: begin
        expected = led_reg[7:0];
        actual   =  txn.LED_OUT;
      end

      32'h4: begin
        expected = sevenseg_reg;
        actual   = txn.SEVENSEG_OUT;
      end

      32'h8: begin
        expected = irq_status_reg;
        actual   = {31'h0, txn.IRQ_OUT};
      end

      default: begin
        expected = 0;
        actual   = 0;
      end

    endcase

    if(actual === expected) begin
      pass_count++;
      `uvm_info("WRITE_PASS",
        $sformatf(
        "WRITE | AWVALID =%0h| AWREADY =%0h|ADDR=%0h |WVALID=%0h | WREADY=%0h| WDATA=%0h | WSTRB=%0b |BRESP=%0b | Exp=%0h Got=%08h | LED=%0h SEG=%0h IRQ=%0b",
           txn.S_AWVALID,
        txn.S_AWVALID,  
        wr_addr_q,
        txn.S_WVALID,
        txn.S_WREADY,  
        wr_data_q,
        wr_strb_q,
        txn.S_BRESP,
        expected,
        actual,
        txn.LED_OUT,
        txn.SEVENSEG_OUT,
        txn.IRQ_OUT),
        UVM_LOW);
    end
    else begin
      fail_count++;
      `uvm_error("WRITE_FAIL",
        $sformatf(
        "WRITE | AWVALID =%0h| AWREADY =%0h|ADDR=%0h |WVALID=%0h | WREADY=%0h| WDATA=%0h | WSTRB=%0b |BRESP=%0b | Exp=%0h Got=%08h | LED=%0h SEG=%0h IRQ=%0b",
        txn.S_AWVALID,
        txn.S_AWVALID,  
        wr_addr_q,
        txn.S_WVALID,
        txn.S_WREADY,  
        wr_data_q,
        wr_strb_q,
        txn.S_BRESP,
        expected,
        actual,
        txn.LED_OUT,
        txn.SEVENSEG_OUT,
        txn.IRQ_OUT));
    end

  endfunction



  // READ CHECK
 
  function void check_read(bit [31:0] addr,
                           bit [31:0] rdata,
                           axi4_seq_item txn);

    bit [31:0] expected;

    case(addr)
      32'h0: expected = led_reg;
      32'h4: expected = sevenseg_reg;
      32'h8: expected = irq_status_reg;
      default: expected =32'hDEADBEEF;
    endcase

    if(rdata === expected) begin
      pass_count++;
      `uvm_info("READ_PASS",
        $sformatf(
          "READ | ARDDR=%0h|ARVALID=%0b |ARREADY=%0b|RRAVLID=%0b|RREADY=%0b| RDATA=%0h | RRESP=%0b | Exp=%0h Got=%0h | LED=%0h SEG=%0h IRQ=%0b",
        addr,
          txn.S_ARVALID,
          txn.S_ARREADY,
          txn.S_RVALID,
          txn.S_RREADY,
        rdata,
        txn.S_RRESP,
        expected,
        rdata,
        txn.LED_OUT,
        txn.SEVENSEG_OUT,
        txn.IRQ_OUT),
        UVM_LOW);
    end
    else begin
      fail_count++;
      `uvm_error("READ_FAIL",
        $sformatf(
                 "READ | ARDDR=%0h|ARVALID=%0b |ARREADY=%0b|RRAVLID=%0b|RREADY=%0b| RDATA=%0h | RRESP=%0b | Exp=%0h Got=%0h | LED=%0h SEG=%0h IRQ=%0b",
        addr,
          txn.S_ARVALID,
          txn.S_ARREADY,
          txn.S_RVALID,
          txn.S_RREADY,
        rdata,
        txn.S_RRESP,
        expected,
        rdata,
        txn.LED_OUT,
        txn.SEVENSEG_OUT,
        txn.IRQ_OUT));
    end

  endfunction


  
  function void report_phase(uvm_phase phase);

    `uvm_info("SUMMARY",
      $sformatf("TOTAL PASS = %0d | TOTAL FAIL = %0d",
                pass_count, fail_count),
      UVM_NONE);

  endfunction

endclass
