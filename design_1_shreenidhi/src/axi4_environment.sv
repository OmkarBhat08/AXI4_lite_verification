class axi4_environment extends uvm_env;

  `uvm_component_utils(axi4_environment)

  axi4_agent       agent_h;
  axi4_scoreboard  scb;
  axi4_subscriber  cov;

  function new(string name = "axi4_environment",
               uvm_component parent = null);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    agent_h = axi4_agent::type_id::create("agent_h", this);
    scb     = axi4_scoreboard::type_id::create("scb", this);
    cov     = axi4_subscriber::type_id::create("cov", this);
  endfunction


  //----------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // Monitor - Scoreboard
    agent_h.mon_h.mon_port.connect(scb.mon_fifo.analysis_export);

    // Monitor - Coverage
    agent_h.mon_h.mon_port.connect(cov.inp_fifo.analysis_export);
    agent_h.mon_h.mon_port.connect(cov.op_fifo.analysis_export);
  endfunction

endclass
