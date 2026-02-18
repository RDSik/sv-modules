/* verilator lint_off TIMESCALEMOD */
module clk_manager (
    input logic clk_i,
    input logic rst_i,

    output logic locked_o
);

    MMCME2_ADV #(
        .CLKFBOUT_MULT_F (8.0),
        .CLKFBOUT_PHASE  (0.000),
        .CLKIN1_PERIOD   (8.0),
        .CLKOUT0_DIVIDE_F(8.0),
        .CLKOUT0_PHASE   (0.000),
        .CLKOUT0_DUTY_CYCLE (0.500),
        .CLKOUT1_DIVIDE  (8),
        .CLKOUT1_PHASE   (90.000),
        .CLKOUT1_DUTY_CYCLE (0.500),
        .CLKOUT2_DIVIDE  (4),
        .CLKOUT2_PHASE   (0.000),
        .CLKOUT2_DUTY_CYCLE (0.500),
    ) i_mmcm (
        .CLKIN1 (clk_i),
        .CLKFBIN(),

        .CLKFBOUT(),
        .CLKOUT0 (),
        .CLKOUT1 (),
        .CLKOUT2 (),

        .LOCKED(locked_o),
        .PWRDWN(1'b0),
        .RST   (rst_i)
    );

    BUFG BUFG_inst (
        .I(),  // 1-bit input: Clock input
        .O()   // 1-bit output: Clock output
    );

endmodule
