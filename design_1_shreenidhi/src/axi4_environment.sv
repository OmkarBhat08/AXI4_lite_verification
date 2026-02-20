class axi4_environment extends uvm_env;

  `uvm_component_utils(axi4_environment)

  axi4_active_agent   act_agent;
  axi4_passive_agent  pas_agent;
  axi4_scoreboard     scb;
  axi4_subscriber     cov;


  function new(string name = "axi4_environment",uvm_component parent = null);
    super.new(name, parent);
  endfunction 


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    act_agent = axi4_active_agent::type_id::create("act_agent", this);
    pas_agent = axi4_passive_agent::type_id::create("pas_agent", this);
    scb       = axi4_scoreboard::type_id::create("scb", this);
    cov       = axi4_subscriber::type_id::create("cov", this);

  endfunction 


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    // monitors to scoreboard fifos
    act_agent.a_mon_h.a_mon_port.connect(scb.active_fifo.analysis_export);
    pas_agent.p_mon_h.p_mon_port.connect(scb.passive_fifo.analysis_export);

    // monitors to suscriber fifos
    act_agent.a_mon_h.a_mon_port.connect(cov.inp_fifo.analysis_export);
    pas_agent.p_mon_h.p_mon_port.connect(cov.op_fifo.analysis_export);

  endfunction 


endclass 

