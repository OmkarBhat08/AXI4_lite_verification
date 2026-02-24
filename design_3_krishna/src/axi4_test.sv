class axi4_base_test extends uvm_test;

  `uvm_component_utils(axi4_base_test)

  axi4_base_seq     base_seq;
  axi4_environment  env;

  function new(string name = "", uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_environment::type_id::create("env", this);
  endfunction 


  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);

    base_seq = axi4_base_seq::type_id::create("base_seq");
    base_seq.start(env.act_agent.sqr_h);

    phase.drop_objection(this);
  endtask

endclass
