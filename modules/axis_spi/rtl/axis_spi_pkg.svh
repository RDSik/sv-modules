`ifndef SPI_PKG_SVH
`define SPI_PKG_SVH

package axis_spi_pkg;

    localparam int DATA_WIDTH    = 8;
    localparam int DIVIDER_WIDTH = 32;

    typedef logic [DIVIDER_WIDTH-1:0] spi_clk_divider_reg_t;

    typedef struct packed {
        logic [29:0] rsrvd;
        logic        cpol;
        logic        cpha;
    } spi_mode_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] tx_data;
    } spi_tx_data_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] rx_data;
    } spi_rx_data_reg_t;

    typedef struct packed {
        spi_rx_data_reg_t     rx_data;
        spi_tx_data_reg_t     tx_data;
        spi_mode_reg_t        mode;
        spi_clk_divider_reg_t clk_divider;
    } uart_regs_t;

    localparam int SPI_CLK_DIVIDER_REG_ADDR = 0;

    localparam int SPI_MODE_REG_ADDR = SPI_CLK_DIVIDER_REG_ADDR + $bits(spi_clk_divider_reg_t) / 32;

    localparam int SPI_TX_DATA_REG_ADDR = SPI_MODE_REG_ADDR + $bits(spi_mode_reg_t) / 32;

    localparam int SPI_RX_DATA_REG_ADDR = SPI_TX_DATA_REG_ADDR + $bits(spi_tx_data_reg_t) / 32;

endpackage

`endif // SPI_PKG_SVH
