class axi4_driver extends uvm_driver #(axi4_seq_item);
  `uvm_component_utils(axi4_driver)

  virtual axi4_if vif;
  int i;

  int timeout = 5000; 

  //----------------------- Constructor ---------------------------//
  function new(string name = "axi4_driver", uvm_component parent = null);
    super.new(name, parent);
    i = 0;
  endfunction

  //--------------------- Build Phase ------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!(uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif))) begin
      `uvm_fatal("DRIVER", "NO VIRTUAL INTERFACE IN DRIVER")
    end
  endfunction

  //--------------------- Run Phase -----------------------------//
  task run_phase(uvm_phase phase);
    vif.drv_cb.AWVALID <= 0;
    vif.drv_cb.WVALID  <= 0;
    vif.drv_cb.BREADY  <= 0;
    vif.drv_cb.ARVALID <= 0;
    vif.drv_cb.RREADY  <= 0;

    wait(vif.ARESETn === 1'b1); 
    repeat (3) @(vif.drv_cb);
    
    forever begin
      seq_item_port.get_next_item(req);
      drive();
      @(vif.drv_cb);
      seq_item_port.item_done();
      i++;
    end
  endtask

  task drive();
    `uvm_info("DRV",$sformatf("------------------------------DRIVER - %0d Driving-----------------------",i),UVM_LOW)
    
    vif.drv_cb.EXT_IRQ_IN <= req.EXT_IRQ_IN;

    fork
      if (req.AWVALID) check_wrt_addr(req);
      if (req.WVALID)  check_wrt_data(req);
      if (req.AWVALID || req.WVALID) check_wrt_resp(req);
      
      if (req.ARVALID) check_rd_addr(req);
      if (req.ARVALID) check_rd_data(req);
    join
    
    `uvm_info("DRV",$sformatf("-------------------------------------------------------------------------------------"),UVM_LOW)
  endtask

  task check_wrt_addr(axi4_seq_item req);
    int timer = 0;
    `uvm_info("DRV", $sformatf("Write Addr Ch : AWADDR = 0x%0h | AWVALID = 1", req.AWADDR), UVM_HIGH)
    vif.drv_cb.AWADDR  <= req.AWADDR;
    vif.drv_cb.AWVALID <= 1'b1;
    
    do begin
      @(vif.drv_cb);
      timer++;
      if (timer > timeout) `uvm_fatal("DRV","Slave never asserted AWREADY")
    end while (!vif.drv_cb.AWREADY);
    
    vif.drv_cb.AWVALID <= 1'b0;
  endtask
  
  // Write Data Handshake
  task check_wrt_data(axi4_seq_item req);
    int timer = 0;
    `uvm_info("DRV", $sformatf("Write Data Ch : WDATA = 0x%0h | WSTRB = 0x%0h | WVALID = 1", req.WDATA, req.WSTRB), UVM_HIGH)
    vif.drv_cb.WDATA  <= req.WDATA;
    vif.drv_cb.WSTRB  <= req.WSTRB;
    vif.drv_cb.WVALID <= 1'b1;

    do begin
      @(vif.drv_cb);
      timer++;
      if (timer > timeout) `uvm_fatal("DRV", "Slave never asserted WREADY")
    end while (!vif.drv_cb.WREADY);
    
    vif.drv_cb.WVALID <= 1'b0;
  endtask
  
  // Write Response Handshake
  task check_wrt_resp(axi4_seq_item req);
    int timer = 0;
    `uvm_info("DRV", $sformatf("Write Resp Ch : BREADY = 1"), UVM_HIGH)
    vif.drv_cb.BREADY <= req.BREADY; 
    
    do begin
      @(vif.drv_cb);
      timer++;
      if (timer > timeout) `uvm_fatal("DRV", "Slave never asserted BVALID")
    end while (!vif.drv_cb.BVALID); 
    
    vif.drv_cb.BREADY <= 1'b0;
  endtask

  // Read Address Handshake
  task check_rd_addr(axi4_seq_item req);
    int timer = 0;
    `uvm_info("DRV", $sformatf("Read Addr Ch  : ARADDR = 0x%0h | ARVALID = 1", req.ARADDR), UVM_HIGH)
    vif.drv_cb.ARADDR  <= req.ARADDR;
    vif.drv_cb.ARVALID <= 1'b1;
    
    do begin
      @(vif.drv_cb);
      timer++;
      if (timer > timeout) `uvm_fatal("DRV", "Slave never asserted ARREADY")
    end while (!vif.drv_cb.ARREADY);
    
    vif.drv_cb.ARVALID <= 1'b0;
  endtask

  // Read Data Handshake
  task check_rd_data(axi4_seq_item req);
    int timer = 0;
    `uvm_info("DRV", $sformatf("Read Data Ch  : RREADY = 1"), UVM_HIGH)
    vif.drv_cb.RREADY <= req.RREADY; 
    
    do begin
      @(vif.drv_cb);
      timer++;
      if (timer > timeout) `uvm_fatal("DRV", "Slave never asserted RVALID")
    end while (!vif.drv_cb.RVALID);
    
    vif.drv_cb.RREADY <= 1'b0;
  endtask
  
endclass
