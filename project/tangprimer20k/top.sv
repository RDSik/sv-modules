module top (
    input logic clk_i,
    input logic arstn_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic scl_pad_i,
    output logic scl_pad_o,
    output logic scl_padoen_o,

    input  logic sda_pad_i,
    output logic sda_pad_o,
    output logic sda_padoen_o
);

    axil_top #(
        .CLK_FREQ       (50 * 10 ** 6),
        .FIFO_DEPTH     (128),
        .AXIL_ADDR_WIDTH(32),
        .AXIL_DATA_WIDTH(32),
        .AXIS_DATA_WIDTH(8),
        .SLAVE_LOW_ADDR ('{default: '0}),
        .SLAVE_HIGH_ADDR('{default: '0}),
        .SLAVE_NUM      (5),
        .SPI_CS_WIDTH   (1),
        .RGMII_WIDTH    (4),
        .ILA_EN         (0),
        .MASTER_NUM     (1),
        .ASYNC_MODE_EN  (0),
        .VENDOR         ("gowin")
    ) i_axil_top (
        .clk_i       (clk_i),
        .arstn_i     (arstn_i),
        .uart_rx_i   (uart_rx_i),
        .uart_tx_o   (uart_tx_o),
        .scl_pad_i   (scl_pad_i),
        .scl_pad_o   (scl_pad_o),
        .scl_padoen_o(scl_padoen_o),
        .sda_pad_i   (sda_pad_i),
        .sda_pad_o   (sda_pad_o),
        .sda_padoen_o(sda_padoen_o),
        .s2mm_irq_o  (),
        .mm2s_irq_o  (),
        .m_eth       (),
        .m_spi       (),
        .m_axi       (),
        .s_axil      ()
    );

endmodule
