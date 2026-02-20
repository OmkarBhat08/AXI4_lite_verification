class axi4_base_seq extends uvm_sequence #(axi4_seq_item);
  `uvm_object_utils(axi4_base_seq)
  
  function new(string name="axi4_base_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    axi4_seq_item req;
    repeat (100) 
      begin
      req = axi4_seq_item::type_id::create("req");
      start_item(req);
      req.randomize();
      finish_item(req);
    end
  endtask
  
endclass
