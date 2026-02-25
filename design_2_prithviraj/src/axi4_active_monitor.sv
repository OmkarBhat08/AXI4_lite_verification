class axi4_passive_monitor extends uvm_monitor;

  `uvm_component_utils(axi4_passive_monitor)

  virtual axi4_if.MON vif;
  uvm_analysis_port #(axi4_seq_item)a_mon_port;
  axi4_seq_item out_item;

//---------------------------------new constructor----------------------------//
  function new(string name = "axi4_passive_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

//------------------------------build phase---------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    p_mon_port = new("p_mon_port", this);

    if (!(uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)))
      `uvm_fatal("PASSIVE_MONITOR","NO VIRTUAL INTERFACE IN PASSIVE MONITOR")
  endfunction

//--------------------------run phase-----------------------------------//
  task run_phase(uvm_phase phase);
    repeat (4) @(vif.mon_cb);

    forever 
      begin

        out_item = axi4_seq_item::type_id::create("out_item");
        
        // write address channel //
        out_item.AWADDR=vif.mon_cb.AWADDR;
        out_item.AWVALID=vif.mon_cb.AWVALID;
        out_item.AWREADY=vif.mon_cb.AWREADY;
        
        // write data channel  //
        out_item.WDATA=vif.mon_cb.WDATA;
        out_item.WSTRB=vif.mon_cb.WSTRB;
        out_item.WVALID=vif.mon_cb.WVALID;
        out_item.WREADY=vif.mon_cb.WREADY;
        
        // write response channel //
        out_item.BRESP=vif.mon_cb.BRESP;
        out_item.BVALID=vif.mon_cb.BVALID;
        out_item.BREADY=vif.mon_cb.BREADY;
        
        // read address channel //
        out_item.ARADDR = vif.mon_cb.ARADDR;
        out_item.ARVALID = vif.mon_cb.ARVALID;
        out_item.ARREADY = vif.mon_cb.ARREADY;
        
        // read data channel //
        
        out_item.RDATA = vif.mon_cb.RDATA;
        out_item.RVALID = vif.mon_cb.RVALID;
        out_item.RREADY =vif.mon_cb.RREADY;
        out_item.RRESP = vif.mon_cb.RRESP;
        
        // extrnal op and inp //
        
        out_item.ext_irq_in = vif.mon_cb.ext_irq_in;
        out_item.leds = vif.mon_cb.leds;
        out_item.seg_cathode = vif.mon_cb.seg_cathode;
        out_item.seg_anode = vif.mon_cb.seg_anode;
        out_item.irq_out = vif.mon_cb.irq_out;
        
        `uvm_info("MON",$sformatf("[write addr channel] captured : AWADDR=%0h | AWVALID=%0b | AWREADY=%0b",out_item.AWADDR,out_item.AWVALID,out_item.AWREADY),UVM_LOW)
        
        `uvm_info("MON",$sformatf("[write data channel] captured : WVALID=%0b | WSTRB=%0d | WDATA=%0d WREADY=%0b",out_item.WVALID,out_item.WSTRB,out_item.WDATA,out_item.WREADY),UVM_LOW)
        
        `uvm_info("MON",$sformatf("[write resp channel] captured : BRESP=%0b | BVALID=%0b | BREADY=%0b",out_item.BRESP,out_item.BVALID,out_item.BREADY),UVM_LOW)
        
        `uvm_info("MON",$sformatf("[read addr channel] captured : ARADDR=%0h | ARVALID=%0b | ARREADY=%0b",out_item.ARADDR,out_item.ARVALID,out_item.ARREADY),UVM_LOW)
        
        `uvm_info("MON",$sformatf("[read data channel] captured : RVALID=%0b | RDATA=%0d | RRESP=%0b | RREADY = %0b ",out_item.RVALID,out_item.RDATA,out_item.RRESP,out_item.RREADY),UVM_LOW)
        
        `uvm_info("MON",$sformatf("[external signals] captured : ext_irq_in=%0b | leds=%0d | seg_cathode=%0d | seg_anode = %0d | irq_out = %0b ",out_item.ext_irq_in,out_item.leds,out_item.seg_cathode,out_item.seg_anode,out_item.irq_out),UVM_LOW)
        
        a_mon_port.write(out_item);
        
        repeat(1) @(vif.mon_cb);

    end
  endtask

endclass
