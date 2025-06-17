`ifndef SPI_PKG_SVH
`define SPI_PKG_SVH

package axis_spi_pkg;

    localparam int DIVIDER_WIDTH = 32;
    localparam int DATA_WIDTH    = 8;

    typedef logic [DIVIDER_WIDTH-1:0] spi_clk_divider_reg_t;

    typedef struct packed {
        logic [27:0] rsrvd;
        logic        cpol;
        logic        cpha;
        logic        tx_reset;
        logic        rx_reset;
    } spi_control_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] data;
    } spi_data_reg_t;

    typedef struct packed {
        spi_data_reg_t        rx;
        spi_data_reg_t        tx;
        spi_control_reg_t     control;
        spi_clk_divider_reg_t clk_divider;
    } uart_regs_t;

    localparam int SPI_COMMAND_REG_ADDR = 0;

    localparam int SPI_CLK_DIVIDER_REG_ADDR = 4*(SPI_COMMAND_REG_ADDR + 1);

    localparam int SPI_CONTROL_REG_ADDR = SPI_CLK_DIVIDER_REG_ADDR + $bits(spi_clk_divider_reg_t)/8;

    localparam int SPI_TX_DATA_REG_ADDR = SPI_CONTROL_REG_ADDR + $bits(spi_control_reg_t)/8;

    localparam int SPI_RX_DATA_REG_ADDR = SPI_TX_DATA_REG_ADDR + $bits(spi_data_reg_t)/8;

endpackage

`endif // SPI_PKG_SVH
