`ifndef UART_PKG_SVH
`define UART_PKG_SVH

package axis_uart_pkg;

    localparam int DIVIDER_WIDTH = 32;
    localparam int DATA_WIDTH    = 8;

    typedef logic [DIVIDER_WIDTH-1:0] uart_clk_divider_reg_t;

    typedef struct packed {
        logic [27:0] rsrvd;
        logic        parity_even;
        logic        parity_odd;
        logic        tx_reset;
        logic        rx_reset;
    } uart_control_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] data;
    } uart_data_reg_t;

    typedef struct packed {
        uart_data_reg_t        rx;
        uart_data_reg_t        tx;
        uart_control_reg_t     control;
        uart_clk_divider_reg_t clk_divider;
    } uart_regs_t;

    // Address
    localparam int UART_COMMAND_REG_ADDR = 0;

    localparam int UART_CLK_DIVIDER_REG_ADDR = 4*(UART_COMMAND_REG_ADDR + 1);

    localparam int UART_CONTROL_REG_ADDR = UART_CLK_DIVIDER_REG_ADDR + $bits(uart_clk_divider_reg_t)/8;

    localparam int UART_TX_DATA_REG_ADDR = UART_CONTROL_REG_ADDR + $bits(uart_control_reg_t)/8;

    localparam int UART_RX_DATA_REG_ADDR = UART_TX_DATA_REG_ADDR + $bits(uart_data_reg_t)/8;

    // Commands
    localparam int DIVIDER_CMD = 1;

    localparam int CONTROL_CMD = 2;

    localparam int TX_DATA_CMD = 3;

    localparam int RX_DATA_CMD = 4;

    function automatic logic parity;
        input logic [DATA_WIDTH-1:0] data;
        input logic                  parity_odd;
        input logic                  parity_even;
        begin
            if (parity_odd) begin
                parity = ~(^data);
            end else if (parity_even) begin
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
