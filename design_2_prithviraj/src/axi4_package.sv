`include "uvm_macros.svh"
`include "define.sv"
package axi4_pkg;
import uvm_pkg::*;
`include "axi4_seq_item.sv"
`include "axi4_sequence.sv"
`include "axi4_sequencer.sv"
`include "axi4_driver.sv"
`include "axi4_active_monitor.sv"
`include "axi4_active_agent.sv"
`include "axi4_scoreboard.sv"
`include "axi4_subscriber.sv"
`include "axi4_environment.sv"
`include "axi4_test.sv"
endpackage
