/* verilator lint_off TIMESCALEMOD */
module ctrl_top #(
    parameter int   FIFO_DEPTH      = 128,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   SPI_CS_WIDTH    = 1,
    parameter logic ILA_EN          = 1,
    parameter       RAM_STYLE       = "distributed"
) (
    input logic clk_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic scl_pad_i,
    output logic scl_pad_o,
    output logic scl_padoen_o,

    input  logic sda_pad_i,
    output logic sda_pad_o,
    output logic sda_padoen_o,

    spi_if.master m_spi,

    axil_if.slave s_axil[2:0]
);

    axil_uart #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .ILA_EN         (ILA_EN),
        .RAM_STYLE      (RAM_STYLE)
    ) i_axil_uart (
        .clk_i    (clk_i),
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o),
        .s_axil   (s_axil[0])
    );

    axil_spi #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SLAVE_NUM      (SPI_CS_WIDTH),
        .ILA_EN         (ILA_EN),
        .RAM_STYLE      (RAM_STYLE)
    ) i_axil_spi (
        .clk_i (clk_i),
        .m_spi (m_spi),
        .s_axil(s_axil[1])
    );

    axil_i2c #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .ILA_EN         (ILA_EN),
        .RAM_STYLE      (RAM_STYLE)
    ) i_axil_i2c (
        .clk_i       (clk_i),
        .scl_pad_i   (scl_pad_i),
        .scl_pad_o   (scl_pad_o),
        .scl_padoen_o(scl_padoen_o),
        .sda_pad_i   (sda_pad_i),
        .sda_pad_o   (sda_pad_o),
        .sda_padoen_o(sda_padoen_o),
        .s_axil      (s_axil[2])
    );

endmodule
