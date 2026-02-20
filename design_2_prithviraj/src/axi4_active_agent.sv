class axi4_active_agent extends uvm_agent;

  `uvm_component_utils(axi4_active_agent)

  axi4_driver         drv_h;
  axi4_active_monitor a_mon_h;
  axi4_sequencer      sqr_h;

  uvm_active_passive_enum is_active;

//-------------------------new constructor---------------------------------//
  function new(string name = "axi4_active_agent",uvm_component parent = null);
    super.new(name, parent);
  endfunction 

//-------------------------build phase-----------------------------------//
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    drv_h   = axi4_driver::type_id::create("drv_h", this);
    sqr_h   = axi4_sequencer::type_id::create("sqr_h", this);
    a_mon_h = axi4_active_monitor::type_id::create("a_mon_h", this);

  endfunction 

//----------------------connect phase------------------------------------//
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    drv_h.seq_item_port.connect(sqr_h.seq_item_export);

  endfunction 

endclass
