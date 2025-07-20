/* verilator lint_off TIMESCALEMOD */
`include "../rtl/axis_uart_pkg.svh"

module apb_uart
    import axis_uart_pkg::*;
#(
    parameter int FIFO_DEPTH      = 128,
    parameter int APB_ADDR_WIDTH  = 32,
    parameter int APB_DATA_WIDTH  = 32,
    parameter int AXIS_DATA_WIDTH = 8
) (
    input  logic uart_rx_i,
    output logic uart_tx_o,

    apb_if.slave s_apb
);

    uart_regs_t uart_regs;

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_apb.clk_i;
    assign rstn_i = s_apb.rstn_i;

    logic tx_reset;
    logic rx_reset;

    assign tx_reset = uart_regs.control.tx_reset;
    assign rx_reset = uart_regs.control.rx_reset;

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) fifo_tx (
        .clk_i (clk_i),
        .rstn_i(tx_reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) fifo_rx (
        .clk_i (clk_i),
        .rstn_i(rx_reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) uart_tx (
        .clk_i (clk_i),
        .rstn_i(tx_reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) uart_rx (
        .clk_i (clk_i),
        .rstn_i(rx_reset)
    );

    assign uart_regs.status.rx_fifo_empty = ~fifo_rx.tvalid;
    assign uart_regs.status.tx_fifo_full  = ~fifo_tx.tready;

    // TODO: Add AXIS to APB logic
    assign s_apb.pslverr                  = 1'b0;

    axis_uart_tx i_axis_uart_tx (
        .clk_divider_i(uart_regs.clk_divider),
        .parity_odd_i (uart_regs.control.parity_odd),
        .parity_even_i(uart_regs.control.parity_even),
        .uart_tx_o    (uart_tx_o),
        .s_axis       (uart_tx)
    );

    axis_uart_rx i_axis_uart_rx (
        .clk_divider_i(uart_regs.clk_divider),
        .parity_odd_i (uart_regs.control.parity_odd),
        .parity_even_i(uart_regs.control.parity_even),
        .uart_rx_i    (uart_rx_i),
        .parity_err_o (uart_regs.status.parity_err),
        .m_axis       (uart_rx)
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(AXIS_DATA_WIDTH),
        .FIFO_MODE ("sync"),
        .FIFO_TYPE ("distributed")
    ) i_axis_fifo_tx (
        .s_axis(fifo_tx),
        .m_axis(uart_tx)
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(AXIS_DATA_WIDTH),
        .FIFO_MODE ("sync"),
        .FIFO_TYPE ("distributed")
    ) i_axis_fifo_rx (
        .s_axis(uart_rx),
        .m_axis(fifo_rx)
    );

endmodule
