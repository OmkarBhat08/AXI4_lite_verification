class axi4_test extends uvm_test;

  `uvm_component_utils(axi4_test)

  axi4_virtual_seq  v_seq;
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

    v_seq = axi4_virtual_seq::type_id::create("v_seq");
    v_seq.start(env.v_seqr);

    phase.drop_objection(this);
  endtask

endclass
