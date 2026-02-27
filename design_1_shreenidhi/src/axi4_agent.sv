class axi4_agent extends uvm_agent;

  `uvm_component_utils(axi4_agent)

 
   axi4_driver     drv_h;
  axi4_sequencer sqr_h;
  axi4_monitor    mon_h;

 
  function new(string name = "axi4_agent",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  //---------------------------------
  // Build Phase
  //---------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  
    if (is_active == UVM_ACTIVE) begin
      drv_h = axi4_driver::type_id::create("drv_h", this);
      sqr_h = axi4_sequencer::type_id::create("sqr_h", this);
    end
       mon_h = axi4_monitor::type_id::create("mon_h", this);
  endfunction


  //---------------------------------
  // Connect Phase
  //---------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      drv_h.seq_item_port.connect(sqr_h.seq_item_export);
    end

  endfunction

endclass
