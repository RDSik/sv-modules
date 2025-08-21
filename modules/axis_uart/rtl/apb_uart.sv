/* verilator lint_off TIMESCALEMOD */
`include "../rtl/uart_pkg.svh"

module apb_uart
    import uart_pkg::*;
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

    uart_rd_regs_t                  rd_regs;
    uart_wr_regs_t                  wr_regs;

    logic          [RD_REG_NUM-1:0] rd_valid;
    logic          [WR_REG_NUM-1:0] wr_valid;

    logic                           clk_i;
    logic                           rstn_i;

    assign clk_i  = s_apb.clk_i;
    assign rstn_i = s_apb.rstn_i;

    logic tx_reset;
    logic rx_reset;

    assign tx_reset = ~wr_regs.control.tx_reset;
    assign rx_reset = ~wr_regs.control.rx_reset;

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

    logic parity_err;
    logic tx_handshake;
    logic rx_handshake;

    assign tx_handshake = fifo_tx.tvalid & fifo_tx.tready;
    assign rx_handshake = fifo_rx.tvalid & fifo_rx.tready;

    always_comb begin
        rd_valid                     = '1;
        rd_regs.wr                   = wr_regs;

        rd_regs.status.rx_fifo_empty = ~fifo_rx.tvalid;
        rd_regs.status.tx_fifo_empty = ~uart_tx.tvalid;
        rd_regs.status.rx_fifo_full  = ~uart_rx.tready;
        rd_regs.status.tx_fifo_full  = ~fifo_tx.tready;
        rd_regs.status.parity_err    = parity_err;
        rd_regs.status.rsrvd         = '0;

        rd_regs.rx.data              = fifo_rx.tdata;
        rd_regs.rx.rsrvd             = '0;
    end

    assign fifo_tx.tdata  = wr_regs.tx.data;
    assign fifo_tx.tvalid = wr_valid[TX_DATA_REG_POS];
    assign fifo_rx.tready = rd_valid[RX_DATA_REG_POS];

    apb_reg_file #(
        .REG_DATA_WIDTH(APB_DATA_WIDTH),
        .REG_ADDR_WIDTH(APB_ADDR_WIDTH),
        .RD_REG_NUM    (RD_REG_NUM),
        .WR_REG_NUM    (WR_REG_NUM),
        .rd_reg_t      (uart_rd_regs_t),
        .wr_reg_t      (uart_wr_regs_t),
        .REG_INIT      (REG_INIT)
    ) i_apb_reg_file (
        .s_apb     (s_apb),
        .rd_regs_i (rd_regs),
        .rd_valid_i(rd_valid),
        .wr_regs_o (wr_regs),
        .wr_valid_o(wr_valid)
    );

    axis_uart_tx i_axis_uart_tx (
        .clk_divider_i(wr_regs.clk_divider),
        .parity_odd_i (wr_regs.control.parity_odd),
        .parity_even_i(wr_regs.control.parity_even),
        .uart_tx_o    (uart_tx_o),
        .s_axis       (uart_tx)
    );

    axis_uart_rx i_axis_uart_rx (
        .clk_divider_i(wr_regs.clk_divider),
        .parity_odd_i (wr_regs.control.parity_odd),
        .parity_even_i(wr_regs.control.parity_even),
        .uart_rx_i    (uart_rx_i),
        .parity_err_o (parity_err),
        .m_axis       (uart_rx)
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(AXIS_DATA_WIDTH),
        .FIFO_MODE ("sync"),
        .FIFO_TYPE ("distributed")
    ) i_axis_fifo_tx (
        .s_axis   (fifo_tx),
        .m_axis   (uart_tx),
        .a_full_o (),
        .a_empty_o()
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(AXIS_DATA_WIDTH),
        .FIFO_MODE ("sync"),
        .FIFO_TYPE ("distributed")
    ) i_axis_fifo_rx (
        .s_axis   (uart_rx),
        .m_axis   (fifo_rx),
        .a_full_o (),
        .a_empty_o()
    );

endmodule
