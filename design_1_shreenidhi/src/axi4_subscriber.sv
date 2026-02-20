class axi4_subscriber extends uvm_component;

  uvm_tlm_analysis_fifo #(axi4_seq_item) inp_fifo;
  uvm_tlm_analysis_fifo #(axi4_seq_item) op_fifo;

  axi4_seq_item inp_item, op_item;

  real input_cov_res, output_cov_res;
  
  `uvm_component_utils(axi4_subscriber)


  //-------------------------------input coverage----------------------------//
  covergroup input_coverage;
    // WRITE ADDRESS

    S_AWADDR_CP: coverpoint inp_item.S_AWADDR { bins LED = {32'h0};
                                               bins SEVENSEG = {32'h4};
                                               bins IRQ = {32'h8};
                                               bins INVALID = default;
                                              }
    
    S_AWVALID_CP: coverpoint inp_item.S_AWVALID { bins low ={0};
                                                bins high ={1};
                                               }
    S_AWREADY_CP: coverpoint inp_item.S_AWREADY { bins low ={0};
                                                 bins high ={1};
                                                }
    // WRITE DATA
    S_WDATA_CP : coverpoint inp_item.S_WDATA {
      bins data_val[] = {[0:255]};
    }

    S_WSTRB_CP : coverpoint inp_item.S_WSTRB {
      bins strobe_val[] = {[0:15]};
    }

    S_WVALID_CP : coverpoint inp_item.S_WVALID { bins low = {0}; 
                                         bins high = {1}; }
    S_WREADY_CP : coverpoint inp_item.S_WREADY { bins low = {0};
                                         bins high = {1}; }
    // READ ADDRESS
    S_ARADDR_CP : coverpoint inp_item.S_ARADDR {
      bins LED      = {32'h0};
      bins SEVENSEG = {32'h4};
      bins IRQ      = {32'h8};
      bins INVALID  = default;
    }

    S_ARVALID_CP : coverpoint inp_item.S_ARVALID { bins low = {0}; 
                                           bins high = {1}; }
                                                 
    S_ARREADY_CP : coverpoint inp_item.S_ARREADY { bins low = {0}; 
                                           bins high = {1}; } 
    // READ READY
    S_RREADY_CP : coverpoint inp_item.S_RREADY { bins low = {0};
                                          bins high = {1}; }

    // CROSS COVERAGE
    AWVALID_X_AWADDR   : cross S_AWVALID_CP, S_AWADDR_CP;
    AWADDR_X_WSTRB     : cross S_AWADDR_CP, S_WSTRB_CP;
    AWVALID_X_AWREADY  : cross S_AWVALID_CP, S_AWREADY_CP;
    WVALID_X_WREADY    : cross S_WVALID_CP, S_WREADY_CP;
    ARVALID_X_ARREADY  : cross S_ARVALID_CP, S_ARREADY_CP;                                           
  endgroup

                                                 
  //-----------------------------output coverage-----------------------------//
  covergroup output_coverage;
    // WRITE RESPONSE
    S_BVALID_CP : coverpoint op_item.S_BVALID { bins low = {0};
                                          bins high = {1}; }

    S_BRESP_CP : coverpoint op_item.S_BRESP {
      bins OKAY  = {2'b00};
    }

        // READ DATA
    S_RVALID_CP : coverpoint op_item.S_RVALID { bins low = {0}; 
                                         bins high = {1}; }

    S_RDATA_CP : coverpoint op_item.S_RDATA {
      bins data_val[] = {[0:255]};
    }

    S_RRESP_CP : coverpoint op_item.S_RRESP {
      bins OKAY  = {2'b00};
    }
    // EXTERNAL OUTPUTS
    LED_OUT_CP : coverpoint op_item.LED_OUT {
      bins led_vals[] = {[0:255]};
    }

    SEVENSEG_OUT_CP : coverpoint op_item.SEVENSEG_OUT {
      bins seg_vals[] = {[0:255]};
    }

    IRQ_OUT_CP : coverpoint op_item.IRQ_OUT {
      bins low = {0};
      bins high = {1};
    }

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

    `uvm_info(get_type_name(),$sformatf("[INPUT_COVERAGE] Coverage -------> %0.2f%%",input_cov_res),UVM_LOW)
    `uvm_info(get_type_name(),$sformatf("[OUTPUT_COVERAGE] Coverage ------> %0.2f%%",output_cov_res),UVM_LOW)
  endfunction

endclass
