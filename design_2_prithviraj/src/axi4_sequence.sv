class base_seq extends uvm_sequence #(axi4_seq_item);
  `uvm_object_utils(base_seq)
  
  function new(string name="base_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    axi4_seq_item req;
    `uvm_info(get_type_name(), " ------ Base Sequence ------ ", UVM_LOW)
    repeat (3) begin
      req = axi4_seq_item::type_id::create("req");
      start_item(req);
      assert(req.randomize() with { req.BREADY == 1;} );
      finish_item(req);
    end
  endtask
endclass

// -----------------------------------------------------------------
// Simple write with strobe = 'b1111
class simple_write extends base_seq;
  `uvm_object_utils(simple_write)

  function new(string name = "simple_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Simple write with strobe = 'b1111 ------ ", UVM_LOW)
    repeat(1) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR == 0; req.AWVALID == 1; req.WVALID == 1; req.BREADY == 1; req.WSTRB == 4'b1111; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == 4; req.AWVALID == 1; req.WVALID == 1; req.BREADY == 1; req.WSTRB == 4'b1111; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WVALID == 1; req.BREADY == 1; req.WSTRB == 4'b1111; req.ARVALID == 0; req.RREADY == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Simple read
class simple_read extends base_seq;
  `uvm_object_utils(simple_read)

  function new(string name = "simple_read");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Simple read ------ ", UVM_LOW)
    repeat(1) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.ARADDR == 0; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
      `uvm_do_with(req, {req.ARADDR == 4; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
      `uvm_do_with(req, {req.ARADDR == 8; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})

    end
  endtask
endclass

// -----------------------------------------------------------------
// Read followed by Write
class read_followed_by_write extends base_seq;
  `uvm_object_utils(read_followed_by_write)
  bit [`ADDR_WIDTH-1:0] prev_addr;

  function new(string name = "read_followed_by_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Read followed by Write ------ ", UVM_LOW)
    repeat(10) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.BREADY == 1; req.AWVALID == 0; req.WVALID == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Parallel Read and Write
class parallel_read_write extends base_seq;
  `uvm_object_utils(parallel_read_write)

  function new(string name = "parallel_read_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Parallel Read and Write ------ ", UVM_LOW)
      `uvm_do_with(req, {req.AWADDR == 0; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR == 0; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == 4; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR == 4; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR == 8; req.ARVALID == 0; req.RREADY == 0;})
    repeat(5) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write data before address
class data_before_addr extends base_seq;
  `uvm_object_utils(data_before_addr)

  function new(string name = "data_before_addr");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write data before address ------ ", UVM_LOW)
    repeat(6) begin
      `uvm_do_with(req, {req.AWVALID == 0; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR == 0; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR dist {0:=2,4:=2,8:=2}; req.AWVALID == 1; req.WSTRB == 4'b0; req.WVALID == 0; req.BREADY == 1; req.ARADDR == 0; req.ARVALID == 0; req.RREADY == 0;})

    end
  endtask
endclass

// -----------------------------------------------------------------
// Write address before data together
class addr_before_data extends base_seq;
  `uvm_object_utils(addr_before_data)

  function new(string name = "addr_before_data");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write address before data together ------ ", UVM_LOW)
    repeat(6) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WSTRB == 4'b0; req.WVALID == 0; req.BREADY == 1; req.ARADDR == 0; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == 0; req.AWVALID == 0; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR == 0; req.ARVALID == 0; req.RREADY == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write address and data together
class data_with_addr extends base_seq;
  `uvm_object_utils(data_with_addr)

  function new(string name = "data_with_addr");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write address and data together ------ ", UVM_LOW)
    repeat(3) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.BREADY == 1; req.WSTRB == 4'b1111; req.ARVALID == 0; req.RREADY == 0; })
 //     `uvm_do_with(req, {req.ARVALID == 0; req.RREADY == 0; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Back to back write to same address and read
class continuous_write extends base_seq;
  `uvm_object_utils(continuous_write)
  bit [`ADDR_WIDTH-1:0] prev_addr;
  bit [`DATA_WIDTH-1:0] prev_data;

  function new(string name = "continuous_write");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Back to back write to same address and read ------ ", UVM_LOW)
    repeat(3) begin
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      prev_data = req.WDATA;

      `uvm_do_with(req, {req.AWADDR == prev_addr; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.WDATA != prev_data; req.ARVALID == 0; req.RREADY == 0;})
      prev_data = req.WDATA;

      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Write with strobe select and read back from the same address
class write_strobe_select_1 extends base_seq;
  `uvm_object_utils(write_strobe_select_1)
  bit [`ADDR_WIDTH-1:0] prev_addr;

  function new(string name = "write_strobe_select_1");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write with strobe select and read back from the same address  ------ ", UVM_LOW)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB inside {[0:15]}; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
    end
  endtask
endclass

class write_strobe_select_2 extends base_seq;
  `uvm_object_utils(write_strobe_select_2)
  bit [`ADDR_WIDTH-1:0] prev_addr;

  function new(string name = "write_strobe_select_2");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Write with strobe select and read back from the same address  ------ ", UVM_LOW)
    repeat(3) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b0001; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 1;})

      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b0010; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 1;})

      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b0100; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 1;})

      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1000; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// BVALID Hold
class bvalid_hold_seq extends base_seq;
  `uvm_object_utils(bvalid_hold_seq)
  bit [`ADDR_WIDTH-1:0] prev_addr;

  function new(string name = "bvalid_hold_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), $sformatf(" ------ BVALID Hold ------ "), UVM_LOW)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111; req.BREADY == 0; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.AWADDR == prev_addr; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111; req.BREADY == 0; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == prev_addr; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111; req.BREADY == 0; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {req.AWADDR == prev_addr; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111; req.BREADY == 1; req.ARVALID == 0; req.RREADY == 0;})
    end
  endtask
endclass
// -----------------------------------------------------------------
// RVALID Hold
class rvalid_hold_seq extends base_seq;
  `uvm_object_utils(rvalid_hold_seq)
  bit [`ADDR_WIDTH-1:0] prev_addr;

  function new(string name = "rvalid_hold_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), $sformatf(" ------ BVALID Hold ------ "), UVM_LOW)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {req.AWADDR inside {0,4,8}; req.AWVALID == 1; req.WVALID == 1; req.WSTRB == 4'b1111; req.BREADY == 0; req.ARVALID == 0; req.RREADY == 0;})
      prev_addr = req.AWADDR;
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 0; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 0; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 0; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
      `uvm_do_with(req, {req.ARADDR == prev_addr; req.ARVALID == 1; req.RREADY == 1; req.AWVALID == 0; req.WVALID == 0; req.BREADY == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Invalid Address Write and Read
class invalid_addr extends base_seq;
  `uvm_object_utils(invalid_addr)

  function new(string name = "invalid_addr");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), $sformatf(" ------ invalid address write and read ------ "), UVM_LOW)
    repeat(5) begin
      req = axi4_seq_item::type_id::create("req");
      `uvm_do_with(req, {!(req.AWADDR inside {0,4,8,12}); req.AWVALID == 1; req.WVALID == 1; req.BREADY == 1; req.WSTRB == 4'b1111; req.ARVALID == 0; req.RREADY == 0;})
      `uvm_do_with(req, {!(req.ARADDR inside {0,4,8,12}); req.AWVALID == 0; req.WVALID == 0; req.BREADY == 1; req.WSTRB == 4'b1111; req.ARVALID == 1; req.RREADY == 1;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// Interrupt High
class irq_seq_1 extends base_seq;
  `uvm_object_utils(irq_seq_1)

  function new(string name = "irq_seq_1");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), $sformatf(" ------ Interrupt High ------ "), UVM_LOW)
    repeat(3) begin
      `uvm_do_with(req, {req.AWADDR == 'h10; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.WDATA[0] == 1; req.ext_irq_in == 1;})
      #1ms;
      `uvm_do_with(req, {req.AWADDR == 'h10; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.WDATA[0] == 1; req.ext_irq_in == 1;})
    end
  endtask
/*
  task body();
    `uvm_info(get_type_name(), $sformatf(" ------ Interrupt High ------ "), UVM_LOW)
    repeat(1) begin
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.ext_irq_in == 1;})
      #3ms;
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.ext_irq_in == 1;})
    end
  endtask
*/
endclass

// -----------------------------------------------------------------
// Interrupt 
class irq_seq_2 extends base_seq;
  `uvm_object_utils(irq_seq_2)

  function new(string name = "irq_seq_2");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Interrupt ------ ", UVM_LOW)
    repeat(3) begin
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB[0] == 1; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.ext_irq_in == 1;})
      #10_000;
      `uvm_do_with(req, {req.AWADDR == 8; req.AWVALID == 1; req.WSTRB[0] == 1; req.WVALID == 1; req.BREADY == 1; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.ext_irq_in == 0;})
    end
  endtask
endclass

// -----------------------------------------------------------------
// 7 segment 
class seven_seg_seq extends base_seq;
  `uvm_object_utils(seven_seg_seq)

  function new(string name = "seven_seg_seq");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ 7 segment ------ ", UVM_LOW)
    repeat(1) begin
      `uvm_do_with(req, {req.AWADDR == 4; req.AWVALID == 1; req.WSTRB == 4'b1111; req.WVALID == 1; req.BREADY == 1; req.WDATA == 32'h9876cdef; req.ARADDR inside {0,4,8}; req.ARVALID == 1; req.RREADY == 1; req.ext_irq_in == 1;})
      #2ms;
    end
  endtask
endclass

// -----------------------------------------------------------------
// Regression test 
class regression extends base_seq;
  `uvm_object_utils(regression)

  simple_write s1;
  simple_read s2;
  read_followed_by_write s3;
  parallel_read_write s4;
  data_before_addr s5;
  addr_before_data s6;
  data_with_addr s7;
  continuous_write s8;
  write_strobe_select_1 s9;
  write_strobe_select_2 s10;
  bvalid_hold_seq s11;
  rvalid_hold_seq s12;
  invalid_addr s13;
  irq_seq_1 s14;
  irq_seq_2 s15;
  seven_seg_seq s16;

  function new(string name = "regression");
    super.new(name);
  endfunction

  task body();
    `uvm_info(get_type_name(), " ------ Regression test ------ ", UVM_LOW)
    repeat(10) begin
      `uvm_do(s1)
      `uvm_do(s2)
      `uvm_do(s3)
      `uvm_do(s4)
      `uvm_do(s5)
      `uvm_do(s6)
      `uvm_do(s7)
      `uvm_do(s8)
      `uvm_do(s9)
      `uvm_do(s10)
      `uvm_do(s11)
      `uvm_do(s12)
      `uvm_do(s13)
    end
    `uvm_do(s14)
    `uvm_do(s15)
    `uvm_do(s16)
  endtask
endclass

// -----------------------------------------------------------------


