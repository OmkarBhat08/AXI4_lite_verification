class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard)
   
  axi4_rd_seq_item   rd_txn, exp_rd_txn;
  axi4_wrt_seq_item  wrt_txn, exp_wrt_txn;

  //----Analysis FIFO's for collecting transactions---//
  uvm_tlm_analysis_fifo #(axi4_rd_seq_item)  read_fifo;
  uvm_tlm_analysis_fifo #(axi4_wrt_seq_item) write_fifo;

  //--------------new constructor-------------------//
  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    read_fifo  = new("read_fifo", this);
    write_fifo = new("write_fifo", this);

    exp_rd_txn  = axi4_rd_seq_item::type_id::create("exp_rd_txn");
    exp_wrt_txn = axi4_wrt_seq_item::type_id::create("exp_wrt_txn");
  endfunction
 
  //------------------run phase----------------------//
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin

      rd_txn  = axi4_rd_seq_item::type_id::create("rd_txn");
      wrt_txn = axi4_wrt_seq_item::type_id::create("wrt_txn");

      fork
        begin
          read_fifo.get(rd_txn);
          compare_read(rd_txn);
        end

        begin
          write_fifo.get(wrt_txn);
          compare_write(wrt_txn);
        end
      join_any

    end
  endtask

  //-----------read transaction comparison------//
  task compare_read(axi4_rd_seq_item actual_rd_txn);
  endtask

  //-----------write transaction comparison-------//
  task compare_write(axi4_wrt_seq_item actual_wrt_txn);
  endtask  

endclass

