
class axi4_monitor extends uvm_monitor;
  `uvm_component_utils(axi4_monitor)

  virtual inf vif;
  uvm_analysis_port #(axi4_seq_item) mon_port;
  axi4_seq_item txn;

  function new(string name="axi4_monitor",
               uvm_component parent=null);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    mon_port = new("mon_port", this);

    if (!uvm_config_db#(virtual inf)::get(this,"","vif",vif))
      `uvm_fatal("MON","No virtual interface")
  endfunction


  task run_phase(uvm_phase phase);
    repeat(3) @(vif.mon_cb);

    forever begin
      @(vif.mon_cb);

      txn = axi4_seq_item::type_id::create("txn");

      // WRITE ADDRESS
      txn.S_AWADDR  = vif.S_AWADDR;
      txn.S_AWVALID = vif.S_AWVALID;
      txn.S_AWREADY = vif.S_AWREADY;

      // WRITE DATA
      txn.S_WDATA   = vif.S_WDATA;
      txn.S_WSTRB   = vif.S_WSTRB;
      txn.S_WVALID  = vif.S_WVALID;
      txn.S_WREADY  = vif.S_WREADY;

      // WRITE RESPONSE
      txn.S_BVALID  = vif.S_BVALID;
      txn.S_BREADY  = vif.S_BREADY;
      txn.S_BRESP   = vif.S_BRESP;

      // READ ADDRESS
      txn.S_ARADDR  = vif.S_ARADDR;
      txn.S_ARVALID = vif.S_ARVALID;
      txn.S_ARREADY = vif.S_ARREADY;

      // READ DATA
      txn.S_RDATA   = vif.S_RDATA;
      txn.S_RVALID  = vif.S_RVALID;
      txn.S_RREADY  = vif.S_RREADY;
      txn.S_RRESP   = vif.S_RRESP;

      // OUTPUTS
      txn.LED_OUT      = vif.LED_OUT;
      txn.SEVENSEG_OUT = vif.SEVENSEG_OUT;
      txn.IRQ_OUT      = vif.IRQ_OUT;

      `uvm_info("MON",
                $sformatf("AWVALID=%0b|AWDDR =%0h| AWREADY=%0b| WVALID=%0b| WREADY=%0b| WDATA=%0h| BVALID=%0b| BRREADY=%0b| BRESP=%0b| ARVAVLID=%0b|ARADD=%0h| ARREADY=%0b| RVVALID=%0b |RREADY=%0b |RDATA=%0h",
          txn.S_AWVALID,
          txn.S_AWADDR,                
          txn.S_AWREADY,
          txn.S_WVALID,
          txn.S_WREADY,
          txn.S_WDATA,
          txn.S_BVALID,
          txn.S_BREADY,
          txn.S_BRESP,
          txn.S_ARVALID,
          txn.S_ARADDR,
          txn.S_ARREADY,
          txn.S_RVALID,
          txn.S_RREADY,
          txn.S_RDATA),
           UVM_LOW);
      //$display("time:",$time);
      //txn.print();

      mon_port.write(txn);

    end
  endtask

endclass
