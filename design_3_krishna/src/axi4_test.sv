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
    base_seq.start(env.sqr);
    phase.drop_objection(this);
  endtask

endclass

// -----------------------------------------------------------------
class simple_write_test extends axi4_base_test;
  `uvm_component_utils(simple_write_test)

  simple_write seq;

  function new(string name = "simple_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = simple_write::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class simple_read_test extends axi4_base_test;
  `uvm_component_utils(simple_read_test)

  simple_read seq;

  function new(string name = "simple_read_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = simple_read_test::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class read_followed_by_write_test extends axi4_base_test;
  `uvm_component_utils(read_followed_by_write_test)

  read_followed_by_write seq;

  function new(string name = "read_followed_by_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = read_followed_by_write::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class parallel_read_write_test extends axi4_base_test;
  `uvm_component_utils(parallel_read_write_test)

  parallel_read_write seq;

  function new(string name = "parallel_read_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = parallel_read_write::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class data_before_addr_test extends axi4_base_test;
  `uvm_component_utils(data_before_addr_test)

  data_before_addr seq;

  function new(string name = "data_before_addr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = data_before_addr::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class addr_before_data_test extends axi4_base_test;
  `uvm_component_utils(addr_before_data_test)

  addr_before_data seq;

  function new(string name = "addr_before_data_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = addr_before_data::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class data_with_addr_test extends axi4_base_test;
  `uvm_component_utils(data_with_addr_test)

  data_with_addr seq;

  function new(string name = "data_with_addr_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = data_with_addr::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class continuous_write_test extends axi4_base_test;
  `uvm_component_utils(continuous_write_test)

  continuous_write seq;

  function new(string name = "continuous_write_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = continuous_write::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class write_strobe_select_1_test extends axi4_base_test;
  `uvm_component_utils(write_strobe_select_1_test)

  write_strobe_select_1 seq;

  function new(string name = "write_strobe_select_1_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = write_strobe_select_1::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class write_strobe_select_2_test extends axi4_base_test;
  `uvm_component_utils(write_strobe_select_2_test)

  write_strobe_select_2 seq;

  function new(string name = "", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = write_strobe_select_2::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class invalid_addr_test extends axi4_base_test;
  `uvm_component_utils(invalid_addr_test)

  invalid_addr seq;

  function new(string name = "invalid_addr", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    phase.raise_objection(this);
    seq = invalid_addr::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass

// -----------------------------------------------------------------
class irq_test extends axi4_base_test;
  `uvm_component_utils(irq_test)

  irq_seq_1 seq;

  function new(string name = "irq_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(this);

    phase.raise_objection(this);
    seq = irq_seq_1::type_id::create("seq");
    seq.start(env.act_agent.seqr);
    phase.drop_objection(this);
  endtask
endclass


