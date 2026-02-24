class axi4_subscriber extends uvm_component;

  uvm_tlm_analysis_fifo #(axi4_seq_item) inp_fifo;
  uvm_tlm_analysis_fifo #(axi4_seq_item) op_fifo;

  axi4_seq_item inp_item, op_item;

  real input_cov_res, output_cov_res;
  
  `uvm_component_utils(axi4_subscriber)


  //-------------------------------input coverage----------------------------//
  covergroup input_coverage with function sample(axi4_seq_item trans);
    option.per_instance = 1;

    // ----- AXI write address -----
    AWADDR_CP: coverpoint trans.AWADDR {
      bins LED_CONTROL_REGISTER = {'h00};
      bins DATA_REGISTER = {'h04};
      bins IRQ_STATUS_REGISTER = {'h08};
      bins RESERVED = {'h0C};
    }

    // Write protection
    AWPROT_CP: coverpoint trans.AWPROT {
      bins DATA_SECURE_UNPRIV   = {0};
      bins DATA_SECURE_PRIV     = {1};
      bins DATA_NONSECURE_UNPRIV = {2};
      bins DATA_NONSECURE_PRIV   = {3};
      illegal_bins INSTR_SECURE_UNPRIV   = {4};
			illegal_bins INSTR_SECURE_PRIV     = {5};
      illegal_bins INSTR_NONSECURE_UNPRIV = {6};
      illegal_bins INSTR_NONSECURE_PRIV   = {7};
    }

    // Write data
    WDATA_CP: coverpoint trans.WDATA {
			//option.auto_bin_max = ;
			bins DATA[] = {[0:32'hFFFF]}; 
    }

    // Write strobe
    WSTRB_CP: coverpoint trans.WSTRB {
      bins SINGLE_BIT = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
      bins TWO_BITS   = {4'b0011, 4'b0110, 4'b1100, 4'b1001, 4'b0101, 4'b1010};
      bins THREE_BITS = {4'b0111, 4'b1110, 4'b1101, 4'b1011};
      bins ALL_ZEROS  = {4'b0000};
      bins ALL_ONES   = {4'b1111};
    }

    // ----- AXI read address -----
    ARADDR_CP: coverpoint trans.ARADDR {
      bins LED_CONTROL_REGISTER = {'h00};
      bins DATA_REGISTER = {'h04};
      bins IRQ_STATUS_REGISTER = {'h08};
      bins RESERVED = {'h0C};
    }

    // Read protection
    ARPROT_CP: coverpoint trans.ARPROT {
      bins DATA_SECURE_UNPRIV   = {0};
      bins DATA_SECURE_PRIV     = {1};
      bins DATA_NONSECURE_UNPRIV = {2};
      bins DATA_NONSECURE_PRIV   = {3};
      illegal_bins INSTR_SECURE_UNPRIV   = {4};
			illegal_bins INSTR_SECURE_PRIV     = {5};
      illegal_bins INSTR_NONSECURE_UNPRIV = {6};
      illegal_bins INSTR_NONSECURE_PRIV   = {7};
    }

    // ----- External input signal -----
    EXT_IRQ_CP: coverpoint trans.EXT_IRQ_IN { 
      bins LOW  = {0};
      bins HIGH = {1};
    }

    // crosses 
    AWPROT_X_WDATA: cross AWPROT_CP, WDATA_CP;
    ARPROT_X_EXT_IRQ: cross ARPROT_CP, EXT_IRQ_CP;

  endgroup


  //-----------------------------output coverage-----------------------------//
  covergroup output_coverage with function sample(axi4_seq_item trans);
    option.per_instance = 1;

    // Read data
    RDATA_CP: coverpoint trans.RDATA {
      bins MAX    = {32'hFFFF_FFFF};
      bins ZERO   = {32'h0000_0000};
      bins TOGGLE = {32'hAAAA_AAAA};
      bins ANY    = {[1:$]};
    }

    // Read response
    RRESP_CP: coverpoint trans.RRESP {
      bins OKAY   = {2'b00};
      bins EXOKAY = {2'b01};
      bins SLVERR = {2'b10};
      bins DECERR = {2'b11};
    }

    // Write response
    BRESP_CP: coverpoint trans.BRESP {
      bins OKAY   = {2'b00};
      bins EXOKAY = {2'b01};
      bins SLVERR = {2'b10};
      bins DECERR = {2'b11};
    }

    // ----- External output signals -----
    // LED output
    LED_CP: coverpoint trans.LED {
      bins ALL_OFF = {4'b0000};
      bins ALL_ON  = {4'b1111};
      bins ONE_HOT = {4'b0001, 4'b0010, 4'b0100, 4'b1000};
      bins PATTERN = {[1:14]};       // all other combinations
    }

    // 7-segment cathode 
    SEG_CATHODE_CP: coverpoint trans.SEG_CATHODE { // 7-bit
      bins ALL_OFF = {7'b111_1111};   
      bins ALL_ON  = {7'b000_0000};  
      bins DIGIT_0 = {7'b100_0000}; 
      bins DIGIT_1 = {7'b111_1001};
      bins DIGIT_2 = {7'b010_0100};
      bins DIGIT_3 = {7'b011_0000};
      bins DIGIT_4 = {7'b001_1001};
      bins DIGIT_5 = {7'b001_0010};
      bins DIGIT_6 = {7'b000_0010};
      bins DIGIT_7 = {7'b111_1000};
      bins DIGIT_8 = {7'b000_0000};
      bins DIGIT_9 = {7'b001_0000};
      bins OTHER   = default;      
    }

    // 7-segment anode 
    SEG_ANODE_CP: coverpoint trans.SEG_ANODE {
      bins DIGIT0 = {4'b1110};
      bins DIGIT1 = {4'b1101};
      bins DIGIT2 = {4'b1011};
      bins DIGIT3 = {4'b0111};
      bins NONE   = {4'b1111};
      bins OTHER  = default;
    }

    // Interrupt output
    IRQ_OUT_CP: coverpoint trans.IRQ_OUT {   // 1-bit
      bins LOW  = {0};
      bins HIGH = {1};
    }

    // Cross
    LED_X_IRQ: cross LED_CP, IRQ_OUT_CP;

    // AXI response crosses
    RDATA_X_RRESP: cross RDATA_CP, RRESP_CP {
      ignore_bins ignore_slverr = (binsof(RRESP_CP.SLVERR));
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
          input_coverage.sample(inp_item);
        end

        begin
          op_fifo.get(op_item);
          output_coverage.sample(op_item);
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
