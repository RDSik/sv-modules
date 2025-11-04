/* verilator lint_off TIMESCALEMOD */
`include "../rtl/spi_pkg.svh"

module axil_spi
    import spi_pkg::*;
#(
    parameter int   FIFO_DEPTH      = 128,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   AXIS_DATA_WIDTH = 8,
    parameter int   SLAVE_NUM       = 1,
    parameter logic ILA_EN          = 0

) (
    /* verilator lint_off PINMISSING */
    input logic clk_i,
    /* verilator lint_on PINMISSING */

    axil_if.slave s_axil,

    spi_if.master m_spi
);

    spi_regs_t               rd_regs;
    spi_regs_t               wr_regs;

    logic      [REG_NUM-1:0] rd_valid;
    logic      [REG_NUM-1:0] rd_req;
    logic      [REG_NUM-1:0] wr_valid;

    logic                    ps_clk;
    logic                    rstn_i;

    assign ps_clk = s_axil.clk_i;
    assign rstn_i = s_axil.rstn_i;

    logic reset;

    assign reset = ~wr_regs.control.reset;

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) fifo_tx (
        .clk_i (ps_clk),
        .rstn_i(reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) fifo_rx (
        .clk_i (ps_clk),
        .rstn_i(reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) spi_tx (
        .clk_i (ps_clk),
        .rstn_i(reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) spi_rx (
        .clk_i (ps_clk),
        .rstn_i(reset)
    );

    always_comb begin
        rd_valid                     = '1;
        rd_regs                      = wr_regs;

        rd_regs.param.data_width     = AXIS_DATA_WIDTH;
        rd_regs.param.fifo_depth     = FIFO_DEPTH;
        rd_regs.param.reg_num        = REG_NUM;

        rd_regs.status.rx_fifo_empty = ~fifo_rx.tvalid;
        rd_regs.status.tx_fifo_empty = ~spi_tx.tvalid;
        rd_regs.status.rx_fifo_full  = ~spi_rx.tready;
        rd_regs.status.tx_fifo_full  = ~fifo_tx.tready;

        rd_regs.rx.data              = fifo_rx.data;
    end

    assign fifo_tx.tdata  = wr_regs.tx.data;
    assign fifo_tx.tvalid = wr_valid[TX_DATA_REG_POS];
    assign fifo_rx.tready = rd_req[RX_DATA_REG_POS];

    axil_reg_file #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (REG_NUM),
        .reg_t         (spi_regs_t),
        .REG_INIT      (REG_INIT),
        .ILA_EN        (ILA_EN)
    ) i_axil_reg_file (
        .s_axil    (s_axil),
        .rd_regs_i (rd_regs),
        .rd_valid_i(rd_valid),
        .wr_regs_o (wr_regs),
        .rd_req_o  (rd_req),
        .wr_valid_o(wr_valid)
    );

    axis_spi_master #(
        .DATA_WIDTH   (AXIS_DATA_WIDTH),
        .SLAVE_NUM    (SLAVE_NUM),
        .DIVIDER_WIDTH(AXIS_DATA_WIDTH),
        .WAIT_WIDTH   (AXIS_DATA_WIDTH)
    ) i_axis_spi_master (
        .addr_i       (wr_regs.slave.select),
        .cpol_i       (wr_regs.control.cpol),
        .cpha_i       (wr_regs.control.cpha),
        .clk_divider_i(wr_regs.clk_divider),
        .wait_time_i  (wr_regs.wait_time),
        .m_axis       (spi_rx),
        .s_axis       (spi_tx),
        .m_spi        (m_spi)
    );

    localparam int CDC_REG_NUM = 2;
    localparam FIFO_MODE = "sync";

    axis_fifo_wrap #(
        .FIFO_DEPTH      (FIFO_DEPTH),
        .FIFO_WIDTH      (AXIS_DATA_WIDTH),
        .FIFO_MODE       (FIFO_MODE),
        .CDC_REG_NUM     (CDC_REG_NUM),
        .RAM_READ_LATENCY(0)
    ) i_axis_fifo_tx (
        .s_axis   (fifo_tx),
        .m_axis   (spi_tx),
        .a_full_o (),
        .a_empty_o()
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH      (FIFO_DEPTH),
        .FIFO_WIDTH      (AXIS_DATA_WIDTH),
        .FIFO_MODE       (FIFO_MODE),
        .CDC_REG_NUM     (CDC_REG_NUM),
        .RAM_READ_LATENCY(0)
    ) i_axis_fifo_rx (
        .s_axis   (spi_rx),
        .m_axis   (fifo_rx),
        .a_full_o (),
        .a_empty_o()
    );

endmodule
