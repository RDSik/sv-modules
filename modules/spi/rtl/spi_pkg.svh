`ifndef SPI_PKG_SVH
`define SPI_PKG_SVH

package spi_pkg;

    localparam int SPI_DIVIDER_WIDTH = 32;
    localparam int SPI_WAIT_WIDTH = 32;
    localparam int SPI_DATA_WIDTH = 8;
    localparam int SPI_MAX_SLAVE_NUM = 8;

    typedef struct packed {
        logic [7:0] rsrvd;
        logic [7:0] fifo_depth;
        logic [7:0] reg_num;
        logic [7:0] data_width;
    } spi_param_reg_t;

    typedef struct packed {
        logic [27:0] rsrvd;
        logic        rx_fifo_empty;
        logic        tx_fifo_empty;
        logic        rx_fifo_full;
        logic        tx_fifo_full;
    } spi_status_reg_t;

    typedef logic [SPI_DIVIDER_WIDTH-1:0] spi_clk_divider_reg_t;
    typedef logic [SPI_WAIT_WIDTH-1:0] spi_wait_time_reg_t;

    typedef struct packed {
        logic [23:0]                  rsrvd;
        logic [SPI_MAX_SLAVE_NUM-1:0] select;
    } spi_slave_select_reg_t;

    typedef struct packed {
        logic [28:0] rsrvd;
        logic        cpol;
        logic        cpha;
        logic        reset;
    } spi_control_reg_t;

    typedef struct packed {
        logic [22:0]               rsrvd;
        logic                      last;
        logic [SPI_DATA_WIDTH-1:0] data;
    } spi_data_reg_t;

    typedef struct packed {
        spi_param_reg_t        param;
        spi_status_reg_t       status;
        spi_data_reg_t         rx;
        spi_data_reg_t         tx;
        spi_slave_select_reg_t slave;
        spi_wait_time_reg_t    wait_time;
        spi_clk_divider_reg_t  clk_divider;
        spi_control_reg_t      control;
    } spi_regs_t;

    localparam int SPI_CONTROL_REG_POS = 0;
    localparam int SPI_CLK_DIVIDER_REG_POS = SPI_CONTROL_REG_POS + $bits(spi_control_reg_t) / 32;
    localparam int SPI_WAIT_TIME_REG_POS = SPI_CLK_DIVIDER_REG_POS + $bits(
        spi_clk_divider_reg_t
    ) / 32;
    localparam int SPI_SLAVE_SELECT_REG_POS = SPI_WAIT_TIME_REG_POS + $bits(
        spi_wait_time_reg_t
    ) / 32;
    localparam int SPI_TX_DATA_REG_POS = SPI_SLAVE_SELECT_REG_POS + $bits(
        spi_slave_select_reg_t
    ) / 32;
    localparam int SPI_RX_DATA_REG_POS = SPI_TX_DATA_REG_POS + $bits(spi_data_reg_t) / 32;
    localparam int SPI_STATUS_REG_POS = SPI_RX_DATA_REG_POS + $bits(spi_data_reg_t) / 32;
    localparam int SPI_PARAM_REG_POS = SPI_STATUS_REG_POS + $bits(spi_status_reg_t) / 32;

    localparam int SPI_REG_NUM = $bits(spi_regs_t) / 32;

    localparam spi_regs_t SPI_REG_INIT = '{
        control : '{reset: 1'b1, default: '0},
        wait_time: '1,
        default: '0
    };

endpackage

`endif  // SPI_PKG_SVH
