/* verilator lint_off TIMESCALEMOD */
module axil_top #(
    parameter real                                       CLK_FREQ        = 50 * 10 ** 6,
    parameter int                                        FIFO_DEPTH      = 128,
    parameter int                                        AXIL_ADDR_WIDTH = 32,
    parameter int                                        AXIL_DATA_WIDTH = 32,
    parameter int                                        SPI_CS_WIDTH    = 1,
    parameter logic                                      ILA_EN          = 0,
    parameter int                                        MASTER_NUM      = 1,
    parameter int                                        SLAVE_NUM       = 4,
    parameter int                                        RGMII_WIDTH     = 4,
    parameter logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_LOW_ADDR  = '{default: '0},
    parameter logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_HIGH_ADDR = '{default: '0},
    parameter                                            MODE            = "sync",
    parameter                                            VENDOR          = "gowin"
) (
    input logic clk_i,
    input logic arstn_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic scl_pad_i,
    output logic scl_pad_o,
    output logic scl_padoen_o,

    input  logic sda_pad_i,
    output logic sda_pad_o,
    output logic sda_padoen_o,

    eth_if.master m_eth,

    spi_if.master m_spi,

    axis_if.slave  s_axis,
    axis_if.master m_axis,

    axil_if.slave s_axil[MASTER_NUM-1:0]
);

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) m_axil[SLAVE_NUM-1:0] (
        .clk_i  (s_axil[0].clk_i),
        .arstn_i(s_axil[0].arstn_i)
    );

    axil_crossbar #(
        .ADDR_WIDTH     (AXIL_ADDR_WIDTH),
        .DATA_WIDTH     (AXIL_DATA_WIDTH),
        .MASTER_NUM     (MASTER_NUM),
        .SLAVE_NUM      (SLAVE_NUM),
        .SLAVE_LOW_ADDR (SLAVE_LOW_ADDR),
        .SLAVE_HIGH_ADDR(SLAVE_HIGH_ADDR)
    ) i_axil_crossbar (
        .s_axil(s_axil),
        .m_axil(m_axil)
    );

    axil_uart #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .ILA_EN         (ILA_EN),
        .MODE           (MODE)
    ) i_axil_uart (
        .clk_i    (clk_i),
        .arstn_i  (arstn_i),
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o),
        .s_axil   (m_axil[0])
    );

    axil_spi #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SLAVE_NUM      (SPI_CS_WIDTH),
        .ILA_EN         (ILA_EN),
        .MODE           (MODE)
    ) i_axil_spi (
        .clk_i  (clk_i),
        .arstn_i(arstn_i),
        .m_spi  (m_spi),
        .s_axil (m_axil[1])
    );

    axil_i2c #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .ILA_EN         (ILA_EN),
        .MODE           (MODE)
    ) i_axil_i2c (
        .clk_i       (clk_i),
        .arstn_i     (arstn_i),
        .scl_pad_i   (scl_pad_i),
        .scl_pad_o   (scl_pad_o),
        .scl_padoen_o(scl_padoen_o),
        .sda_pad_i   (sda_pad_i),
        .sda_pad_o   (sda_pad_o),
        .sda_padoen_o(sda_padoen_o),
        .s_axil      (m_axil[2])
    );

    axil_rgmii #(
        .CLK_FREQ       (CLK_FREQ),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .RGMII_WIDTH    (RGMII_WIDTH),
        .ILA_EN         (ILA_EN),
        .MODE           (MODE),
        .VENDOR         (VENDOR)
    ) i_axil_rgmii (
        .clk_i  (clk_i),
        .arstn_i(arstn_i),
        .m_eth  (m_eth),
        .s_axis (s_axis),
        .m_axis (m_axis),
        .s_axil (m_axil[3])
    );

endmodule
