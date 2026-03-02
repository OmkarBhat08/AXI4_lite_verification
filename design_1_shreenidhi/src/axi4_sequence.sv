class axi4_base_seq extends uvm_sequence #(axi4_seq_item);
  `uvm_object_utils(axi4_base_seq)
  
  function new(string name=""); 
    super.new(name); 
  endfunction
  
  task body();
    axi4_seq_item req;
    repeat (1) begin
      req = axi4_seq_item::type_id::create("req");
      start_item(req);
      req.randomize();
      finish_item(req);
    end
  endtask
endclass
//--------------------RESET------------------------------
class axi4_reset_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_reset_seq)
  
  function new(string name="axi4_reset_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WDATA == 32'h10;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 1;req.S_RREADY == 1;})//RESET assertion done in the top module global in this sequence during reset applying the valid information on the bus checking for the reset behavior
  endtask
endclass

//---------------------WRITE CHANNEL-------------------------------

class axi4_valid_write_handshake_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_valid_write_handshake_seq)
  
  function new(string name="axi4_valid_write_handshake_seq"); 
    super.new(name); 
  endfunction
  
  task body();
   `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WDATA == 32'h10;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})
     `uvm_do_with(req,{req.S_AWADDR == 32'h100;req.S_AWVALID == 1;req.S_WDATA == 32'h10;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h0;req.S_ARVALID == 1;req.S_RREADY == 1;})
  endtask
endclass

class axi4_address_before_data_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_address_before_data_seq)
  
  function new(string name="axi4_address_before_data_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WVALID == 0;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//data can be anything becasue its not valid || STROBE also can be anythig
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//address handshake completed so AWVALID == 0 
  endtask
endclass

class axi4_data_before_adress_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_data_before_adress_seq)
  
  function new(string name="axi4_data_before_adress_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//address is not valid AWVALID == 0 
    `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WVALID == 0;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//data handshake completed data can be anything becasue its not valid

  endtask
endclass

class axi4_response_check_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_response_check_seq)
  
  function new(string name="axi4_response_check_seq"); 
    super.new(name); 
  endfunction
  
  task body();
//     `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//valid address
    `uvm_do_with(req,{req.S_AWADDR == 32'h100;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//invalid address
    `uvm_do_with(req,{req.S_AWADDR == 32'h3;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//unaligned address
  endtask
endclass

class axi4_BVALID_hold_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_BVALID_hold_seq)
  
  function new(string name="axi4_BVALID_hold_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 0;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//valid address || valid data but bready = 0 for more than one cycle
    repeat(10)begin
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_BREADY == 0;req.S_ARVALID == 0;req.S_RREADY == 0;})//holding BVALID =0
    end
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;})//ready to accept the response
  endtask
endclass

class axi4_back_to_back_write_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_back_to_back_write_seq)
  
  function new(string name="axi4_back_to_back_write_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    bit [`ADDR_WIDTH -1 :0] ADDR;
    repeat(5)begin
      `uvm_do_with(req,{req.S_AWADDR == ADDR;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//valid address || valid data
      ADDR = (ADDR == 32'h8) ? 32'h0 : (ADDR + 32'h4);//continous writing to the consecutive address
    end
    repeat(5)begin
      `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//valid address || valid data countnious writing to the same address
    end
  endtask
endclass

class axi4_multiple_outstanding_write_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_multiple_outstanding_write_seq)
  
  function new(string name="axi4_multiple_outstanding_write_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_AWADDR < 32'h9;req.S_AWADDR % 4 == 0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 0;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//valid address || valid data but keping Bready =0
    end
  endtask
endclass

class axi4_invalid_address_write_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_invalid_address_write_seq)
  
  function new(string name="axi4_invalid_address_write_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_AWADDR > 32'h8;req.S_AWADDR % 4 == 0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//invalid address but aligned || valid data
    end
  endtask
endclass

class axi4_unaligned_address_write_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_unaligned_address_write_seq)
  
  function new(string name="axi4_unaligned_address_write_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_AWADDR < 32'h9;req.S_AWADDR % 4 != 0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR == 32'h04;req.S_ARVALID == 0;req.S_RREADY == 0;})//valid address but unaligned || valid data
    end
  endtask
endclass


//-------------------READ CHENNALE---------------------------------------

class axi4_valid_read_handshake_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_valid_read_handshake_seq)
  
  function new(string name="axi4_valid_read_handshake_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_ARADDR == 32'h04;req.S_ARVALID == 1;req.S_RREADY == 1;})
  endtask
endclass

class axi4_RVALID_hold_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_RVALID_hold_seq)
  
  function new(string name="axi4_RVALID_hold_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_ARADDR == 32'h04;req.S_ARVALID == 1;req.S_RREADY == 0;})//valid address rready = 0 for more than one cycle
    repeat(5)begin
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_ARVALID == 0;req.S_RREADY == 0;})//holding RVALID =0
    end
    `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_ARVALID == 0;req.S_RREADY == 1;})//ready to accept the response
  endtask
endclass

class axi4_back_to_back_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_back_to_back_read_seq)
  
  function new(string name="axi4_back_to_back_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    bit [`ADDR_WIDTH -1 :0] ADDR;
    repeat(5)begin
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == ADDR;req.S_ARVALID == 1;req.S_RREADY == 1;})//valid address 
      ADDR = (ADDR == 32'h8) ? 32'h0 : (ADDR + 32'h4);//continous writing to the consecutive address
    end
    repeat(5)begin
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h04;req.S_ARVALID == 1;req.S_RREADY == 1;})//valid address  countnious READING FROM  the same address
    end
  endtask
endclass

class axi4_multiple_outstanding_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_multiple_outstanding_read_seq)
  
  function new(string name="axi4_multiple_outstanding_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_ARADDR < 32'h9;req.S_ARADDR % 4 == 0;req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARVALID == 1;req.S_RREADY == 0;})//valid address  but keping rready =0
    end
  endtask
endclass

class axi4_invalid_address_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_invalid_address_read_seq)
  
  function new(string name="axi4_invalid_address_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_ARADDR > 32'h8;req.S_ARADDR % 4 == 0;req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARVALID == 1;req.S_RREADY == 1;})//invalid address but aligned 
    end
  endtask
endclass

class axi4_unaligned_address_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_unaligned_address_read_seq)
  
  function new(string name="axi4_unaligned_address_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_ARADDR < 32'h9;req.S_ARADDR % 4 != 0;req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 1;req.S_ARVALID == 1;req.S_RREADY == 1;})//valid address but unaligned 
    end
  endtask
endclass


class axi4_concurrent_write_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_concurrent_write_read_seq)
  
  function new(string name="axi4_concurrent_write_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(10)begin
      `uvm_do_with(req,{req.S_AWADDR inside{[32'h0:32'h8]};req.S_AWADDR %4 == 0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WSTRB == 15;req.S_BREADY == 1;req.S_ARADDR inside{[32'h0:32'h8]};req.S_ARADDR %4 == 0;req.S_ARVALID == 1;req.S_RREADY == 1;req.S_AWADDR != req.S_ARADDR;})//just to avoid race arround condition if writing and reading to the same location may cause race 
    end
  endtask
endclass

//-------------------------LED REDISTER------------------------
class axi4_led_write_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_led_write_read_seq)
  
  function new(string name="axi4_led_write_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(1)begin
      `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;req.S_WSTRB==15;}) 
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h0;req.S_ARVALID == 1;req.S_RREADY == 1;}) 
    end
  endtask
endclass

//----------------------------SEGMENT REGISTER---------------------
class axi4_segment_write_read_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_segment_write_read_seq)
  
  function new(string name="axi4_segment_write_read_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(20)begin
      `uvm_do_with(req,{req.S_AWADDR == 32'h4;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;}) 
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h4;req.S_ARVALID == 1;req.S_RREADY == 1;}) 
    end
  endtask
endclass

//---------------------------INTERRUPT REGISTER--------------
class axi4_interrupt_assert_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_interrupt_assert_seq)
  
  function new(string name="axi4_interrupt_assert_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(20)begin
      `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_WSTRB == 15;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WDATA != 32'hFFFF_FFFF;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;}) //writing led register except FFFF_FFFF
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h0;req.S_ARVALID == 1;req.S_RREADY == 1;})//raeding from the same
      
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h8;req.S_ARVALID == 1;req.S_RREADY == 1;})//reading from interrupt register
      
      `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_WSTRB == 15;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WDATA == 32'hFFFF_FFFF;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;}) //writing led register  FFFF_FFFF
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h0;req.S_ARVALID == 1;req.S_RREADY == 1;})//raeding from the same
      
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h8;req.S_ARVALID == 1;req.S_RREADY == 1;})//reading from interrupt register
    end
  endtask
endclass

class axi4_interrupt_deassert_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_interrupt_deassert_seq)
  
  function new(string name="axi4_interrupt_deassert_seq"); 
    super.new(name); 
  endfunction
  
  task body();
    repeat(20)begin
      `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_WSTRB == 15;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WDATA != 32'hFFFF_FFFF;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;}) //writing led register except FFFF_FFFF
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h0;req.S_ARVALID == 1;req.S_RREADY == 1;})//raeding from the same
      
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h8;req.S_ARVALID == 1;req.S_RREADY == 1;})//reading from interrupt register
      
      `uvm_do_with(req,{req.S_AWADDR == 32'h0;req.S_WSTRB == 15;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WDATA == 32'hFFFF_FFFF;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;}) //writing led register  FFFF_FFFF
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h0;req.S_ARVALID == 1;req.S_RREADY == 1;})//raeding from the same
      
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h8;req.S_ARVALID == 1;req.S_RREADY == 1;})//reading from interrupt register
      
      `uvm_do_with(req,{req.S_AWADDR == 32'h8;req.S_AWVALID == 1;req.S_WVALID == 1;req.S_WDATA[0] == 1;req.S_WSTRB[0] == 1;req.S_BREADY == 1;req.S_ARVALID == 0;req.S_RREADY == 0;})//writing 1 to  interrupt register
      
      `uvm_do_with(req,{req.S_AWVALID == 0;req.S_WVALID == 0;req.S_BREADY == 0;req.S_ARADDR == 32'h8;req.S_ARVALID == 1;req.S_RREADY == 1;})//reading from interrupt register
    end
  endtask
endclass


class axi4_regression_seq extends axi4_base_seq;
  `uvm_object_utils(axi4_regression_seq)
  
  function new(string name="axi4_regression_seq"); 
    super.new(name); 
  endfunction
  //------------RESET-----------------
  axi4_reset_seq reset_seq;
  
  //-----------------WRITE-------------------------
  axi4_valid_write_handshake_seq valid_write_handshake_seq;
  axi4_address_before_data_seq address_before_data_seq ;
  axi4_data_before_adress_seq data_before_adress_seq;
  axi4_response_check_seq response_check_seq;
  axi4_BVALID_hold_seq BVALID_hold_seq;
  axi4_back_to_back_write_seq back_to_back_write_seq;
  axi4_invalid_address_write_seq invalid_address_write_seq;
  axi4_unaligned_address_write_seq unaligned_address_write_seq;
  axi4_multiple_outstanding_write_seq multiple_outstanding_write_seq;
  
  //----------------------READ-----------------------
  axi4_valid_read_handshake_seq valid_read_handshake_seq ;
  axi4_RVALID_hold_seq RVALID_hold_seq ;
  axi4_back_to_back_read_seq ack_to_back_read_seq;
  axi4_multiple_outstanding_read_seq multiple_outstanding_read_seq;
  axi4_invalid_address_read_seq invalid_address_read_seq;
  axi4_unaligned_address_read_seq unaligned_address_read_seq;
  
  //------------------CONCURRENT WRITE READ --------------------------
  
  axi4_concurrent_write_read_seq concurrent_write_read_seq ;
 
  //-------------------------LED REDISTER------------------------
  axi4_led_write_read_seq led_write_read_seq;
  
  //-------------------------SEGMENT REDISTER------------------------
  axi4_segment_write_read_seq segment_write_read_seq;
  
  //-------------------------INTERRUPT REDISTER------------------------
  axi4_interrupt_assert_seq interrupt_assert_seq;
  axi4_interrupt_deassert_seq interrupt_deassert_seq;
  
  
  task body();
    //-------------RESET SEQUENCE------------------------------
    `uvm_do(reset_seq)
    
    //-------------WRITE CHANNEL SEQUENCE-----------------------
    `uvm_do(valid_write_handshake_seq)
    `uvm_do(address_before_data_seq )
    `uvm_do(data_before_adress_seq)
    `uvm_do(response_check_seq)
    `uvm_do(BVALID_hold_seq)
    `uvm_do(back_to_back_write_seq)
    `uvm_do(invalid_address_write_seq)
    `uvm_do(unaligned_address_write_seq)
    `uvm_do(multiple_outstanding_write_seq)
    
    //----------------READ CHANNEL SEQUENCE------------------------
    `uvm_do(valid_read_handshake_seq )
    `uvm_do(RVALID_hold_seq )
    `uvm_do(ack_to_back_read_seq )
    `uvm_do(multiple_outstanding_read_seq )
    `uvm_do(invalid_address_read_seq )
    `uvm_do(unaligned_address_read_seq )
    
    //--------------CONCURRENT WRITE READ---------------------------
    `uvm_do(concurrent_write_read_seq)
    
    //-------------------------LED REDISTER------------------------
    `uvm_do(led_write_read_seq)
    
    //-------------------------SEGMENT REDISTER------------------------
    `uvm_do(segment_write_read_seq)
    
    //-------------------------INTERRUPT REDISTER-----------------------
    `uvm_do(interrupt_assert_seq)
    `uvm_do(interrupt_deassert_seq)

    
  endtask
endclass
