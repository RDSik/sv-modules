/* verilator lint_off TIMESCALEMOD */
module clk_manager #(
    parameter real CLK_FREQ    = 50*10**6,
    parameter real CLK_MULT    = 5,
    parameter real CLK0_DIVIDE = 2,
    parameter real CLK1_DIVIDE = 10,
    parameter real CLK2_DIVIDE = 100
) (
    input logic clk_i,
    input logic rst_i,

    output logic clk0_o,
    output logic clk1_o,
    output logic clk2_o,

    output logic locked_o
);

    localparam real CLK_PERIOD = 10 ** 9 / CLK_FREQ;

    logic clk_fbin;
    logic clk_fbin_bufg;

    logic clk0_out;
    logic clk1_out;
    logic clk2_out;

    MMCME2_ADV #(
        .BANDWIDTH           ("OPTIMIZED"),  // Jitter programming (OPTIMIZED, HIGH, LOW)
        .CLKOUT4_CASCADE     ("FALSE"),      // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
        .COMPENSATION        ("ZHOLD"),
        .STARTUP_WAIT        ("FALSE"),      // Delays DONE until MMCM is locked (FALSE, TRUE)
        .DIVCLK_DIVIDE       (1),
        .CLKFBOUT_MULT_F     (CLK_MULT),
        .CLKIN1_PERIOD       (CLK_PERIOD),
        .CLKOUT0_DIVIDE_F    (CLK0_DIVIDE),
        .CLKOUT1_DIVIDE      (CLK1_DIVIDE),
        .CLKOUT2_DIVIDE      (CLK2_DIVIDE),
        .CLKOUT0_DUTY_CYCLE  (0.500),
        .CLKOUT1_DUTY_CYCLE  (0.500),
        .CLKOUT2_DUTY_CYCLE  (0.500),
        .CLKFBOUT_PHASE      (0.000),
        .CLKOUT0_PHASE       (0.000),
        .CLKOUT1_PHASE       (0.000),
        .CLKOUT2_PHASE       (0.000),
        .CLKFBOUT_USE_FINE_PS("FALSE"),
        .CLKOUT0_USE_FINE_PS ("FALSE"),
        .CLKOUT1_USE_FINE_PS ("FALSE"),
        .CLKOUT2_USE_FINE_PS ("FALSE")
    ) i_mmcm (
        .CLKIN1 (clk_i),
        .CLKFBIN(clk_fbin_bufg),

        .CLKFBOUT(clk_fbin),
        .CLKOUT0 (clk0_out),
        .CLKOUT1 (clk1_out),
        .CLKOUT2 (clk2_out),

        .LOCKED(locked_o),
        .PWRDWN(1'b0),
        .RST   (rst_i)
    );

    BUFG i_bufg_fbin (
        .I(clk_fbin),      // 1-bit input: Clock input
        .O(clk_fbin_bufg)  // 1-bit output: Clock output
    );

    BUFG i_clk0_out (
        .I(clk0_out),  // 1-bit input: Clock input
        .O(clk0_o)     // 1-bit output: Clock output
    );

    BUFG i_clk1_out (
        .I(clk1_out),  // 1-bit input: Clock input
        .O(clk1_o)     // 1-bit output: Clock output
    );

    BUFG i_clk2_out (
        .I(clk2_out),  // 1-bit input: Clock input
        .O(clk2_o)     // 1-bit output: Clock output
    );

endmodule
