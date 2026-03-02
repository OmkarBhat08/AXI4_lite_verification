class axi4_driver extends uvm_driver #(axi4_seq_item);

  `uvm_component_utils(axi4_driver)

  virtual axi4_if.DRV vif;

  static int i;
  static bit rd_addr_done;
  static bit wrt_data_done, wrt_addr_done;
  static bit wrt_addr_wait,wrt_data_wait,rd_addr_wait;

  //-----------------------new constructor---------------------------//
  function new(string name = "axi4_driver", uvm_component parent = null);
    super.new(name, parent);

    i = 0;
    rd_addr_done  = 0;
    wrt_data_done = 0;
    wrt_addr_done = 0;
    
    wrt_addr_wait = 0;
    wrt_data_wait = 0;
    rd_addr_wait  = 0;

  endfunction

  //---------------------build phase------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if (!(uvm_config_db #(virtual axi4_if)::get(this, "", "vif", vif)))
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

    

   
    //----write response channel---//
    vif.drv_cb.BREADY<=req.BREADY;
    
    //-----read data channel---//
    vif.drv_cb.RREADY<=req.RREADY;
    
    //---interuppt input------//
    vif.drv_cb.EXT_IRQ_IN<=req.EXT_IRQ_IN;
    
    `uvm_info("DRV",$sformatf("--------------------------DRIVER - %0d Driving-------------------",i),UVM_LOW)
    `uvm_info("DRV",$sformatf("Write response channel : BREADY = %0b", req.BREADY),UVM_LOW)
    `uvm_info("DRV",$sformatf("Read data channel : RREADY = %0b", req.RREADY),UVM_LOW)
    `uvm_info("DRV",$sformatf("Extra irq input : EXT_IRQ_IN = %0b", req.EXT_IRQ_IN),UVM_LOW)
        
    fork
      // write
      fork
        if(!wrt_addr_wait)
          check_wrt_addr(); 
        if(!wrt_data_wait)
          check_wrt_data(); 
      join

      // read
      fork
        check_rd_addr(); 
      join
      
    join
@(vif.drv_cb);
  endtask

  //read address handshake

  task check_rd_addr();
    `uvm_info("DRV",$sformatf("Read address channel :ARADDR = 0x%0h, ARVALID = %0b",req.ARADDR, req.ARVALID),UVM_LOW)
    vif.drv_cb.ARADDR<=req.ARADDR;
    vif.drv_cb.ARVALID<=req.ARVALID;
    if (rd_addr_done == 0) 
      begin 

        if(req.ARVALID == 1) 
          begin
            
            rd_addr_wait=1;
            wait(vif.drv_cb.ARREADY);
            rd_addr_done=1;
            rd_addr_wait=0;
            
            repeat(1) @(vif.drv_cb);
            vif.drv_cb.ARVALID<=0;
            check_rd_data();
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
        rd_addr_done=0;
      end
  endtask
  
  //write address handshake
  task check_wrt_addr();
    vif.drv_cb.AWADDR<=req.AWADDR;
    vif.drv_cb.AWVALID<=req.AWVALID;
    `uvm_info("DRV",$sformatf("Write address channel : AWADDR = 0x%0h | AWVALID = %0b ",req.AWADDR, req.AWVALID),UVM_LOW)
    if(wrt_addr_done==0)
      begin
        if(req.AWVALID==1)
          begin
            wrt_addr_wait=1;
            wait(vif.drv_cb.AWREADY);
            wrt_addr_wait=0;
            wrt_addr_done=1;
            
            fork
              
              if(wrt_data_done && wrt_addr_done)
                check_wrt_resp();
            
              @(vif.drv_cb)
              begin
                vif.drv_cb.AWVALID<=0;
              end
              
            join
            
          end
      end
  endtask
  
  //write data handshake
  
  task check_wrt_data();
    vif.drv_cb.WDATA<=req.WDATA;
    vif.drv_cb.WSTRB<=req.WSTRB;
    vif.drv_cb.WVALID<=req.WVALID;
    `uvm_info("DRV",$sformatf("Write data channel : WDATA = 0x%0h | WSTRB = 0x%0d | WVALID = %0b",req.WDATA, req.WSTRB, req.WVALID),UVM_LOW)
    if(wrt_data_done==0)
      begin
        if(req.WVALID==1)
          begin 
            wrt_data_wait=1;
            wait(vif.drv_cb.WREADY);
            wrt_data_done=1;
            wrt_data_wait=0;
            
            fork 
              if(wrt_data_done && wrt_addr_done)
                check_wrt_resp();
              
              @(vif.drv_cb)
              begin
                vif.drv_cb.WVALID<=0;
              end
            join
            
          end
      end
         
  endtask
        
  
  //write response handshake
  task check_wrt_resp();
        if(req.BREADY==1 && vif.drv_cb.BVALID==1)
          begin
            wrt_data_done=0;
            wrt_addr_done=0;       
          end
  endtask

endclass
