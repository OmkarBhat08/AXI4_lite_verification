class axi4_subscriber extends uvm_subscriber #(axi4_seq_item);

  uvm_tlm_analysis_fifo #(axi4_seq_item) inp_fifo;
  uvm_tlm_analysis_fifo #(axi4_seq_item) op_fifo;

  axi4_seq_item inp_item, op_item;

  real input_cov_res, output_cov_res;
  
  `uvm_component_utils(axi4_subscriber)


  //-------------------------------input coverage----------------------------//
  covergroup input_coverage;
  endgroup

  //-----------------------------output coverage-----------------------------//
  covergroup output_coverage;
  endgroup

  
  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    inp_fifo = new("inp_fifo", this);
    op_fifo  = new("op_fifo", this);

    input_coverage  = new();
    output_coverage = new();
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      fork
        begin
          inp_fifo.get(inp_item);
          input_coverage.sample();
        end

        begin
          op_fifo.get(op_item);
          output_coverage.sample();
        end
      join
    end
  endtask


  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);

    input_cov_res  = input_coverage.get_coverage();
    output_cov_res = output_coverage.get_coverage();
  endfunction


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(get_type_name(),
              $sformatf("[INPUT_COVERAGE] Coverage -------> %0.2f%%",
                        input_cov_res),
              UVM_LOW)

    `uvm_info(get_type_name(),
              $sformatf("[OUTPUT_COVERAGE] Coverage ------> %0.2f%%",
                        output_cov_res),
              UVM_LOW)
  endfunction

endclass
