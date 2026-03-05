
`define ADDR_WIDTH 4
`define DATA_WIDTH 32
`define CLK_FREQ 100000000
`define REFRESH_RATE 1000
`define DEBOUNCE 20

package define;
  parameter COUNTER_MAX = (`CLK_FREQ / (`REFRESH_RATE * 4) - 1);
  parameter IRQ_COUNTER_MAX = (`CLK_FREQ / 1000 * `DEBOUNCE - 1);
endpackage
