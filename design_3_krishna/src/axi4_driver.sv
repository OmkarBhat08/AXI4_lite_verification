class axi4_driver extends uvm_driver #(axi4_seq_item);

  `uvm_component_utils(axi4_driver)

  virtual axi4_if.DRV vif;

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

    if (!(uvm_config_db #(virtual inf)::get(this, "", "vif", vif)))
    begin
      `uvm_fatal("DRIVER", "NO VIRTUAL INTERFACE IN DRIVER")
    end

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


  //----------------------task drive-------------------------//
  task drive();
    
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
    vif.drv_cb.EXTRA_IRQ_IN<=req.EXTRA_IRQ_IN;
    
    `uvm_info("DRV",$sformatf("--------------------------DRIVER - %0d Driving-------------------",i),UVM_LOW)
    
    `uvm_info("DRV",$sformatf("Write address channel : AWADDR = 0x%0h | AWVALID = %0b ",req.AWADDR, req.AWVALID),UVM_LOW)
    `uvm_info("DRV",$sformatf("Write data channel : WDATA = 0x%0h | WSTRB = 0x%0d | WVALID = %0b",req.WDATA, req.WSTRB, req.WVALID),UVM_LOW)
    `uvm_info("DRV",$sformatf("Write response channel : BREADY = %0b", req.BREADY),UVM_LOW)
    `uvm_info("DRV",$sformatf("Read address channel :ARADDR = 0x%0h, ARVALID = %0b",req.ARADDR, req.ARVALID),UVM_LOW)
    `uvm_info("DRV",$sformatf("Read data channel : RREADY = %0b", req.RREADY),UVM_LOW)
    `uvm_info("DRV",$sformatf("Extra irq input : EXT_IRQ_IN = %0b", req.EXTRA_IRQ_IN),UVM_LOW)
    
    `uvm_info("DRV",$sformatf("-------------------------------------------------------------------"),UVM_LOW)
    
    fork
      // write
      fork
        check_wrt_addr(); 
        check_wrt_data(); 
        check_wrt_resp(); 
      join

      // read
      fork
        check_rd_addr(); 
      join
      
    join
    
  endtask

  //read address handshake

  task check_rd_addr();
    if (rd_addr_done == 0) 
      begin 

        if(req.ARVALID == 1) 
          begin
            wait(vif.drv_cb.ARREADY);
            `uvm_info("RD-ADDR-DRV", $sformatf("[DRIVER-%0d] : Slave asserted ARREADY, read address handshake completed", i),UVM_LOW)
            rd_addr_done=1;
            repeat(1) @(vif.drv_cb);
            check_rd_data();
        end
      else 
        begin
          `uvm_info("RD-ADDR-DRV", $sformatf("[DRIVER-%0d] : ARVALID is asserted yet", i), UVM_LOW)
        end
      
    end
    else 
      begin
        check_rd_data();
      end

  endtask


  // read data handshake
  task check_rd_data();

    if (req.RREADY == 1) 
      begin
        wait(vif.drv_cb.RVALID);
        `uvm_info("RD-DATA-DRV",$sformatf("[DRIVER-%0d] : Slave asserted RVALID, read data handshake completed", i),UVM_LOW)
        rd_addr_done=0;
      end
    else 
      begin
        `uvm_info("RD-DATA-DRV", $sformatf("[DRIVER-%0d] : RREADY is not asserted yet", i),UVM_LOW)
      end
  endtask
  
  //write address handshake
  task check_wrt_addr();
    if(wrt_addr_done==0)
      begin
        if(req.AWVALID==1)
          begin
            wait(vif.drv_cb.AWREADY);
            `uvm_info("WRT-ADDR-DRV",$sformatf("[DRIVER-%0d] Slave asserted AWREADY, Write address handshake done",i),UVM_LOW)
            wrt_addr_done=1;
          end
        else
          begin
            `uvm_info("WRT-ADDR-DRV",$sformatf("[DRIVER-%0d] AWALID is not asserted yet",i),UVM_LOW)
          end
        
      end
  endtask
  
  //write data handshake
  
  task check_wrt_data();
    
    if(wrt_data_done==0)
      begin
        if(req.WVALID==1)
          begin 
            wait(vif.drv_cb.WREADY);
            `uvm_info("WRT-DATA-DRV",$sformatf("[DRIVER-%0d] Slave asserted WREADY, Write data handshake done",i),UVM_LOW)
            wrt_data_done=1;
          end
        else
          begin
            `uvm_info("WRT-DATA-DRV",$sformatf("[DRIVER-%0d] WVALID is not asserted yet",i),UVM_LOW)
          end
      end
         
  endtask
        
  
  //write response handshake
  task check_wrt_resp();
    if(wrt_data_done && wrt_addr_done)
      begin
        if(req.BREADY==1)
          begin
            wait(vif.drv_cb.BVALID);
            `uvm_info("WRT-RESP-DRV",$sformatf("[DRIVER-%0d] Slave asserted BVALID, Write response handshake done",i),UVM_LOW)
            wrt_data_done=0;
            wrt_addr_done=0;
          end
        else
          begin
            `uvm_info("WRT-RESP-DRV",$sformatf("[DRIVER-%0d] BREADY is not asserted yet",i),UVM_LOW)
          end
      end
    else
      begin
        `uvm_info("WRT-RSP-DRV",$sformatf("[DRIVER-%0d] waiting for completion of write data/addr handshake",i),UVM_LOW)
      end
            
  endtask

endclass
