/* verilator lint_off TIMESCALEMOD */
`include "../rtl/axis_uart_pkg.svh"

module axis_uart_top
    import axis_uart_pkg::*;
#(
    parameter int CLK_MHZ   = 50,
    parameter int BAUD_RATE = 115_200,
    parameter int PARITY    = 0,
    parameter int ILA_EN    = 0
) (
    input  logic clk_i,
    input  logic arstn_i,

    input  logic uart_rx_i,
    output logic uart_tx_o
);

localparam int DIVIDER = (CLK_MHZ*1_000_000)/BAUD_RATE;

uart_clk_divider_reg_t clk_divider;
uart_parity_reg_t parity;

assign clk_divider = DIVIDER;
assign parity      = PARITY;

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) axis (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   )
);

axis_uart_tx i_axis_uart_tx (
    .clk_divider_i (clk_divider),
    .parity_i      (parity     ),
    .uart_tx_o     (uart_tx_o  ),
    .s_axis        (axis.slave )
);

axis_uart_rx i_axis_uart_rx (
    .clk_divider_i (clk_divider),
    .parity_i      (parity     ),
    .uart_rx_i     (uart_rx_i  ),
    .m_axis        (axis.master)
);

if (ILA_EN) begin : g_uart_ila
    uart_ila i_uart_ila (
        .clk    (clk_i      ),
        .probe0 (axis.tdata ),
        .probe1 (axis.tvalid),
        .probe2 (axis.tready),
        .probe3 (clk_divider),
        .probe4 (parity     )
    );
end

endmodule
