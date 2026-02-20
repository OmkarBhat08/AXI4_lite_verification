class axi4_driver extends uvm_driver #(axi4_seq_item);

  `uvm_component_utils(axi4_driver)

  virtual inf vif;

//-----------------------new constructor---------------------------//
  function new(string name = "axi4_driver",uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

//---------------------build phase------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

      if (!(uvm_config_db #(virtual inf)::get(this, "", "vif", vif)))
      `uvm_fatal("DRIVER", "NO VIRTUAL INTERFACE IN DRIVER")

  endfunction 

//---------------------run phase-----------------------------//
  task run_phase(uvm_phase phase);

    repeat (2) @(vif.drv_cb);

    forever begin
      seq_item_port.get_next_item(req);
      drive_task();
      seq_item_port.item_done();
    end

  endtask 

//----------------------task drive-------------------------//
  task drive_task();

    `uvm_info("DRV", $sformatf("Driving transaction"), UVM_LOW)

    repeat (1) @(vif.drv_cb);

  endtask 


endclass 
