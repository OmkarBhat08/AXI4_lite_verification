
class axi4_driver extends uvm_driver #(axi4_seq_item);
  `uvm_component_utils(axi4_driver)

  virtual axi4_if vif;
  static int i;
  static bit rd_addr_done;
  static bit wrt_data_done, wrt_addr_done;

  //-----------------------new constructor---------------------------//
  function new(string name = "axi4_driver", uvm_component parent = null);
    super.new(name, parent);
    i = 0;
    rd_addr_done   = 0;
    wrt_data_done  = 0;
    wrt_addr_done  = 0;
  endfunction

  //---------------------build phase------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!(uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)))
      `uvm_fatal("DRIVER", "NO VIRTUAL INTERFACE IN DRIVER")

  endfunction

  //---------------------run phase-----------------------------//
  task run_phase(uvm_phase phase);
    repeat (3) @(vif.drv_cb);
    forever 
    begin
      seq_item_port.get_next_item(req);
      drive();
      seq_item_port.item_done();
      i++;
    end
  endtask

  task drive;

    //----write address channel------//
    vif.drv_cb.AWADDR<=req.AWADDR;
    vif.drv_cb.AWVALID<=req.AWVALID;

    //----write data channel-------//
    vif.drv_cb.WDATA<=req.WDATA;
    vif.drv_cb.WSTRB<=req.WSTRB;
    vif.drv_cb.WVALID<=req.WVALID;

    //----write response channel---//
    vif.drv_cb.BREADY<=req.BREADY;

    //----read address channel----//
    vif.drv_cb.ARADDR<=req.ARADDR;
    vif.drv_cb.ARVALID<=req.ARVALID;

    //-----read data channel---//
    vif.drv_cb.RREADY<=req.RREADY;

    //---interuppt input------//
    vif.drv_cb.EXT_IRQ_IN<=req.EXT_IRQ_IN;

    `uvm_info("DRV",$sformatf("--------------------------DRIVER - %0d Driving-------------------",i),UVM_LOW)

    `uvm_info("DRV",$sformatf("Write address channel : AWADDR = 0x%0h | AWVALID = %0b ",req.AWADDR, req.AWVALID),UVM_LOW)
    `uvm_info("DRV",$sformatf("Write data channel : WDATA = 0x%0h | WSTRB = 0x%0d | WVALID = %0b",req.WDATA, req.WSTRB, req.WVALID),UVM_LOW)
    `uvm_info("DRV",$sformatf("Write response channel : BREADY = %0b", req.BREADY),UVM_LOW)
    `uvm_info("DRV",$sformatf("Read address channel :ARADDR = 0x%0h, ARVALID = %0b",req.ARADDR, req.ARVALID),UVM_LOW)
    `uvm_info("DRV",$sformatf("Read data channel : RREADY = %0b", req.RREADY),UVM_LOW)
    `uvm_info("DRV",$sformatf("Extra irq input : EXT_IRQ_IN = %0b", req.EXT_IRQ_IN),UVM_LOW)

    `uvm_info("DRV",$sformatf("-------------------------------------------------------------------"),UVM_LOW)
fork
    do begin
      @(vif.drv_cb);
      `uvm_info("WRT-ADDR-DRV",$sformatf("[DRIVER-%0d] waiting for Write ADDR handshake ",i),UVM_LOW)
    end while(vif.drv_cb.AWVALID && vif.drv_cb.AWREADY) ;

    do begin
      @(vif.drv_cb);
      `uvm_info("WRT-DATA-DRV",$sformatf("[DRIVER-%0d] waiting for Write DATA handshake ",i),UVM_LOW)
    end while(vif.drv_cb.WVALID && vif.drv_cb.WREADY);

    do begin
      @(vif.drv_cb);
      `uvm_info("WRT-RESP-DRV",$sformatf("[DRIVER-%0d] waiting for Write RESPONSE handshake ",i),UVM_LOW)
    end while(vif.drv_cb.BREADY && vif.drv_cb.BVALID);

    do begin
      @(vif.drv_cb);
      `uvm_info("RD-ADDR-DRV",$sformatf("[DRIVER-%0d] waiting for READ address handshake ",i),UVM_LOW)
    end while(vif.drv_cb.ARVALID && vif.drv_cb.ARREADY); 

    do begin
      @(vif.drv_cb);
      `uvm_info("RD-DATA-DRV",$sformatf("[DRIVER-%0d] waiting for READ data handshake ",i),UVM_LOW)
    end while(vif.drv_cb.RREADY && vif.drv_cb.RVALID);
join
  endtask
endclass

 
