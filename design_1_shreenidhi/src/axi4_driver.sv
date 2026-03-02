class axi4_driver extends uvm_driver #(axi4_seq_item);

  `uvm_component_utils(axi4_driver)

  virtual inf vif;
  int AW_waiting;
  int W_waiting;
  int AR_waiting;
  int got_addr;

//---------------------------new constructor-------------------------//
  function new(string name = "axi4_driver",uvm_component parent = null);
    super.new(name, parent);
  endfunction 

//----------------------------build phase-----------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

      if (!(uvm_config_db #(virtual inf)::get(this, "", "vif", vif)))
      `uvm_fatal("DRIVER", "NO VIRTUAL INTERFACE IN DRIVER")

  endfunction 

//------------------------------run pahse-----------------------------//
  task run_phase(uvm_phase phase);

    repeat (2) @(vif.drv_cb);

    forever begin
      seq_item_port.get_next_item(req);
      vif.S_BREADY <= req.S_BREADY;
      vif.S_RREADY <= req.S_RREADY;
      fork
        if(!AW_waiting) drive_write_addr();
        if(!W_waiting) drive_write_data();
        if(!AR_waiting) drive_read_addr();
      join
      repeat (1) @(vif.drv_cb);
      seq_item_port.item_done();
    end

  endtask 

//----------------------------------task drive----------------------//
  
  task drive_write_addr();
    got_addr = 0;
    vif.S_AWADDR  <= req.S_AWADDR;
    vif.S_AWVALID <= req.S_AWVALID;
    
    if(req.S_AWVALID)begin
      AW_waiting = 1;
      wait(vif.S_AWREADY == 1);
      got_addr = 1;
    end

   // `uvm_info("DRV", $sformatf("Driving write addr transaction complete"), UVM_LOW)

  endtask 
    
   task drive_write_data();
    vif.S_WDATA   <= req.S_WDATA;
    vif.S_WSTRB   <= req.S_WSTRB;
    vif.S_WVALID  <= req.S_WVALID;
    
    if(req.S_WVALID)begin
      W_waiting = 1;
      wait(vif.S_WREADY == 1);
      wait(got_addr && vif.S_BVALID && vif.S_BREADY && (vif.S_BRESP == 2'b00));
      AW_waiting = 0;
      W_waiting = 0;
    end

   //  `uvm_info("DRV", $sformatf("Driving write data transaction complete"), UVM_LOW)

  endtask
    
  task drive_read_addr();
    vif.S_ARADDR  <= req.S_ARADDR;
    vif.S_ARVALID <= req.S_ARVALID;
    
    if(req.S_ARVALID)begin
      AR_waiting = 1;
      wait(vif.S_ARREADY == 1);
      wait(vif.S_RREADY && vif.S_RVALID && (vif.S_RRESP == 2'b00));
      AR_waiting = 0;
    end

    //`uvm_info("DRV", $sformatf("Driving read addr transaction complete"), UVM_LOW)

  endtask 
    
    


endclass 
 
