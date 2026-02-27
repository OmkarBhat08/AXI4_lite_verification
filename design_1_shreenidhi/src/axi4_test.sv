//==========================================================
// BASE TEST
//==========================================================

class axi4_base_test extends uvm_test;

  `uvm_component_utils(axi4_base_test)

  axi4_environment env;

  function new(string name="axi4_base_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = axi4_environment::type_id::create("env", this);
  endfunction

endclass


//==========================================================
// WRITE TESTS
//==========================================================

class axi4_reset_test extends axi4_base_test;
  `uvm_component_utils(axi4_reset_test)
  axi4_reset_seq reset_seq;

  function new(string name="axi4_reset_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    reset_seq = axi4_reset_seq::type_id::create("reset_seq");
    reset_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_valid_write_handshake_test extends axi4_base_test;
  `uvm_component_utils(axi4_valid_write_handshake_test)
  axi4_valid_write_handshake_seq valid_write_handshake_seq;

  function new(string name="axi4_valid_write_handshake_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    valid_write_handshake_seq =
      axi4_valid_write_handshake_seq::type_id::create("valid_write_handshake_seq");
    valid_write_handshake_seq.start(env.agent_h.sqr_h);
    #200;
    phase.drop_objection(this);
  endtask
endclass


class axi4_address_before_data_test extends axi4_base_test;
  `uvm_component_utils(axi4_address_before_data_test)
  axi4_address_before_data_seq address_before_data_seq;

  function new(string name="axi4_address_before_data_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    address_before_data_seq =
      axi4_address_before_data_seq::type_id::create("address_before_data_seq");
    address_before_data_seq.start(env.agent_h.sqr_h);
    #200;
    phase.drop_objection(this);
  endtask
endclass


class axi4_data_before_address_test extends axi4_base_test;
  `uvm_component_utils(axi4_data_before_address_test)
  axi4_data_before_adress_seq data_before_adress_seq;

  function new(string name="axi4_data_before_address_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    data_before_adress_seq =
      axi4_data_before_adress_seq::type_id::create("data_before_adress_seq");
    data_before_adress_seq.start(env.agent_h.sqr_h);
   // #500;
    phase.drop_objection(this);
  endtask
endclass



class axi4_response_check_test extends axi4_base_test;
  `uvm_component_utils(axi4_response_check_test)
  axi4_response_check_seq response_check_seq;

  function new(string name="axi4_response_check_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    response_check_seq =
      axi4_response_check_seq::type_id::create("response_check_seq");
    response_check_seq.start(env.agent_h.sqr_h);
    #500;
    phase.drop_objection(this);
  endtask
endclass


class axi4_BVALID_hold_test extends axi4_base_test;
  `uvm_component_utils(axi4_BVALID_hold_test)
  axi4_BVALID_hold_seq BVALID_hold_seq;

  function new(string name="axi4_BVALID_hold_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    BVALID_hold_seq =
      axi4_BVALID_hold_seq::type_id::create("BVALID_hold_seq");
    BVALID_hold_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_back_to_back_write_test extends axi4_base_test;
  `uvm_component_utils(axi4_back_to_back_write_test)
  axi4_back_to_back_write_seq back_to_back_write_seq;

  function new(string name="axi4_back_to_back_write_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    back_to_back_write_seq =
      axi4_back_to_back_write_seq::type_id::create("back_to_back_write_seq");
    back_to_back_write_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_multiple_outstanding_write_test extends axi4_base_test;
  `uvm_component_utils(axi4_multiple_outstanding_write_test)
  axi4_multiple_outstanding_write_seq multiple_outstanding_write_seq;

  function new(string name="axi4_multiple_outstanding_write_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    multiple_outstanding_write_seq =
      axi4_multiple_outstanding_write_seq::type_id::create("multiple_outstanding_write_seq");
    multiple_outstanding_write_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_invalid_address_write_test extends axi4_base_test;
  `uvm_component_utils(axi4_invalid_address_write_test)
  axi4_invalid_address_write_seq invalid_address_write_seq;

  function new(string name="axi4_invalid_address_write_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    invalid_address_write_seq =
      axi4_invalid_address_write_seq::type_id::create("invalid_address_write_seq");
    invalid_address_write_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_unaligned_address_write_test extends axi4_base_test;
  `uvm_component_utils(axi4_unaligned_address_write_test)
  axi4_unaligned_address_write_seq unaligned_address_write_seq;

  function new(string name="axi4_unaligned_address_write_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    unaligned_address_write_seq =
      axi4_unaligned_address_write_seq::type_id::create("unaligned_address_write_seq");
    unaligned_address_write_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


//==========================================================
// READ TESTS
//==========================================================

class axi4_valid_read_handshake_test extends axi4_base_test;
  `uvm_component_utils(axi4_valid_read_handshake_test)
  axi4_valid_read_handshake_seq valid_read_handshake_seq;

  function new(string name="axi4_valid_read_handshake_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    valid_read_handshake_seq =
      axi4_valid_read_handshake_seq::type_id::create("valid_read_handshake_seq");
    valid_read_handshake_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_RVALID_hold_test extends axi4_base_test;
  `uvm_component_utils(axi4_RVALID_hold_test)
  axi4_RVALID_hold_seq RVALID_hold_seq;

  function new(string name="axi4_RVALID_hold_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    RVALID_hold_seq =
      axi4_RVALID_hold_seq::type_id::create("RVALID_hold_seq");
    RVALID_hold_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_back_to_back_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_back_to_back_read_test)
  axi4_back_to_back_read_seq back_to_back_read_seq;

  function new(string name="axi4_back_to_back_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    back_to_back_read_seq =
      axi4_back_to_back_read_seq::type_id::create("back_to_back_read_seq");
    back_to_back_read_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_multiple_outstanding_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_multiple_outstanding_read_test)
  axi4_multiple_outstanding_read_seq multiple_outstanding_read_seq;

  function new(string name="axi4_multiple_outstanding_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    multiple_outstanding_read_seq =
      axi4_multiple_outstanding_read_seq::type_id::create("multiple_outstanding_read_seq");
    multiple_outstanding_read_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_invalid_address_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_invalid_address_read_test)
  axi4_invalid_address_read_seq invalid_address_read_seq;

  function new(string name="axi4_invalid_address_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    invalid_address_read_seq =
      axi4_invalid_address_read_seq::type_id::create("invalid_address_read_seq");
    invalid_address_read_seq.start(env.agent_h.sqr_h);
    #200;
    phase.drop_objection(this);
  endtask
endclass


class axi4_unaligned_address_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_unaligned_address_read_test)
  axi4_unaligned_address_read_seq unaligned_address_read_seq;

  function new(string name="axi4_unaligned_address_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    unaligned_address_read_seq =
      axi4_unaligned_address_read_seq::type_id::create("unaligned_address_read_seq");
    unaligned_address_read_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


//==========================================================
// CONCURRENT TEST
//==========================================================

class axi4_concurrent_write_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_concurrent_write_read_test)
  axi4_concurrent_write_read_seq concurrent_write_read_seq;

  function new(string name="axi4_concurrent_write_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    concurrent_write_read_seq =
      axi4_concurrent_write_read_seq::type_id::create("concurrent_write_read_seq");
    concurrent_write_read_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


//==========================================================
// LED / SEGMENT / INTERRUPT TESTS
//==========================================================

class axi4_led_write_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_led_write_read_test)
  axi4_led_write_read_seq led_write_read_seq;

  function new(string name="axi4_led_write_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    led_write_read_seq =
      axi4_led_write_read_seq::type_id::create("led_write_read_seq");
    led_write_read_seq.start(env.agent_h.sqr_h);
    #200;
    phase.drop_objection(this);
  endtask
endclass


class axi4_segment_write_read_test extends axi4_base_test;
  `uvm_component_utils(axi4_segment_write_read_test)
  axi4_segment_write_read_seq segment_write_read_seq;

  function new(string name="axi4_segment_write_read_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    segment_write_read_seq =
      axi4_segment_write_read_seq::type_id::create("segment_write_read_seq");
    segment_write_read_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_interrupt_assert_test extends axi4_base_test;
  `uvm_component_utils(axi4_interrupt_assert_test)
  axi4_interrupt_assert_seq interrupt_assert_seq;

  function new(string name="axi4_interrupt_assert_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    interrupt_assert_seq =
      axi4_interrupt_assert_seq::type_id::create("interrupt_assert_seq");
    interrupt_assert_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


class axi4_interrupt_deassert_test extends axi4_base_test;
  `uvm_component_utils(axi4_interrupt_deassert_test)
  axi4_interrupt_deassert_seq interrupt_deassert_seq;
  
  function new(string name="axi4_interrupt_deassert_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    interrupt_deassert_seq =
      axi4_interrupt_deassert_seq::type_id::create("interrupt_deassert_seq");
    interrupt_deassert_seq.start(env.agent_h.sqr_h);
    phase.drop_objection(this);
  endtask
endclass


//==========================================================
// REGRESSION TEST
//==========================================================

class axi4_regression_test extends axi4_base_test;

  `uvm_component_utils(axi4_regression_test)

  axi4_regression_seq regression_seq;
  
  function new(string name="axi4_regression_test", uvm_component parent);
    super.new(name,parent);
  endfunction

  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    regression_seq =
      axi4_regression_seq::type_id::create("regression_seq");

    regression_seq.start(env.agent_h.sqr_h);

    phase.drop_objection(this);

  endtask

endclass
