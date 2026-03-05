class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard) 

  axi4_seq_item monitor_txn;
  axi4_seq_item exp_txn;

  bit [3:0] write_states, read_states;
	bit write_done, read_done;
  bit [3:0] wstrb;
  int index;
  bit [(`DATA_WIDTH)-1:0] temp_data, mask, masked_data;
	int write_pass_count, write_fail_count, read_pass_count, read_fail_count, led_fail_count, seg_anode_fail_count, seg_cathode_fail_count, irq_out_fail_count;

  // Register bank
  bit [(`DATA_WIDTH)-1:0] mem [0:25];

  // For 7 segment driver
  bit [(`DATA_WIDTH)-1:0] segment_data;
	bit [6:0] temp_seg_cathode;
  longint segment_counter;

  // For LED driver
  bit [(`DATA_WIDTH)-1:0] led_data;

  // For Interrupt generation
  longint irq_counter;

  //----Analysis FIFO's for collecting transactions---//
  uvm_tlm_analysis_fifo #(axi4_seq_item) monitor_fifo;

  //--------------new constructor-------------------//
  function new(string name = "", uvm_component parent);
    super.new(name, parent);

    exp_txn = new();
    monitor_fifo  = new("monitor_fifo", this);
  endfunction : new


  //------------------run phase----------------------//
  task run_phase(uvm_phase phase);
    super.run_phase(phase);

    forever
    begin
      monitor_fifo.get(monitor_txn);
      // IRQ_STATUS updation
      if(monitor_txn.ext_irq_in)
        irq_counter++;
      else
        irq_counter = 0;

      if(irq_counter == 1_00_001)
          mem[12] = 1;

    	`uvm_info(get_type_name(), $sformatf("\n--------------------------------------------Scoreboard @ %0t---------------------------------------------", $time), UVM_MEDIUM)
      fork
        write_operation(monitor_txn);
        read_operation(monitor_txn);
      join
      seven_segment_driver();
      led_driver();
      transaction_checker();
    end
  endtask : run_phase

  //------------------- Write Operation ------------------//
  task write_operation(axi4_seq_item monitor_txn);
    if(!monitor_txn.ARESETn)
    begin
      `uvm_info("All Write Channels","Reset Applied", UVM_MEDIUM)
      write_states = 0;
      read_states = 0;
      exp_txn = new();
      `uvm_info("SCOREBOARD", "SCOREBOARD in reset", UVM_MEDIUM)
    end
    else
    begin
      // AW CHANNEL
      if(monitor_txn.AWVALID && monitor_txn.AWREADY)
      begin
        exp_txn.AWADDR = monitor_txn.AWADDR;
        `uvm_info("AW Channel", $sformatf("Received AWADDR = %0h when AWVALID = %b and AWREADY = %b", monitor_txn.AWADDR, monitor_txn.AWVALID, monitor_txn.AWREADY), UVM_MEDIUM)
        write_states = 1;
      end

      // W Channel
      if(monitor_txn.WVALID && monitor_txn.WREADY)
      begin
        if(exp_txn.AWADDR == 0) // LED_CTRL
        begin
          if(monitor_txn.WSTRB[0])
          begin
            mem[exp_txn.AWADDR] = {{(`DATA_WIDTH-8){1'b0}}, monitor_txn.WDATA[7:0]};
            `uvm_info("W Channel", $sformatf("Writing WDATA = %0h to LED when WVALID = %b and WREADY = %b", monitor_txn.WDATA, monitor_txn.WVALID, monitor_txn.WREADY), UVM_MEDIUM)
          end
        end
        else if(exp_txn.AWADDR == 4 )  // SEG_DATA
        begin
          wstrb = monitor_txn.WSTRB;
          index = 0;
          for(int i=0; i<(`DATA_WIDTH/8); i++) // For each strobe bit
          begin
            for(int j=0; j<8;j++) // for each byte
            begin
              if((wstrb>>i)&'d1)
                mask[index] = 1;
              else
                mask[index] = 0;
              index++;
            end
          end
          masked_data = (mem[exp_txn.AWADDR] & (~mask)) | (monitor_txn.WDATA & mask);
          mem[exp_txn.AWADDR] = {{(`DATA_WIDTH-16){1'b0}}, masked_data[15:0]};
          `uvm_info("W Channel", $sformatf("Writing WDATA = %0h to 7 segment when WVALID = %b and WREADY = %b", monitor_txn.WDATA, monitor_txn.WVALID, monitor_txn.WREADY), UVM_MEDIUM)
        end
        else if(exp_txn.AWADDR == 8) // IRQ_EN
        begin
          if(monitor_txn.WSTRB[0])
          begin
            `uvm_info("W Channel", "Accessing IRQ_EN", UVM_MEDIUM)
            mem[exp_txn.AWADDR] = {{(`DATA_WIDTH-2){1'b1}},monitor_txn.WDATA[0]};
          end
        end
        else if(exp_txn.AWADDR == 12) // IRQ_STATUS
        begin
          `uvm_error("W Channel", $sformatf("Writing to the address %0h is not allowed, address is readonly", monitor_txn.AWADDR))
        end
        else if(exp_txn.AWADDR == 16) // IRQ_CLEAR
          if(monitor_txn.WSTRB[0] && monitor_txn.WDATA[0])
          begin
            mem[12] = 0;
            `uvm_info("W Channel", "Clearing IRQ STATUS", UVM_MEDIUM)
          end
        else
          `uvm_error("W Channel", $sformatf("Writing to the address %0h is not allowed", monitor_txn.AWADDR))

        //Printing
        `uvm_info("W Channel", "Writing WDATA", UVM_MEDIUM)
        $display("WVALID \t %b", monitor_txn.WVALID);
        $display("WREADY \t %b", monitor_txn.WREADY);
        $display("WSTRB \t %b", monitor_txn.WSTRB);
        $display("WDATA \t %0h", monitor_txn.WDATA);

        write_states = 3;
      end

      // B Channel
      if(monitor_txn.BVALID)
      begin
        if(write_states != 3)
        begin
          if(!write_states[0])
            `uvm_error("B Channel", "Handshake Failed: BVALID asserted before AW Channel Operation completed")
          else if(!write_states[1])
            `uvm_error("B Channel", "Handshake Failed: BVALID asserted before W Channel Operation completed")
          else
            `uvm_error("B Channel", "Handshake Failed: BVALID asserted before AW or W Channel Operation completed")
          write_states = 0;
        end
        else
        begin
          if(monitor_txn.BREADY)
          begin
            `uvm_info("B Channel", $sformatf("Received BRESP = %b when BVALID = %b and BREADY = %b", monitor_txn.BRESP, monitor_txn.BVALID, monitor_txn.BREADY), UVM_MEDIUM)
						if(monitor_txn.BRESP === 0)
						begin
      				`uvm_info("CHECKER", $sformatf("CHECKER PASSED : BRESP\n Expected: 0 \n Received: %0d", monitor_txn.BRESP), UVM_MEDIUM)
							write_pass_count++;
						end
    				else
						begin
      				`uvm_error("CHECKER", $sformatf("CHECKER FAILED : BRESP\n Expected: 0 \n Received: %0d", monitor_txn.BRESP))
							write_fail_count++;
						end

            write_states = 0;
						write_done = 1;
            `uvm_info("B Channel", "Write handshake completed", UVM_MEDIUM)
            `uvm_info(get_type_name(), "SUCCESSFULLY WRITTEN INTO THE REGISTER BANK", UVM_MEDIUM)
          end
        end
      end
    end
  endtask : write_operation

  //------------------- Read Operation ------------------//
  task read_operation(axi4_seq_item monitor_txn);
    if(!monitor_txn.ARESETn)
    begin
      read_states = 0;
      exp_txn = new();
      `uvm_info("SCOREBOARD", "SCOREBOARD in reset", UVM_MEDIUM)
    end
    else
    begin
      // AR CHANNEL
      if(monitor_txn.ARVALID && monitor_txn.ARREADY)
      begin
        exp_txn.ARADDR = monitor_txn.ARADDR;
        exp_txn.RDATA = mem[exp_txn.ARADDR];
        `uvm_info("AR Channel", $sformatf("Received ARADDR = %0h when ARVALID = %b and ARREADY = %b", monitor_txn.ARADDR, monitor_txn.ARVALID, monitor_txn.ARREADY), UVM_MEDIUM)
        read_states = 1;
      end

      // R Channel
      if(monitor_txn.RVALID)
      begin
        exp_txn.RVALID = monitor_txn.RVALID;
        if(!read_states[0])
          `uvm_error("R Channel", "Handshake Failed: RVALID asserted before AR Channel operation completed")
        else
        begin
          if(monitor_txn.RREADY)
          begin
            exp_txn.RRESP = monitor_txn.RRESP;
            `uvm_info("B Channel", "Read handshake completed", UVM_MEDIUM)
						read_done = 1;

            //Printing
            `uvm_info("R Channel", "Read RDATA", UVM_MEDIUM)
            $display("RVALID \t %b", monitor_txn.RVALID);
            $display("RREADY \t %b", monitor_txn.RREADY);
            $display("RDATA \t %0h", monitor_txn.RDATA);
            $display("RRESP \t %0h", monitor_txn.RRESP);

    				if(monitor_txn.RDATA === exp_txn.RDATA)
      				`uvm_info("CHECKER", $sformatf("CHECKER PASSED : RDATA\n Expected: %0h \n Received: %0h",exp_txn.RDATA, monitor_txn.RDATA), UVM_MEDIUM)
    				else
      				`uvm_error("CHECKER", $sformatf("CHECKER FAILED : RDATA\n Expected: %0h \n Received: %0h",exp_txn.RDATA, monitor_txn.RDATA))

    				if(monitor_txn.RRESP === 0)
      				`uvm_info("CHECKER", $sformatf("CHECKER PASSED : RRESP\n Expected: 0 \n Received: %0d", monitor_txn.RRESP), UVM_MEDIUM)
    				else
      				`uvm_error("CHECKER", $sformatf("CHECKER FAILED : RRESP\n Expected: 0 \n Received: %0d", monitor_txn.RRESP))

						if((exp_txn.RDATA === monitor_txn.RDATA) && (monitor_txn.RRESP == 0))
						begin
							$display("Read transaction PASSED");
							read_pass_count++;
						end
						else
						begin
							$display("Read transaction FAILED");
							read_fail_count++;
						end
          end
        end
      end
		end
  endtask : read_operation

  //------------------- Seven Segment driver ------------------//
  task seven_segment_driver();
		$display("segment_counter: %0d", segment_counter);
    segment_data = mem[4];
		if(!monitor_txn.ARESETn || segment_counter==0)
		begin
      exp_txn.seg_cathode = decode_7_segment(0);
			temp_seg_cathode = decode_7_segment(segment_data[3:0]);
      exp_txn.seg_anode = 4'b1110;
		end	
		else if(segment_counter < 25000) // Digit 1
    begin
      exp_txn.seg_cathode = temp_seg_cathode;
			temp_seg_cathode = decode_7_segment(segment_data[3:0]);
      exp_txn.seg_anode = 4'b1110;
    end
    else if((segment_counter > 25000) && (segment_counter < 50000)) // Digit 2
    begin
      exp_txn.seg_cathode = temp_seg_cathode;
      temp_seg_cathode = decode_7_segment(segment_data[7:4]);
      exp_txn.seg_anode = 4'b1101;
    end
    else if((segment_counter > 50000) && (segment_counter < 75000)) // Digit 3
    begin
      exp_txn.seg_cathode = temp_seg_cathode;
      temp_seg_cathode = decode_7_segment(segment_data[11:8]);
      exp_txn.seg_anode = 4'b1011;
    end
    else if(segment_counter > 75000)  // Digit 4
    begin
      exp_txn.seg_cathode = temp_seg_cathode;
      temp_seg_cathode = decode_7_segment(segment_data[15:12]);
      exp_txn.seg_anode = 4'b0111;
    end
    else  // ALl off
    begin
      exp_txn.seg_cathode = temp_seg_cathode;
      temp_seg_cathode =  7'hFF;
      exp_txn.seg_anode = 4'b1111;
    end
    segment_counter++;
  endtask : seven_segment_driver

  //------------------- 7 segment decoder------------------//
  function bit [6:0] decode_7_segment(bit[3:0] val);
    case (val)
        4'h0: return(7'b1000000);  // 0  hex  40
        4'h1: return(7'b1111001);  // 1  hex  79
        4'h2: return(7'b0100100);  // 2  hex  24 
        4'h3: return(7'b0110000);  // 3  hex  30
        4'h4: return(7'b0011001);  // 4  hex  19
        4'h5: return(7'b0010010);  // 5  hex  12
        4'h6: return(7'b0000010);  // 6  hex  2
        4'h7: return(7'b1111000);  // 7  hex  78
        4'h8: return(7'b0000000);  // 8  hex  0
        4'h9: return(7'b0010000);  // 9  hex  10
        4'hA: return(7'b0001000);  // A  hex  8 
        4'hB: return(7'b0000011);  // B  hex  3
        4'hC: return(7'b1000110);  // C  hex  46 
        4'hD: return(7'b0100001);  // D  hex  21
        4'hE: return(7'b0000110);  // E  hex  6
        4'hF: return(7'b0001110);  // F  hex  e
        default: return(7'b1111111);  // hex  7F
    endcase
  endfunction : decode_7_segment
  //------------------- LED driver ------------------//
  task led_driver();
    led_data = mem[0];
    exp_txn.leds = led_data[7:0];
  endtask : led_driver

  //------------------- checker ------------------//
  task transaction_checker();
			$display("ARESETn:  %b", monitor_txn.ARESETn);
			$display("Expected ARADDR:  %0h", exp_txn.ARADDR);
		
		foreach(mem[i])
			$display("Address:  %0h |  Data: %0h", i, mem[i]);

    `uvm_info(get_type_name(), $sformatf("--------------------CHECKER Scoreboard @ %0t-----------------------------", $time), UVM_MEDIUM)

    if(exp_txn.leds !== monitor_txn.leds)
		begin
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : leds\n Expected: %b \n Received: %b",exp_txn.leds, monitor_txn.leds))
			led_fail_count++;
		end
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : leds\n Expected: %b \n Received: %b",exp_txn.leds, monitor_txn.leds), UVM_MEDIUM)

    if(exp_txn.seg_cathode !== monitor_txn.seg_cathode)
		begin
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : seg_cathode\n Expected: %0h \n Received: %0h",exp_txn.seg_cathode, monitor_txn.seg_cathode))
			seg_cathode_fail_count++;
		end
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : seg_cathode\n Expected: %0h \n Received: %0h",exp_txn.seg_cathode, monitor_txn.seg_cathode), UVM_MEDIUM)

    if(exp_txn.seg_anode !== monitor_txn.seg_anode)
		begin
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : seg_anode\n Expected: %0h \n Received: %0h",exp_txn.seg_anode, monitor_txn.seg_anode))
			seg_anode_fail_count++;
		end
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : seg_anode\n Expected: %0h \n Received: %0h",exp_txn.seg_anode, monitor_txn.seg_anode), UVM_MEDIUM)

    if(exp_txn.irq_out !== monitor_txn.irq_out)
		begin
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : irq_out\n Expected: %b \n Received: %b",exp_txn.irq_out, monitor_txn.irq_out))
			irq_out_fail_count++;
		end
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : irq_out\n Expected: %b \n Received: %b",exp_txn.irq_out, monitor_txn.irq_out), UVM_MEDIUM)

		$display("TOTAL WRITE TESTS: %0d | Passed: %0d | Failed: %0d", write_pass_count+write_fail_count, write_pass_count, write_fail_count);
		$display("TOTAL READ TESTS: %0d | Passed: %0d | Failed: %0d", read_pass_count+read_fail_count, read_pass_count, read_fail_count);
		$display("LED failure count: %0d", led_fail_count);
		$display("seg_cathode failure count: %0d", seg_cathode_fail_count);
		$display("seg_anode failure count: %0d", seg_anode_fail_count);
		$display("irq_out failure count: %0d", irq_out_fail_count);
		$display("#########################################################################################################################################################################");
  endtask : transaction_checker

endclass
