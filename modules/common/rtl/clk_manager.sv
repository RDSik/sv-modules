/* verilator lint_off TIMESCALEMOD */
module clk_manager #(
    parameter real CLK_FREQ    = 50*10**6,
    parameter real CLK_MULT    = 5,
    parameter real CLK0_DIVIDE = 2,
    parameter real CLK1_DIVIDE = 10
) (
    input logic clk_i,
    input logic rst_i,

    output logic clk0_o,
    output logic clk1_o,

    output logic locked_o
);

    localparam real CLK_PERIOD = 10 ** 9 / CLK_FREQ;

    logic clk_fbin;
    logic clk_fbout;

    logic clk0_out;
    logic clk1_out;

    MMCME2_BASE #(
        .BANDWIDTH         ("OPTIMIZED"),  // Jitter programming (OPTIMIZED, HIGH, LOW)
        .CLKOUT4_CASCADE   ("FALSE"),      // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        .REF_JITTER1       (0.0),          // Reference input jitter in UI (0.000-0.999).
        .STARTUP_WAIT      ("FALSE"),      // Delays DONE until MMCM is locked (FALSE, TRUE)
        .DIVCLK_DIVIDE     (1),            // Master division value (1-106)
        .CLKFBOUT_MULT_F   (CLK_MULT),     // Multiply value for all CLKOUT (2.000-64.000).
        .CLKFBOUT_PHASE    (0.000),        // Phase offset in degrees of CLKFB (-360.000-360.000).
        // CLKIN_PERIOD: Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
        .CLKIN1_PERIOD     (CLK_PERIOD),
        // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT (1-128)
        .CLKOUT0_DIVIDE_F  (CLK0_DIVIDE),
        .CLKOUT1_DIVIDE    (CLK1_DIVIDE),
        // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs (0.01-0.99).
        .CLKOUT0_DUTY_CYCLE(0.500),
        .CLKOUT1_DUTY_CYCLE(0.500),
        // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs (-360.000-360.000).
        .CLKOUT0_PHASE     (0.000),
        .CLKOUT1_PHASE     (0.000)
    ) i_mmcm (
        .CLKOUT0  (clk0_out),      // 1-bit output: CLKOUT0
        .CLKOUT0B (),              // 1-bit output: Inverted CLKOUT0
        .CLKOUT1  (clk1_out),      // 1-bit output: CLKOUT1
        .CLKOUT1B (),              // 1-bit output: Inverted CLKOUT1
        .CLKOUT2  (),              // 1-bit output: CLKOUT2
        .CLKOUT2B (),              // 1-bit output: Inverted CLKOUT2
        .CLKOUT3  (),              // 1-bit output: CLKOUT3
        .CLKOUT3B (),              // 1-bit output: Inverted CLKOUT3
        .CLKOUT4  (),              // 1-bit output: CLKOUT4
        .CLKOUT5  (),              // 1-bit output: CLKOUT5
        .CLKOUT6  (),              // 1-bit output: CLKOUT6
        // Feedback Clocks: 1-bit (each) output: Clock feedback ports
        .CLKFBOUT (clk_fbout),     // 1-bit output: Feedback clock
        .CLKFBOUTB(),              // 1-bit output: Inverted CLKFBOUT
        // Status Ports: 1-bit (each) output: MMCM status ports
        .LOCKED   (locked_o),      // 1-bit output: LOCK
        // Clock Inputs: 1-bit (each) input: Clock inputs
        .CLKIN1   (clk_i),         // 1-bit input: Clock
        // Control Ports: 1-bit (each) input: MMCM control ports
        .PWRDWN   ('0),            // 1-bit input: Power-down
        .RST      (rst_i),         // 1-bit input: Reset
        // Feedback Clocks: 1-bit (each) input: Clock feedback ports
        .CLKFBIN  (clk_fbin)       // 1-bit input: Feedback clock
    );

    BUFG i_bufg_fbin (
        .I(clk_fbout), // 1-bit input: Clock input
        .O(clk_fbin)   // 1-bit output: Clock output
    );

    BUFG i_clk0_out (
        .I(clk0_out),  // 1-bit input: Clock input
        .O(clk0_o)     // 1-bit output: Clock output
    );

    BUFG i_clk1_out (
        .I(clk1_out),  // 1-bit input: Clock input
        .O(clk1_o)     // 1-bit output: Clock output
    );

endmodule
