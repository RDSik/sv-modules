`ifndef UART_PKG_SVH
`define UART_PKG_SVH

package axis_uart_pkg;

    localparam int DATA_WIDTH    = 8;
    localparam int DIVIDER_WIDTH = 32;

    typedef logic [DIVIDER_WIDTH-1:0] uart_clk_divider_reg_t;

    typedef struct packed {
        logic [29:0] rsrvd;
        logic        even;
        logic        odd;
    } uart_parity_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] data;
    } uart_tx_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] data;
    } uart_rx_reg_t;

    typedef struct packed {
        uart_rx_reg_t          rx;
        uart_tx_reg_t          tx;
        uart_parity_reg_t      parity;
        uart_clk_divider_reg_t clk_divider;
    } uart_regs_t;

    localparam int UART_CONTROL_REG_ADDR = 0;

    localparam int UART_CLK_DIVIDER_REG_ADDR = 4*(UART_CONTROL_REG_ADDR + 1);

    localparam int UART_PARITY_REG_ADDR = 4*(UART_CLK_DIVIDER_REG_ADDR + $bits(uart_clk_divider_reg_t)/32);

    localparam int UART_TX_DATA_REG_ADDR = 4*(UART_PARITY_REG_ADDR + $bits(uart_parity_reg_t)/32);

    localparam int UART_RX_DATA_REG_ADDR = 4*(UART_TX_DATA_REG_ADDR + $bits(uart_tx_data_reg_t)/32);

    function automatic logic parity;
        input logic [DATA_WIDTH-1:0] data;
        input uart_parity_reg_t      parity_mode;
        begin
            if (parity_mode.odd) begin
                parity = ~(^data);
            end else if (parity_mode.even) begin
                parity = ^data;
            end
        end
    endfunction

    typedef enum logic [2:0] {
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b010,
        PARITY = 3'b011,
        STOP   = 3'b100,
        WAIT   = 3'b101
    } uart_state_e;

endpackage

`endif // UART_PKG_SVH
