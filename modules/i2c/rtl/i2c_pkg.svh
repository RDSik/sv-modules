`ifndef I2C_PKG_SVH
`define I2C_PKG_SVH

package i2c_pkg;

    localparam int PRESCALE_WIDTH = 16;
    localparam int DATA_WIDTH = 8;

    typedef struct packed {
        logic [27:0] rsrvd;
        logic        rx_ack;
        logic        busy;
        logic        al;
        logic        cmd_ack;
    } i2c_status_reg_t;

    typedef struct packed {
        logic [15:0]               rsrvd;
        logic [PRESCALE_WIDTH-1:0] prescale;
    } i2c_clk_prescale_reg_t;

    typedef struct packed {
        logic [29:0] rsrvd;
        logic        core_en;
        logic        core_rst;
    } i2c_control_reg_t;

    typedef struct packed {
        logic [26:0] rsrvd;
        logic        start;
        logic        stop;
        logic        rd;
        logic        wr;
        logic        ack;
    } i2c_command_reg_t;

    typedef struct packed {
        logic [23:0]           rsrvd;
        logic [DATA_WIDTH-1:0] data;
    } i2c_data_reg_t;

    typedef struct packed {
        i2c_status_reg_t       status;
        i2c_data_reg_t         rx;
        i2c_data_reg_t         tx;
        i2c_clk_prescale_reg_t clk;
        i2c_command_reg_t      command;
        i2c_control_reg_t      control;
    } i2c_regs_t;

    localparam int CONTROL_REG_POS = 0;
    localparam int COMMAND_REG_POS = CONTROL_REG_POS + $bits(i2c_control_reg_t) / 32;
    localparam int CLK_PRESCALE_REG_POS = COMMAND_REG_POS + $bits(i2c_command_reg_t) / 32;
    localparam int TX_DATA_REG_POS = CLK_PRESCALE_REG_POS + $bits(i2c_clk_prescale_reg_t) / 32;
    localparam int RX_DATA_REG_POS = TX_DATA_REG_POS + $bits(i2c_data_reg_t) / 32;
    localparam int STATUS_REG_POS = RX_DATA_REG_POS + $bits(i2c_data_reg_t) / 32;

    localparam int REG_NUM = $bits(i2c_regs_t) / 32;

    localparam i2c_regs_t REG_INIT = '{control : '{core_rst: 1'b1, default: '0}, default: '0};

endpackage

`endif  // I2C_PKG_SVH
