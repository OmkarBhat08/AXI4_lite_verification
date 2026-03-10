class axi4_subscriber extends uvm_component;

  uvm_tlm_analysis_fifo #(axi4_seq_item) monitor_fifo;

  axi4_seq_item op_item;

  real input_cov_res, output_cov_res;
  
  `uvm_component_utils(axi4_subscriber)


  //-------------------------------input coverage----------------------------//
  covergroup input_coverage with function sample(axi4_seq_item trans);
    option.per_instance = 1;

    // ----- AXI write address -----
    AWADDR_CP: coverpoint trans.AWADDR {
      bins led_reg = {'h00};
      bins seven_seg_reg = {'h04};
      bins irq_reg[2] = {'h08, 'h10};
      bins other = default; 
    }

    // Write data
    WDATA_CP: coverpoint trans.WDATA {
			bins wdata[4] = {[0:$]}; 
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
      bins led_reg = {'h00};
      bins seven_seg_reg = {'h04};
      bins irq_reg[2] = {'h08, 'h10};
      bins other = default;
    }

    // ----- External input signal -----
    EXT_IRQ_CP: coverpoint trans.ext_irq_in { 
      bins LOW  = {0};
      bins HIGH = {1};
    }

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
    LED_CP: coverpoint trans.leds {
      bins led_bins[4] = {[0:$]};
    }

    // 7-segment cathode 
    SEG_CATHODE_CP: coverpoint trans.seg_cathode { 
      bins off = {7'b111_1111};   
      bins digit0 = {7'b100_0000}; 
      bins digit1 = {7'b111_1001};
      bins digit2 = {7'b010_0100};
      bins digit3 = {7'b011_0000};
      bins digit4 = {7'b001_1001};
      bins digit5 = {7'b001_0010};
      bins digit6 = {7'b000_0010};
      bins digit7 = {7'b111_1000};
      bins digit8 = {7'b000_0000};
      bins digit9 = {7'b001_0000};

      bins digit_a = {7'b000_1000};
      bins digit_b = {7'b000_0011};
      bins digit_c = {7'b100_0110};
      bins digit_d = {7'b010_0001};
      bins digit_e = {7'b000_0110};
      bins digit_f = {7'b000_1110};
      bins others = default;      
    }

    // 7-segment anode 
    SEG_ANODE_CP: coverpoint trans.seg_anode {
      bins digit0 = {4'b1110};
      bins digit1 = {4'b1101};
      bins digit2 = {4'b1011};
      bins digit3 = {4'b0111};
      bins no_sel = {4'b1111};
      bins other  = default;
    }

    // Interrupt output
    IRQ_OUT_CP: coverpoint trans.irq_out { 
      bins LOW  = {0};
      bins HIGH = {1};
    }

    // AXI response crosses
    RDATA_X_RRESP: cross RDATA_CP, RRESP_CP {
      ignore_bins ignore_slverr = (binsof(RRESP_CP.SLVERR));
    }

  endgroup


  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    monitor_fifo = new("monitor_fifo", this);

    input_coverage  = new();
    output_coverage = new();
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever begin
      fork
        begin
          monitor_fifo.get(op_item);
          input_coverage.sample(op_item);
          output_coverage.sample(op_item);
        end
      join
    end
  endtask


  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);

    input_cov_res  = input_coverage.get_coverage();
  endfunction


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);

    `uvm_info(get_type_name(),$sformatf("[COVERAGE] Coverage -------> %0.2f%%",input_cov_res),UVM_LOW)
  endfunction

endclass
