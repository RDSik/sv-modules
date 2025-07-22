/* verilator lint_off TIMESCALEMOD */
`include "../rtl/uart_pkg.svh"

module axis_uart_top
    import uart_pkg::*;
#(
    parameter int   CLK_MHZ     = 50,
    parameter int   BAUD_RATE   = 115_200,
    parameter logic PARITY_ODD  = 1,
    parameter logic PARITY_EVEN = 0,
    parameter logic ILA_EN      = 0
) (
    input logic clk_i,
    input logic rstn_i,

    input  logic uart_rx_i,
    output logic uart_tx_o
);

    localparam int DIVIDER = (CLK_MHZ * 1_000_000) / BAUD_RATE;

    uart_clk_divider_reg_t clk_divider;
    uart_control_reg_t control;

    assign clk_divider         = DIVIDER;
    assign control.parity_even = PARITY_EVEN;
    assign control.parity_odd  = PARITY_ODD;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    axis_uart_tx i_axis_uart_tx (
        .clk_divider_i(clk_divider),
        .parity_odd_i (control.parity_odd),
        .parity_even_i(control.parity_even),
        .uart_tx_o    (uart_tx_o),
        .s_axis       (axis)
    );

    axis_uart_rx i_axis_uart_rx (
        .clk_divider_i(clk_divider),
        .parity_odd_i (control.parity_odd),
        .parity_even_i(control.parity_even),
        .uart_rx_i    (uart_rx_i),
        .m_axis       (axis)
    );

    if (ILA_EN) begin : g_uart_ila
        uart_ila i_uart_ila (
            .clk   (clk_i),
            .probe0(axis.tdata),
            .probe1(axis.tvalid),
            .probe2(axis.tready),
            .probe3(clk_divider),
            .probe4(control)
        );
    end

endmodule
