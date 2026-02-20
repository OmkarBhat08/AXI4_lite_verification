class axi4_driver extends uvm_driver#(axi4_seq_item);
    `uvm_component_utils(axi4_driver)
    virtual axi4_interface vif;

    function new(string name = "axi4_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction: new
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if( !(uvm_config_db#(virtual axi4_interface)::get(this, "", "vif", vif) )
            `uvm_fatal("DRIVER", "NO VIRTUAL INTERFACE IN DRIVER")
    endfunction: build_phase

    task run_phase(uvm_phase phase);
        repeat(2)@(vif.drv_cb);
        forever begin
            seq_item_port.get_next_item(req);
            drive_task();
            seq_item_port.item_done();
        end
    endtask: run_phase
    task drive_task();

        `uvm_info(" DRV ", $sformatf(" ", ), UVM_LOW)
        repeat( )@(vif.drv_cb);
    endtask: drive_task

endclass: axi4_driver

 
