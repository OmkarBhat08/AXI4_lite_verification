class axi4_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi4_scoreboard) 

  axi4_seq_item monitor_txn;
  axi4_seq_item exp_txn;

  bit [3:0] write_states, read_states;
	bit write_done, read_done;
  bit [3:0] wstrb;
  int index;
  bit [(`DATA_WIDTH)-1:0] temp_data, mask, masked_data;

  // Register bank
  bit [(`DATA_WIDTH)-1:0] mem [0:(2**`ADDR_WIDTH)-1];

  // For 7 segment driver
  bit [(`DATA_WIDTH)-1:0] segment_data;
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
    `uvm_info(get_type_name(), $sformatf("--------------------Scoreboard @ %0t-----------------------------", $time), UVM_MEDIUM)
    if(monitor_txn.ARESETn)
    begin
      `uvm_info("All Write Channels","Reset Applied", UVM_MEDIUM)
      write_states = 0;
      read_states = 0;
      exp_txn = new();
    end
    else
    begin
      // AW CHANNEL
      if(monitor_txn.AWVALID && monitor_txn.AWREADY)
      begin
        exp_txn.AWADDR = monitor_txn.AWADDR;
        exp_txn.AWREADY = monitor_txn.AWREADY;
        `uvm_info("AW Channel", $sformatf("Received AWADDR = %0h when AWVALID = %b and AWREADY = %b", monitor_txn.AWADDR, monitor_txn.AWVALID, monitor_txn.AWREADY), UVM_MEDIUM)
        write_states = 1;
      end

      // W Channel
      if(monitor_txn.WVALID && monitor_txn.WREADY)
      begin
        exp_txn.WREADY = monitor_txn.WREADY;
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
        exp_txn.BVALID = 1;
        if(write_states != 3)
        begin
          if(!write_states[0])
            `uvm_error("B Channel", "Handshake Failed: BVALID asserted before AW Channel Operation completed")
          else if(!write_states[1])
            `uvm_error("B Channel", "Handshake Failed: BVALID asserted before W Channel Operation completed")
          else
            `uvm_error("B Channel", "Handshake Failed: BVALID asserted before AW or W Channel Operation completed")
        end
        else
        begin
          if(monitor_txn.BREADY)
          begin
            exp_txn.BRESP = monitor_txn.BRESP;
            `uvm_info("B Channel", $sformatf("Received BRESP = %b when BVALID = %b and BREADY = %b", monitor_txn.BRESP, monitor_txn.BVALID, monitor_txn.BREADY), UVM_MEDIUM)
            write_states = 0;
						write_done = 1;
            `uvm_info("B Channel", "Write handshake completed", UVM_MEDIUM)
						$display("#######################################################################################################################################################################");
            `uvm_info("get_type_name()", "SUCCESSFULLY WRITTEN INTO THE REGISTER BANK", UVM_MEDIUM)
          end
        end
      end
    end
  endtask : write_operation

  //------------------- Read Operation ------------------//
  task read_operation(axi4_seq_item monitor_txn);
    `uvm_info(get_type_name(), $sformatf("--------------------Scoreboard @ %0t-----------------------------", $time), UVM_MEDIUM)
    if(monitor_txn.ARESETn)
    begin
      read_states = 0;
      exp_txn = new();
    end
    else
    begin
      // AR CHANNEL
      if(monitor_txn.ARVALID && monitor_txn.ARREADY)
      begin
        exp_txn.ARADDR = monitor_txn.ARADDR;
        exp_txn.ARREADY = monitor_txn.ARREADY;
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
            exp_txn.RDATA = mem[exp_txn.ARADDR];
            exp_txn.RRESP = monitor_txn.RRESP;
            `uvm_info("B Channel", "Read handshake completed", UVM_MEDIUM)
						read_done = 1;

            //Printing
            `uvm_info("R Channel", "Writing RDATA", UVM_MEDIUM)
            $display("RVALID \t %b", monitor_txn.RVALID);
            $display("RREADY \t %b", monitor_txn.RREADY);
            $display("RDATA \t %0h", exp_txn.RDATA);
            $display("RRESP \t %0h", exp_txn.RRESP);
          end
        end
      end
		end
  endtask : read_operation

  //------------------- Seven Segment driver ------------------//
  task seven_segment_driver();
    segment_data = mem[4];
    if(segment_counter < 25000) // Digit 1
    begin
      exp_txn.seg_cathode = decode_7_segment(segment_data[3:0]);
      exp_txn.seg_anode = 4'b1110;
    end
    else if((segment_counter > 25000) && (segment_counter < 50000)) // Digit 2
    begin
      exp_txn.seg_cathode = decode_7_segment(segment_data[7:4]);
      exp_txn.seg_anode = 4'b1101;
    end
    else if((segment_counter > 50000) && (segment_counter < 75000)) // Digit 3
    begin
      exp_txn.seg_cathode = decode_7_segment(segment_data[11:8]);
      exp_txn.seg_anode = 4'b1011;
    end
    else if(segment_counter > 75000)  // Digit 4
    begin
      exp_txn.seg_cathode = decode_7_segment(segment_data[15:12]);
      exp_txn.seg_anode = 4'b0111;
    end
    else  // ALl off
    begin
      exp_txn.seg_cathode =  7'hFF;
      exp_txn.seg_anode = 4'b1111;
    end
    segment_counter++;
  endtask : seven_segment_driver

  //------------------- 7 segment decoder------------------//
  function bit [6:0] decode_7_segment(bit[3:0] val);
    case (val)
        4'h0: return(7'b1000000);  // 0
        4'h1: return(7'b1111001);  // 1
        4'h2: return(7'b0100100);  // 2
        4'h3: return(7'b0110000);  // 3
        4'h4: return(7'b0011001);  // 4
        4'h5: return(7'b0010010);  // 5
        4'h6: return(7'b0000010);  // 6
        4'h7: return(7'b1111000);  // 7
        4'h8: return(7'b0000000);  // 8
        4'h9: return(7'b0010000);  // 9
        4'hA: return(7'b0001000);  // A
        4'hB: return(7'b0000011);  // B
        4'hC: return(7'b1000110);  // C
        4'hD: return(7'b0100001);  // D
        4'hE: return(7'b0000110);  // E
        4'hF: return(7'b0001110);  // F
        default: return(7'b1111111);  // All off
    endcase
  endfunction : decode_7_segment
  //------------------- LED driver ------------------//
  task led_driver();
    led_data = mem[0];
    exp_txn.leds = led_data[7:0];
  endtask : led_driver

  //------------------- checker ------------------//
  task transaction_checker();
    `uvm_info(get_type_name(), $sformatf("--------------------CHECKER Scoreboard @ %0t-----------------------------", $time), UVM_MEDIUM)
    if(exp_txn.AWREADY !== monitor_txn.AWREADY)
      `uvm_error("CHECKER", "CHECKER FAILED : AWREADY")
    else
      `uvm_info("CHECKER", "CHECKER PASSED : AWREADY", UVM_MEDIUM)

    if(exp_txn.WREADY !== monitor_txn.WREADY)
      `uvm_error("CHECKER", "CHECKER FAILED : WREADY")
    else
      `uvm_info("CHECKER", "CHECKER PASSED : RREADY", UVM_MEDIUM)

    if(exp_txn.BRESP !== monitor_txn.BRESP)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : BRESP\n Expected: %b \n Received: %b",exp_txn.BRESP, monitor_txn.BRESP))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : BRESP\n Expected: %b \n Received: %b",exp_txn.BRESP, monitor_txn.BRESP), UVM_MEDIUM)

    if(exp_txn.BVALID !== monitor_txn.BVALID)
      `uvm_error("CHECKER", "CHECKER FAILED : BVALID")
    else
      `uvm_info("CHECKER", "CHECKER PASSED : BVALID", UVM_MEDIUM)

    if(exp_txn.ARREADY !== monitor_txn.ARREADY)
      `uvm_error("CHECKER", "CHECKER FAILED : ARREADY")
    else
      `uvm_info("CHECKER", "CHECKER PASSED : ARREADY", UVM_MEDIUM)

    if(exp_txn.RDATA !== monitor_txn.RDATA)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : RDATA\n Expected: %b \n Received: %b",exp_txn.RDATA, monitor_txn.RDATA))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : RDATA\n Expected: %b \n Received: %b",exp_txn.RDATA, monitor_txn.RDATA), UVM_MEDIUM)

    if(exp_txn.RRESP !== monitor_txn.RRESP)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : RRESP\n Expected: %b \n Received: %b",exp_txn.RRESP, monitor_txn.RRESP))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : RRESP\n Expected: %b \n Received: %b",exp_txn.RRESP, monitor_txn.RRESP), UVM_MEDIUM)

    if(exp_txn.RVALID !== monitor_txn.RVALID)
      `uvm_error("CHECKER", "CHECKER FAILED : RVALID")
    else
      `uvm_info("CHECKER", "CHECKER PASSED : RVALID", UVM_MEDIUM)

		if((exp_txn.RDATA === monitor_txn.RDATA) && (monitor_txn.RRESP == 0) && (monitor_txn.RVALID == 1))
		begin
			if(read_done)
			begin
				$display("##############################################################################################################################");
				$display("Read transaction PASSED with correct output");
      	`uvm_info("CHECKER", $sformatf("CHECKER PASSED : RDATA\n Expected: %b \n Received: %b",exp_txn.RDATA, monitor_txn.RDATA), UVM_MEDIUM)
				read_done = 0;
			end
			else
			begin
				$display("##############################################################################################################################");
				`uvm_error("CHECKER", "Read transaction FAILED");
      	`uvm_error("CHECKER", $sformatf("CHECKER FAILED : RDATA\n Expected: %b \n Received: %b",exp_txn.RDATA, monitor_txn.RDATA))
				read_done = 0;
			end
		end

		
    if(exp_txn.leds !== monitor_txn.leds)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : leds\n Expected: %b \n Received: %b",exp_txn.leds, monitor_txn.leds))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : leds\n Expected: %b \n Received: %b",exp_txn.leds, monitor_txn.leds), UVM_MEDIUM)

    if(exp_txn.seg_cathode !== monitor_txn.seg_cathode)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : seg_cathode\n Expected: %b \n Received: %b",exp_txn.seg_cathode, monitor_txn.seg_cathode))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : seg_cathode\n Expected: %b \n Received: %b",exp_txn.seg_cathode, monitor_txn.seg_cathode), UVM_MEDIUM)

    if(exp_txn.seg_anode !== monitor_txn.seg_anode)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : seg_anode\n Expected: %b \n Received: %b",exp_txn.seg_anode, monitor_txn.seg_anode))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : seg_anode\n Expected: %b \n Received: %b",exp_txn.seg_anode, monitor_txn.seg_anode), UVM_MEDIUM)

    if(exp_txn.irq_out !== monitor_txn.irq_out)
      `uvm_error("CHECKER", $sformatf("CHECKER FAILED : irq_out\n Expected: %b \n Received: %b",exp_txn.irq_out, monitor_txn.irq_out))
    else
      `uvm_info("CHECKER", $sformatf("CHECKER PASSED : irq_out\n Expected: %b \n Received: %b",exp_txn.irq_out, monitor_txn.irq_out), UVM_MEDIUM)
		$display("#######################################################################################################################################################################");
  endtask : transaction_checker

endclass
