class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard)

  axi4_seq_item active_txn, passive_txn;

  //----Analysis FIFO's for collecting transactions---//
  uvm_tlm_analysis_fifo #(axi4_seq_item) active_fifo;
  uvm_tlm_analysis_fifo #(axi4_seq_item) passive_fifo;


  //--------------new constructor-------------------//
  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    active_fifo  = new("active_fifo", this);
    passive_fifo = new("passive_fifo", this);

  endfunction


  //------------------run phase----------------------//
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      fork
        begin
          active_fifo.get(active_txn);
          passive_fifo.get(passive_txn);
          assign_expected(active_txn, passive_txn);
        end
      join
    end
  endtask


  //------------------- comparison------------------//
  task assign_expected(axi4_seq_item exp_txn,axi4_seq_item actual_txn);
  endtask

endclass
