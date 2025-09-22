`ifndef UART_PKG_SVH
`define UART_PKG_SVH

package uart_pkg;

    localparam int DIVIDER_WIDTH = 32;
    localparam int DATA_WIDTH = 8;

    typedef struct packed {
        logic [7:0] rsrvd;
        logic [7:0] fifo_depth;
        logic [7:0] reg_num;
        logic [7:0] data_width;
    } uart_param_reg_t;

    typedef struct packed {
        logic [26:0] rsrvd;
        logic        rx_fifo_empty;
        logic        tx_fifo_empty;
        logic        rx_fifo_full;
        logic        tx_fifo_full;
        logic        parity_err;
    } uart_status_reg_t;

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
        uart_param_reg_t       param;
        uart_status_reg_t      status;
        uart_data_reg_t        rx;
        uart_data_reg_t        tx;
        uart_clk_divider_reg_t clk_divider;
        uart_control_reg_t     control;
    } uart_regs_t;

    localparam int CONTROL_REG_POS = 0;
    localparam int CLK_DIVIDER_REG_POS = CONTROL_REG_POS + $bits(uart_control_reg_t) / 32;
    localparam int TX_DATA_REG_POS = CLK_DIVIDER_REG_POS + $bits(uart_clk_divider_reg_t) / 32;
    localparam int RX_DATA_REG_POS = TX_DATA_REG_POS + $bits(uart_data_reg_t) / 32;
    localparam int STATUS_REG_POS = RX_DATA_REG_POS + $bits(uart_data_reg_t) / 32;
    localparam int PARAM_REG_POS = STATUS_REG_POS + $bits(uart_status_reg_t) / 32;

    localparam int REG_NUM = $bits(uart_regs_t) / 32;

    localparam uart_regs_t REG_INIT = '{
        control : '{tx_reset: 1'b1, rx_reset: 1'b1, default: '0},
        default: '0
    };

    function automatic logic parity;
        input logic [DATA_WIDTH-1:0] data;
        input logic parity_odd;
        input logic parity_even;
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

`endif  // UART_PKG_SVH
