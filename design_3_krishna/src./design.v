module axi_lite_if #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 32
)(
    // Global Signals
    input  wire                     S_AXI_ACLK,
    input  wire                     S_AXI_ARESETN,
    
    // Write Address Channel (AW)
    
    input  wire [ADDR_WIDTH-1:0]    S_AXI_AWADDR,
    input  wire [2:0]               S_AXI_AWPROT,   // Protection type (unused)
    input  wire                     S_AXI_AWVALID,
    output reg                      S_AXI_AWREADY,
    
    // Write Data Channel (W)
    
    input  wire [DATA_WIDTH-1:0]    S_AXI_WDATA,
    input  wire [DATA_WIDTH/8-1:0]  S_AXI_WSTRB,    // Byte strobes
    input  wire                     S_AXI_WVALID,
    output reg                      S_AXI_WREADY,
    
    // Write Response Channel (B)

    output reg  [1:0]               S_AXI_BRESP,
    output reg                      S_AXI_BVALID,
    input  wire                     S_AXI_BREADY,
    
    // Read Address Channel (AR)

    input  wire [ADDR_WIDTH-1:0]    S_AXI_ARADDR,
    input  wire [2:0]               S_AXI_ARPROT,   // Protection type (unused)
    input  wire                     S_AXI_ARVALID,
    output reg                      S_AXI_ARREADY,
    
    // Read Data Channel (R)

    output reg  [DATA_WIDTH-1:0]    S_AXI_RDATA,
    output reg  [1:0]               S_AXI_RRESP,
    output reg                      S_AXI_RVALID,
    input  wire                     S_AXI_RREADY,
    
    // Register Bank Interface

    output reg                      reg_wr_en,
    output reg  [ADDR_WIDTH-1:0]    reg_wr_addr,
    output reg  [DATA_WIDTH-1:0]    reg_wr_data,
    output reg  [DATA_WIDTH/8-1:0]  reg_wr_strb,
    
    output reg                      reg_rd_en,
    output reg  [ADDR_WIDTH-1:0]    reg_rd_addr,
    input  wire [DATA_WIDTH-1:0]    reg_rd_data,
    input  wire                     reg_rd_valid
);

    // AXI Response Types
    localparam [1:0] RESP_OKAY   = 2'b00;  // Successful transaction
    localparam [1:0] RESP_EXOKAY = 2'b01;  // Exclusive access okay (unused)
    localparam [1:0] RESP_SLVERR = 2'b10;  // Slave error
    localparam [1:0] RESP_DECERR = 2'b11;  // Decode error

    // Write FSM States
    localparam [2:0] W_IDLE    = 3'b000;
    localparam [2:0] W_ADDR    = 3'b001;
    localparam [2:0] W_DATA    = 3'b010;
    localparam [2:0] W_BOTH    = 3'b011;
    localparam [2:0] W_RESP    = 3'b100;
    
    reg [2:0] write_state;
    
    // Read FSM States
    localparam [1:0] R_IDLE    = 2'b00;
    localparam [1:0] R_ADDR    = 2'b01;
    localparam [1:0] R_DATA    = 2'b10;
    
    reg [1:0] read_state;
    

    // Internal Registers for Captured Write Transaction
    reg [ADDR_WIDTH-1:0] wr_addr_captured;
    reg [DATA_WIDTH-1:0] wr_data_captured;
    reg [DATA_WIDTH/8-1:0] wr_strb_captured;
    

    // Write Transaction State Machine

    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            write_state      <= W_IDLE;
            S_AXI_AWREADY    <= 1'b0;
            S_AXI_WREADY     <= 1'b0;
            S_AXI_BVALID     <= 1'b0;
            S_AXI_BRESP      <= RESP_OKAY;
            reg_wr_en        <= 1'b0;
            reg_wr_addr      <= {ADDR_WIDTH{1'b0}};
            reg_wr_data      <= {DATA_WIDTH{1'b0}};
            reg_wr_strb      <= {DATA_WIDTH/8{1'b0}};
            wr_addr_captured <= {ADDR_WIDTH{1'b0}};
            wr_data_captured <= {DATA_WIDTH{1'b0}};
            wr_strb_captured <= {DATA_WIDTH/8{1'b0}};
        end else begin
            reg_wr_en <= 1'b0;
            
            case (write_state)
                
                W_IDLE: begin
                    S_AXI_AWREADY <= 1'b1;  // Ready to accept address
                    S_AXI_WREADY  <= 1'b1;  // Ready to accept data
                    S_AXI_BVALID  <= 1'b0;
                    
                    // Check which channel arrives first
                    if (S_AXI_AWVALID && S_AXI_WVALID) begin
                        // Both arrive together (common case)
                        wr_addr_captured <= S_AXI_AWADDR;
                        wr_data_captured <= S_AXI_WDATA;
                        wr_strb_captured <= S_AXI_WSTRB;
                        S_AXI_AWREADY    <= 1'b0;
                        S_AXI_WREADY     <= 1'b0;
                        write_state      <= W_BOTH;
                    end else if (S_AXI_AWVALID) begin
                        // Address arrives first
                        wr_addr_captured <= S_AXI_AWADDR;
                        S_AXI_AWREADY    <= 1'b0;
                        write_state      <= W_ADDR;
                    end else if (S_AXI_WVALID) begin
                        // Data arrives first
                        wr_data_captured <= S_AXI_WDATA;
                        wr_strb_captured <= S_AXI_WSTRB;
                        S_AXI_WREADY     <= 1'b0;
                        write_state      <= W_DATA;
                    end
                end
                
                W_ADDR: begin
                    // Waiting for write data
                    S_AXI_WREADY <= 1'b1;
                    
                    if (S_AXI_WVALID) begin
                        wr_data_captured <= S_AXI_WDATA;
                        wr_strb_captured <= S_AXI_WSTRB;
                        S_AXI_WREADY     <= 1'b0;
                        write_state      <= W_BOTH;
                    end
                end
                
                W_DATA: begin
                    // Waiting for write address
                    S_AXI_AWREADY <= 1'b1;
                    
                    if (S_AXI_AWVALID) begin
                        wr_addr_captured <= S_AXI_AWADDR;
                        S_AXI_AWREADY    <= 1'b0;
                        write_state      <= W_BOTH;
                    end
                end
                
                W_BOTH: begin
                    reg_wr_en   <= 1'b1;
                    reg_wr_addr <= wr_addr_captured;
                    reg_wr_data <= wr_data_captured;
                    reg_wr_strb <= wr_strb_captured;
                    
                    // Generate write response
                    S_AXI_BVALID <= 1'b1;
                    S_AXI_BRESP  <= RESP_OKAY;
                    write_state  <= W_RESP;
                end
                
                W_RESP: begin
                    // Wait for master to accept response
                    if (S_AXI_BREADY) begin
                        S_AXI_BVALID <= 1'b0;
                        write_state  <= W_IDLE;
                    end
                end
      
                default: begin
                    write_state <= W_IDLE;
                end
            endcase
        end
    end

    
    // Read Transaction State Machine
    always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
        if (!S_AXI_ARESETN) begin
            read_state    <= R_IDLE;
            S_AXI_ARREADY <= 1'b0;
            S_AXI_RVALID  <= 1'b0;
            S_AXI_RDATA   <= {DATA_WIDTH{1'b0}};
            S_AXI_RRESP   <= RESP_OKAY;
            reg_rd_en     <= 1'b0;
            reg_rd_addr   <= {ADDR_WIDTH{1'b0}};
        end else begin
            //deassert read enable
            reg_rd_en <= 1'b0;
            
            case (read_state)
                R_IDLE: begin
                    S_AXI_ARREADY <= 1'b1;  // Ready to accept read address
                    S_AXI_RVALID  <= 1'b0;
                    
                    if (S_AXI_ARVALID) begin
                        // Capture address and initiate read
                        reg_rd_addr   <= S_AXI_ARADDR;
                        reg_rd_en     <= 1'b1;
                        S_AXI_ARREADY <= 1'b0;
                        read_state    <= R_ADDR;
                    end
                end
                                
                R_ADDR: begin
                    // Wait for reg_bank to provide data
                    if (reg_rd_valid) begin
                        S_AXI_RDATA  <= reg_rd_data;
                        S_AXI_RRESP  <= RESP_OKAY;
                        S_AXI_RVALID <= 1'b1;
                        read_state   <= R_DATA;
                    end
                end
                
                R_DATA: begin
                    // Wait for master to accept data
                    if (S_AXI_RREADY) begin
                        S_AXI_RVALID <= 1'b0;
                        read_state   <= R_IDLE;
                    end
                end
                
                default: begin
                    read_state <= R_IDLE;
                end
            endcase
        end
    end

endmodule


module irq_ctrl #(
    parameter CLK_FREQ_HZ = 100_000_000,        // 100 MHz system clock
    parameter DEBOUNCE_MS = 20                  // Debounce time in milliseconds
) (
    // Clock and reset
    input  wire  clk,
    input  wire  rst_n,
    
    input  wire  ext_irq_in,
    
    // Interrupt output (clean, debounced, single-cycle pulse)
    output wire  irq_pulse_out
);

    localparam integer DEBOUNCE_COUNT = (CLK_FREQ_HZ / 1000) * DEBOUNCE_MS;
    localparam integer COUNTER_WIDTH = $clog2(DEBOUNCE_COUNT + 1);
    
    reg [COUNTER_WIDTH-1:0] debounce_counter;
    reg                      ext_irq_sync_1;     // First sync stage
    reg                      ext_irq_sync_2;     // Second sync stage
    reg                      ext_irq_stable;     // Debounced signal
    reg                      ext_irq_d1;         // Delayed by 1 cycle
    wire                     ext_irq_posedge;    // Positive edge detected
    reg                      irq_pulse_reg;
    
    assign irq_pulse_out = irq_pulse_reg;
    

    always @(posedge clk) begin
        if (!rst_n) begin
            ext_irq_sync_1 <= 1'b0;
            ext_irq_sync_2 <= 1'b0;
        end else begin
            ext_irq_sync_1 <= ext_irq_in;      // First stage
            ext_irq_sync_2 <= ext_irq_sync_1;  // Second stage (safe to use)
        end
    end
    
    always @(posedge clk) begin
        if (!rst_n) begin
            debounce_counter <= {COUNTER_WIDTH{1'b0}};
            ext_irq_stable   <= 1'b0;
        end else begin
            if (ext_irq_sync_2 != ext_irq_stable) begin
                // Input changed - start/restart counter
                if (debounce_counter == DEBOUNCE_COUNT[COUNTER_WIDTH-1:0]) begin
                    // Counter expired - accept new value as stable
                    ext_irq_stable   <= ext_irq_sync_2;
                    debounce_counter <= {COUNTER_WIDTH{1'b0}};
                end else begin
                    // Continue counting
                    debounce_counter <= debounce_counter + 1'b1;
                end
            end else begin
                // Input matches stable value - reset counter
                debounce_counter <= {COUNTER_WIDTH{1'b0}};
            end
        end
    end
    
    always @(posedge clk) begin
        if (!rst_n) begin
            ext_irq_d1 <= 1'b0;
        end else begin
            ext_irq_d1 <= ext_irq_stable;
        end
    end
    
    // Positive edge = current high AND previous low
    assign ext_irq_posedge = ext_irq_stable & ~ext_irq_d1;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            irq_pulse_reg <= 1'b0;
        end else begin
            irq_pulse_reg <= ext_irq_posedge;
        end
    end

endmodule


`timescale 1ns / 1ps

module led_driver #(
    parameter NUM_LEDS = 4,                     // Number of LEDs
    parameter ENABLE_PWM = 0,                   // 0=direct, 1=PWM dimming
    parameter PWM_RESOLUTION = 8,               // PWM resolution in bits
    parameter CLK_FREQ_HZ = 100_000_000         // Clock frequency
) (
    // Clock and reset
    input  wire                  clk,
    input  wire                  rst_n,
    
    // LED control input from register bank
    input  wire [NUM_LEDS-1:0]   led_ctrl,
    
    // PWM brightness control (0-255, only used if ENABLE_PWM=1)
    input  wire [PWM_RESOLUTION-1:0] pwm_duty,
    
    // Physical LED outputs
    output wire [NUM_LEDS-1:0]   LED
);

    generate
        if (ENABLE_PWM == 1) begin : gen_pwm
            localparam integer PWM_PERIOD = (1 << PWM_RESOLUTION) - 1;
            
            reg [PWM_RESOLUTION-1:0] pwm_counter;
            reg                       pwm_active;
            reg [NUM_LEDS-1:0]       led_out_reg;
            
            // PWM counter
            always @(posedge clk) begin
                if (!rst_n) begin
                    pwm_counter <= {PWM_RESOLUTION{1'b0}};
                end else begin
                    if (pwm_counter == PWM_PERIOD[PWM_RESOLUTION-1:0]) begin
                        pwm_counter <= {PWM_RESOLUTION{1'b0}};
                    end else begin
                        pwm_counter <= pwm_counter + 1'b1;
                    end
                end
            end
            
            // PWM comparator
            always @(posedge clk) begin
                if (!rst_n) begin
                    pwm_active <= 1'b0;
                end else begin
                    pwm_active <= (pwm_counter < pwm_duty) ? 1'b1 : 1'b0;
                end
            end
            
            // Apply PWM to LEDs
            always @(posedge clk) begin
                if (!rst_n) begin
                    led_out_reg <= {NUM_LEDS{1'b0}};
                end else begin
                    led_out_reg <= led_ctrl & {NUM_LEDS{pwm_active}};
                end
            end
            
            assign LED = led_out_reg;
            
        end else begin : gen_direct

            reg [NUM_LEDS-1:0] led_out_reg;
            
            always @(posedge clk) begin
                if (!rst_n) begin
                    led_out_reg <= {NUM_LEDS{1'b0}};
                end else begin
                    led_out_reg <= led_ctrl;
                end
            end
            
            assign LED = led_out_reg;
        end
    endgenerate

endmodule


`timescale 1ns / 1ps

// Memory Map:
//   0x00: LED Control Register    [7:0] - LED control (bits [3:0] used)
//   0x04: 7-Segment Data Register [15:0] - Four hex digits
//   0x08: IRQ Status Register     [0] - Interrupt status (write 1 to clear)
//   0x0C: Reserved


module reg_bank #(
    parameter ADDR_WIDTH = 4,    // 16 bytes of address space
    parameter DATA_WIDTH = 32    // 32-bit registers
)(
    // Clock and Reset
    input  wire                     clk,
    input  wire                     rst_n,
    
    // Register Write Interface
    input  wire                     wr_en,
    input  wire [ADDR_WIDTH-1:0]    wr_addr,
    input  wire [DATA_WIDTH-1:0]    wr_data,
    input  wire [DATA_WIDTH/8-1:0]  wr_strb,    // Byte enable strobes
    
    // Register Read Interface
    input  wire                     rd_en,
    input  wire [ADDR_WIDTH-1:0]    rd_addr,
    output reg  [DATA_WIDTH-1:0]    rd_data,
    output reg                      rd_valid,
    
    // Peripheral Outputs
    output wire [7:0]               led_ctrl_reg,
    output wire [15:0]              sevenseg_data_reg,
    output wire                     irq_status_reg,
    
    // Interrupt Input (from irq_ctrl)
    input  wire                     irq_set
);

    //=========================================================================
    // Register Definitions
    //=========================================================================
    reg [31:0] reg_0x00;  // LED Control Register
    reg [31:0] reg_0x04;  // 7-Segment Data Register
    reg [31:0] reg_0x08;  // IRQ Status Register
    reg [31:0] reg_0x0C;  // Reserved Register

    //=========================================================================
    // Register Write Logic with Byte Enable
    //=========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers to 0
            reg_0x00 <= 32'h0;
            reg_0x04 <= 32'h0;
            reg_0x08 <= 32'h0;
            reg_0x0C <= 32'h0;
        end else begin
            // IRQ set has priority (hardware sets the bit)
            if (irq_set) begin
                reg_0x08[0] <= 1'b1;
            end
            
            // Handle register writes with byte enables
            if (wr_en) begin
                case (wr_addr[3:2])  // Word-aligned addressing
                    2'b00: begin  // Address 0x00 - LED Control
                        if (wr_strb[0]) reg_0x00[7:0]   <= wr_data[7:0];
                        if (wr_strb[1]) reg_0x00[15:8]  <= wr_data[15:8];
                        if (wr_strb[2]) reg_0x00[23:16] <= wr_data[23:16];
                        if (wr_strb[3]) reg_0x00[31:24] <= wr_data[31:24];
                    end
                    
                    2'b01: begin  // Address 0x04 - 7-Segment Data
                        if (wr_strb[0]) reg_0x04[7:0]   <= wr_data[7:0];
                        if (wr_strb[1]) reg_0x04[15:8]  <= wr_data[15:8];
                        if (wr_strb[2]) reg_0x04[23:16] <= wr_data[23:16];
                        if (wr_strb[3]) reg_0x04[31:24] <= wr_data[31:24];
                    end
                    
                    2'b10: begin  // Address 0x08 - IRQ Status (write 1 to clear)
                        if (wr_strb[0] && wr_data[0]) begin
                            reg_0x08[0] <= 1'b0;  // Clear interrupt on write-1
                        end
                        // Other bits are reserved, ignore writes
                    end
                    
                    2'b11: begin  // Address 0x0C - Reserved
                        if (wr_strb[0]) reg_0x0C[7:0]   <= wr_data[7:0];
                        if (wr_strb[1]) reg_0x0C[15:8]  <= wr_data[15:8];
                        if (wr_strb[2]) reg_0x0C[23:16] <= wr_data[23:16];
                        if (wr_strb[3]) reg_0x0C[31:24] <= wr_data[31:24];
                    end
                endcase
            end
        end
    end

    //=========================================================================
    // Register Read Logic
    //=========================================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_data  <= 32'h0;
            rd_valid <= 1'b0;
        end else begin
            rd_valid <= rd_en;  // Read valid one cycle after read enable
            
            if (rd_en) begin
                case (rd_addr[3:2])  // Word-aligned addressing
                    2'b00:   rd_data <= reg_0x00;  // LED Control
                    2'b01:   rd_data <= reg_0x04;  // 7-Segment Data
                    2'b10:   rd_data <= reg_0x08;  // IRQ Status
                    2'b11:   rd_data <= reg_0x0C;  // Reserved
                    default: rd_data <= 32'hDEADBEEF;  // Invalid address
                endcase
            end
        end
    end

    //=========================================================================
    // Output Assignments to Peripherals
    //=========================================================================
    assign led_ctrl_reg       = reg_0x00[7:0];   // Only lower 8 bits used
    assign sevenseg_data_reg  = reg_0x04[15:0];  // Only lower 16 bits used
    assign irq_status_reg     = reg_0x08[0];     // Only bit 0 used

endmodule


module sevenseg_mux #(
    parameter CLK_FREQ_HZ = 100_000_000,        // 100 MHz system clock
    parameter REFRESH_RATE_HZ = 1000            // 1 kHz per digit (4 kHz total)
) (
    // Clock and reset
    input  wire        clk,
    input  wire        rst_n,
    
    // 16-bit input data (4 hex digits)
    // seg_data[3:0]   = digit 0 (rightmost)
    // seg_data[7:4]   = digit 1
    // seg_data[11:8]  = digit 2
    // seg_data[15:12] = digit 3 (leftmost)
    input  wire [15:0] seg_data,
    
    // 7-segment outputs (active low for common anode)
    output wire [6:0]  seg_cathode,  // {g,f,e,d,c,b,a}
    
    // Digit select outputs (active low for common anode)
    output wire [3:0]  seg_anode     // {dig3,dig2,dig1,dig0}
);

    localparam integer COUNTER_MAX = CLK_FREQ_HZ / (REFRESH_RATE_HZ * 4) - 1;
    localparam integer COUNTER_WIDTH = $clog2(COUNTER_MAX + 1);
    
    reg [COUNTER_WIDTH-1:0] counter_reg;
    reg [1:0]               digit_sel_reg;      // Which digit to display (0-3)
    reg [3:0]               current_digit;      // Current 4-bit hex value
    reg [6:0]               seg_cathode_reg;
    reg [3:0]               seg_anode_reg;

    assign seg_cathode = seg_cathode_reg;
    assign seg_anode   = seg_anode_reg;
    
    always @(posedge clk) begin
        if (!rst_n) begin
            counter_reg   <= {COUNTER_WIDTH{1'b0}};
            digit_sel_reg <= 2'b00;
        end else begin
            if (counter_reg == COUNTER_MAX[COUNTER_WIDTH-1:0]) begin
                // Time to switch to next digit
                counter_reg   <= {COUNTER_WIDTH{1'b0}};
                digit_sel_reg <= digit_sel_reg + 2'b01;
            end else begin
                // Keep counting
                counter_reg   <= counter_reg + 1'b1;
            end
        end
    end

    always @(*) begin
        case (digit_sel_reg)
            2'b00:   current_digit = seg_data[3:0];    // Digit 0 (rightmost)
            2'b01:   current_digit = seg_data[7:4];    // Digit 1
            2'b10:   current_digit = seg_data[11:8];   // Digit 2
            2'b11:   current_digit = seg_data[15:12];  // Digit 3 (leftmost)
            default: current_digit = 4'h0;
        endcase
    end

    always @(*) begin
        case (current_digit)
            4'h0: seg_cathode_reg = 7'b1000000;  // 0
            4'h1: seg_cathode_reg = 7'b1111001;  // 1
            4'h2: seg_cathode_reg = 7'b0100100;  // 2
            4'h3: seg_cathode_reg = 7'b0110000;  // 3
            4'h4: seg_cathode_reg = 7'b0011001;  // 4
            4'h5: seg_cathode_reg = 7'b0010010;  // 5
            4'h6: seg_cathode_reg = 7'b0000010;  // 6
            4'h7: seg_cathode_reg = 7'b1111000;  // 7
            4'h8: seg_cathode_reg = 7'b0000000;  // 8
            4'h9: seg_cathode_reg = 7'b0010000;  // 9
            4'hA: seg_cathode_reg = 7'b0001000;  // A
            4'hB: seg_cathode_reg = 7'b0000011;  // b
            4'hC: seg_cathode_reg = 7'b1000110;  // C
            4'hD: seg_cathode_reg = 7'b0100001;  // d
            4'hE: seg_cathode_reg = 7'b0000110;  // E
            4'hF: seg_cathode_reg = 7'b0001110;  // F
            default: seg_cathode_reg = 7'b1111111;  // blank (all segments off)
        endcase
    end

    always @(*) begin
        case (digit_sel_reg)
            2'b00:   seg_anode_reg = 4'b1110;  // Digit 0 active (rightmost)
            2'b01:   seg_anode_reg = 4'b1101;  // Digit 1 active
            2'b10:   seg_anode_reg = 4'b1011;  // Digit 2 active
            2'b11:   seg_anode_reg = 4'b0111;  // Digit 3 active (leftmost)
            default: seg_anode_reg = 4'b1111;  // All off
        endcase
    end

endmodule


module axi_lite_slave #(
    parameter ADDR_WIDTH = 4,                   // 16 bytes address space
    parameter DATA_WIDTH = 32,                  // 32-bit data bus
    parameter CLK_FREQ_HZ = 100_000_000,        // 100 MHz
    parameter NUM_LEDS = 4                      // Number of LEDs
) (
    //==========================================================================
    // AXI4-Lite Slave Interface
    //==========================================================================
    // Global signals
    input  wire                     S_AXI_ACLK,
    input  wire                     S_AXI_ARESETN,
    
    // Write address channel
    input  wire [ADDR_WIDTH-1:0]    S_AXI_AWADDR,
    input  wire [2:0]               S_AXI_AWPROT,
    input  wire                     S_AXI_AWVALID,
    output wire                     S_AXI_AWREADY,
    
    // Write data channel
    input  wire [DATA_WIDTH-1:0]    S_AXI_WDATA,
    input  wire [DATA_WIDTH/8-1:0]  S_AXI_WSTRB,
    input  wire                     S_AXI_WVALID,
    output wire                     S_AXI_WREADY,
    
    // Write response channel
    output wire [1:0]               S_AXI_BRESP,
    output wire                     S_AXI_BVALID,
    input  wire                     S_AXI_BREADY,
    
    // Read address channel
    input  wire [ADDR_WIDTH-1:0]    S_AXI_ARADDR,
    input  wire [2:0]               S_AXI_ARPROT,
    input  wire                     S_AXI_ARVALID,
    output wire                     S_AXI_ARREADY,
    
    // Read data channel
    output wire [DATA_WIDTH-1:0]    S_AXI_RDATA,
    output wire [1:0]               S_AXI_RRESP,
    output wire                     S_AXI_RVALID,
    input  wire                     S_AXI_RREADY,
    
    //==========================================================================
    // External I/O Ports
    //==========================================================================
    // LED outputs
    output wire [NUM_LEDS-1:0]      LED,
    
    // 7-segment display outputs
    output wire [6:0]               SEG_CATHODE,
    output wire [3:0]               SEG_ANODE,
    
    // Interrupt output to PS
    output wire                     IRQ_OUT,
    
    // External interrupt input (e.g., button)
    input  wire                     EXT_IRQ_IN
);

    //==========================================================================
    // Internal Wires - AXI Interface to Register Bank
    //==========================================================================
    wire                     reg_wr_en;
    wire [ADDR_WIDTH-1:0]    reg_wr_addr;
    wire [DATA_WIDTH-1:0]    reg_wr_data;
    wire [DATA_WIDTH/8-1:0]  reg_wr_strb;
    
    wire                     reg_rd_en;
    wire [ADDR_WIDTH-1:0]    reg_rd_addr;
    wire [DATA_WIDTH-1:0]    reg_rd_data;
    wire                     reg_rd_valid;
    
    //==========================================================================
    // Internal Wires - Register Bank to Peripherals
    //==========================================================================
    wire [7:0]               led_ctrl_reg;
    wire [15:0]              sevenseg_data_reg;
    wire                     irq_status_reg;
    
    // Interrupt pulse from IRQ controller
    wire                     irq_pulse;
    
    //==========================================================================
    // AXI4-Lite Interface Module
    //==========================================================================
    axi_lite_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axi_if (
        // Global signals
        .S_AXI_ACLK     (S_AXI_ACLK),
        .S_AXI_ARESETN  (S_AXI_ARESETN),
        
        // Write address channel
        .S_AXI_AWADDR   (S_AXI_AWADDR),
        .S_AXI_AWPROT   (S_AXI_AWPROT),
        .S_AXI_AWVALID  (S_AXI_AWVALID),
        .S_AXI_AWREADY  (S_AXI_AWREADY),
        
        // Write data channel
        .S_AXI_WDATA    (S_AXI_WDATA),
        .S_AXI_WSTRB    (S_AXI_WSTRB),
        .S_AXI_WVALID   (S_AXI_WVALID),
        .S_AXI_WREADY   (S_AXI_WREADY),
        
        // Write response channel
        .S_AXI_BRESP    (S_AXI_BRESP),
        .S_AXI_BVALID   (S_AXI_BVALID),
        .S_AXI_BREADY   (S_AXI_BREADY),
        
        // Read address channel
        .S_AXI_ARADDR   (S_AXI_ARADDR),
        .S_AXI_ARPROT   (S_AXI_ARPROT),
        .S_AXI_ARVALID  (S_AXI_ARVALID),
        .S_AXI_ARREADY  (S_AXI_ARREADY),
        
        // Read data channel
        .S_AXI_RDATA    (S_AXI_RDATA),
        .S_AXI_RRESP    (S_AXI_RRESP),
        .S_AXI_RVALID   (S_AXI_RVALID),
        .S_AXI_RREADY   (S_AXI_RREADY),
        
        // Register interface
        .reg_wr_en      (reg_wr_en),
        .reg_wr_addr    (reg_wr_addr),
        .reg_wr_data    (reg_wr_data),
        .reg_wr_strb    (reg_wr_strb),
        
        .reg_rd_en      (reg_rd_en),
        .reg_rd_addr    (reg_rd_addr),
        .reg_rd_data    (reg_rd_data),
        .reg_rd_valid   (reg_rd_valid)
    );
    
    //==========================================================================
    // Register Bank Module
    //==========================================================================
    reg_bank #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_reg_bank (
        .clk                (S_AXI_ACLK),
        .rst_n              (S_AXI_ARESETN),
        
        // Write interface
        .wr_en              (reg_wr_en),
        .wr_addr            (reg_wr_addr),
        .wr_data            (reg_wr_data),
        .wr_strb            (reg_wr_strb),
        
        // Read interface
        .rd_en              (reg_rd_en),
        .rd_addr            (reg_rd_addr),
        .rd_data            (reg_rd_data),
        .rd_valid           (reg_rd_valid),
        
        // Peripheral outputs
        .led_ctrl_reg       (led_ctrl_reg),
        .sevenseg_data_reg  (sevenseg_data_reg),
        .irq_status_reg     (irq_status_reg),
        
        // Interrupt input
        .irq_set            (irq_pulse)
    );
    
    //==========================================================================
    // LED Driver Module
    //==========================================================================
    led_driver #(
        .NUM_LEDS       (NUM_LEDS),
        .ENABLE_PWM     (0),                    // Direct mode (no PWM)
        .PWM_RESOLUTION (8),
        .CLK_FREQ_HZ    (CLK_FREQ_HZ)
    ) u_led_driver (
        .clk            (S_AXI_ACLK),
        .rst_n          (S_AXI_ARESETN),
        .led_ctrl       (led_ctrl_reg[NUM_LEDS-1:0]),
        .pwm_duty       (8'd128),               // Unused in direct mode
        .LED            (LED)
    );
    
    //==========================================================================
    // Seven-Segment Multiplexer Module
    //==========================================================================
    sevenseg_mux #(
        .CLK_FREQ_HZ      (CLK_FREQ_HZ),
        .REFRESH_RATE_HZ  (1000)                // 1 kHz per digit
    ) u_sevenseg_mux (
        .clk              (S_AXI_ACLK),
        .rst_n            (S_AXI_ARESETN),
        .seg_data         (sevenseg_data_reg),
        .seg_cathode      (SEG_CATHODE),
        .seg_anode        (SEG_ANODE)
    );
    
    //==========================================================================
    // Interrupt Controller Module
    //==========================================================================
    irq_ctrl #(
        .CLK_FREQ_HZ  (CLK_FREQ_HZ),
        .DEBOUNCE_MS  (20)                      // 20ms debounce
    ) u_irq_ctrl (
        .clk            (S_AXI_ACLK),
        .rst_n          (S_AXI_ARESETN),
        .ext_irq_in     (EXT_IRQ_IN),
        .irq_pulse_out  (irq_pulse)
    );
    
    //==========================================================================
    // Interrupt Output Assignment
    //==========================================================================
    assign IRQ_OUT = irq_status_reg;

endmodule
