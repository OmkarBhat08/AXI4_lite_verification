class axi4_sequencer extends uvm_sequencer#(axi4_seq_item);

  function new(string name="",uvm_component parent);
    super.new(name,parent);
  endfunction

endclass

