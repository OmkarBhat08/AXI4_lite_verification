class axi4_passive_monitor extends uvm_monitor;

  `uvm_component_utils(axi4_passive_monitor)

  virtual inf vif;
  uvm_analysis_port #(axi4_seq_item) p_mon_port;
  axi4_seq_item out_item;


  function new(string name = "axi4_passive_monitor",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    p_mon_port = new("p_mon_port", this);

    if (!(uvm_config_db #(virtual inf)::get(this, "", "vif", vif)))
      `uvm_fatal("PASSIVE_MONITOR",
                 "NO VIRTUAL INTERFACE IN PASSIVE MONITOR")
  endfunction


  task run_phase(uvm_phase phase);
    repeat (3) @(vif.mon_cb);

    forever begin

      out_item = axi4_seq_item::type_id::create("out_item");

      @(vif.mon_cb);

    end
  endtask

endclass
