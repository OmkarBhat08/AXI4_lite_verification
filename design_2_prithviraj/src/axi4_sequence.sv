class base_seq extends uvm_sequence #(axi4_seq_item);
  `uvm_object_utils(base_seq)
  
  function new(string name="base_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    axi4_seq_item req;
    `uvm_info(get_type_name(), " ------ Base Sequence ------ ", UVM_NONE)
    repeat (100) begin
      req = axi4_seq_item::type_id::create("req");
      start_item(req);
      req.randomize();
      finish_item(req);
    end
  endtask
endclass

// -----------------------------------------------------------------
// Simple write with strobe = 'b1111
class simple_write extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(simple_write)

  function new(string name = "simple_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Simple write with strobe = 'b1111 ------ ", UVM_NONE)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111; req.BREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Simple read
class simple_read extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(simple_read)

  function new(string name = "simple_read");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Simple read ------ ", UVM_NONE)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.ARADDR inside {0, 4, 8}; req.ARVALID == 1; req.RREADY == 1;})

    end
  endtask
endclass

// -----------------------------------------------------------------
// Read followed by Write
class read_followed_by_write extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(read_followed_by_write)
  int prev_addr;

  function new(string name = "read_followed_by_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Read followed by Write ------ ", UVM_NONE)
    repeat(10) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Parallel Read and Write
class parallel_read_write extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(parallel_read_write)

  function new(string name = "parallel_read_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Parallel Read and Write ------ ", UVM_NONE)
    repeat(10) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.BREADY == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write data before address
class data_before_addr extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(data_before_addr)

  function new(string name = "data_before_addr");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write data before address ------ ", UVM_NONE)
    repeat(10) begin
      `uvm_do_with(req, {req.WVALID == 1; req.WSTRB == 4'b1111;})
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1;})
      `uvm_do_with(req, {req.BREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write address before data together
class addr_before_data extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(addr_before_data)

  function new(string name = "addr_before_data");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write address before data together ------ ", UVM_NONE)
    repeat(10) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1;})
      `uvm_do_with(req, {req.WVALID == 1; req.WSTRB == 4'b1111;})
      `uvm_do_with(req, {req.BREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write address and data together
class data_with_addr extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(data_with_addr)

  function new(string name = "data_with_addr");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write address and data together ------ ", UVM_NONE)
    repeat(10) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111;})
      `uvm_do_with(req, {req.BREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Back to back write to same address and read
class continuous_write extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(continuous_write)
  int prev_addr, prev_data;

  function new(string name = "continuous_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Back to back write to same address and read ------ ", UVM_NONE)
    prev_addr = 0;
    repeat(10) begin
      `uvm_do_with(req, {req.AWADDR != prev_addr; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1;})
      prev_addr = req.AWADDR;
      prev_data = req.WDATA;

      `uvm_do_with(req, {req.AWADDR == prev_addr; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.WDATA != prev_data; req.BREADY == 1;})
      prev_data = req.WDATA;

      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write with strobe select and read back from the same address
class write_strobe_select_1 extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(write_strobe_select_1)
  int prev_addr;

  function new(string name = "write_strobe_select_1");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write with strobe select and read back from the same address  ------ ", UVM_NONE)
    repeat(25) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.AWSTRB inside {[0:15]}; req.BREADY == 1;})
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

class write_strobe_select_2 extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(write_strobe_select_2)
  int prev_addr;

  function new(string name = "write_strobe_select_2");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write with strobe select and read back from the same address  ------ ", UVM_NONE)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.AWSTRB == 4'b0001; req.BREADY == 1;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})

      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.AWSTRB == 4'b0010; req.BREADY == 1;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})

      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.AWSTRB == 4'b0100; req.BREADY == 1;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})
      
        `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.AWSTRB == 4'b1000; req.BREADY == 1;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Invalid Address Write and Read
class invalid_addr extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(invalid_addr)

  function new(string name = "invalid_addr");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Invalid Address Write and Read ------ ", UVM_NONE)
    repeat(10) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {!(req.ARADDR inside {0,4,8}); req.ARVALID == 1; req.RREADY == 1; req.AWADDR inside {0,4,8}); req.AWVALID == 1; req.WVALID == 1; req.AWSTRB == 4'b1111; req.BREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Interrupt High
class irq_seq_1 extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(irq_seq_1)

  function new(string name = "irq_seq_1");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Interrupt High ------ ", UVM_NONE)
    repeat(3) begin
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB[0] == 1; req.WDATA[0] == 1; req.WVALID == 1; req.BREADY == 1; req.ext_irq_in == 1;})
      #1000000;
      `uvm_do_with(req, {req.ARADDR == 8; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Interrupt 
/*
class irq_seq_2 extends uvm_sequence#(axi4_seq_item);
  `uvm_object_utils(irq_seq_2)

  function new(string name = "irq_seq_2");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Interrupt High ------ ", UVM_NONE)
    repeat(4) begin
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB[0] == 1; req.WDATA[0] == 1; req.WVALID == 1; req.BREADY == 1; req.ext_irq_in == 1;})
      #10_000;
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB[0] == 1; req.WDATA[0] == 1; req.WVALID == 1; req.BREADY == 1; req.ext_irq_in == 0;})
    end
  endtask
endclass
*/
// -----------------------------------------------------------------

