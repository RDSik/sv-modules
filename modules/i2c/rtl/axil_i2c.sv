/* verilator lint_off TIMESCALEMOD */
`include "../rtl/i2c_pkg.svh"

module axil_i2c
    import i2c_pkg::*;
#(
    parameter int   FIFO_DEPTH      = 128,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter logic ILA_EN          = 0,
    parameter       MODE            = "sync"
) (
    input logic clk_i,

    input  logic scl_pad_i,
    output logic scl_pad_o,
    output logic scl_padoen_o,

    input  logic sda_pad_i,
    output logic sda_pad_o,
    output logic sda_padoen_o,

    axil_if.slave s_axil
);

    i2c_regs_t                      rd_regs;
    i2c_regs_t                      wr_regs;

    logic      [   I2C_REG_NUM-1:0] rd_request;
    logic      [   I2C_REG_NUM-1:0] rd_valid;
    logic      [   I2C_REG_NUM-1:0] wr_valid;

    logic      [I2C_DATA_WIDTH-1:0] i2c_tx_data;
    logic      [I2C_DATA_WIDTH-1:0] i2c_rx_data;

    logic                           tx_fifo_full;
    logic                           tx_fifo_empty;
    logic                           rx_fifo_full;
    logic                           rx_fifo_empty;

    logic      [I2C_DATA_WIDTH-1:0] rx_data;
    logic                           i2c_busy;
    logic                           i2c_ack;
    logic                           i2c_al;

    always_comb begin
        rd_valid                     = '1;
        rd_regs                      = wr_regs;

        rd_regs.param.data_width     = I2C_DATA_WIDTH;
        rd_regs.param.fifo_depth     = FIFO_DEPTH;
        rd_regs.param.reg_num        = I2C_REG_NUM;

        rd_regs.status.rx_fifo_empty = rx_fifo_empty;
        rd_regs.status.rx_fifo_full  = rx_fifo_full;
        rd_regs.status.tx_fifo_empty = tx_fifo_empty;
        rd_regs.status.tx_fifo_full  = tx_fifo_full;
        rd_regs.status.busy          = i2c_busy;
        rd_regs.status.rx_ack        = i2c_ack;

        rd_regs.rx.data              = rx_data;
    end

    axil_reg_file_wrap #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (I2C_REG_NUM),
        .reg_t         (i2c_regs_t),
        .REG_INIT      (I2C_REG_INIT),
        .ILA_EN        (ILA_EN),
        .MODE          (MODE)
    ) i_axil_reg_file (
        .clk_i       (clk_i),
        .s_axil      (s_axil),
        .rd_regs_i   (rd_regs),
        .rd_valid_i  (rd_valid),
        .wr_regs_o   (wr_regs),
        .rd_request_o(rd_request),
        .wr_valid_o  (wr_valid)
    );

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        ADDR = 2'b01,
        DATA = 2'b10,
        STOP = 2'b11
    } state_t;

    state_t state;

    logic   cmd_ack;
    logic   stop;
    logic   start;
    logic   write;
    logic   read;

    logic   fifo_rst;
    logic   tx_fifo_push;
    logic   tx_fifo_pop;
    logic   rx_fifo_push;
    logic   rx_fifo_pop;

    assign fifo_rst = wr_regs.control.core_rst;

    assign tx_fifo_push = wr_valid[I2C_TX_DATA_REG_POS];
    assign tx_fifo_pop = cmd_ack & write;

    assign rx_fifo_pop = rd_request[I2C_RX_DATA_REG_POS];
    assign rx_fifo_push = cmd_ack & read;

    always @(posedge clk_i) begin
        if (wr_regs.control.core_rst | i2c_al) begin
            state <= IDLE;
            write <= 1'b0;
            read  <= 1'b0;
            start <= 1'b0;
            stop  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (tx_fifo_push) begin
                        state <= ADDR;
                        start <= 1'b1;
                        write <= 1'b1;
                        read  <= 1'b0;
                    end
                end
                ADDR: begin
                    if (cmd_ack) begin
                        state <= DATA;
                        start <= 1'b0;
                        write <= wr_regs.tx.rw;
                        read  <= ~wr_regs.tx.rw;
                    end
                end
                DATA: begin
                    if (cmd_ack) begin
                        state <= STOP;
                        stop  <= 1'b1;
                        write <= 1'b0;
                        read  <= 1'b0;
                    end
                end
                STOP: begin
                    if (cmd_ack) begin
                        state <= IDLE;
                        stop  <= 1'b0;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    i2c_master_byte_ctrl i_i2c_master_byte_ctrl (
        .clk     (clk_i),
        .rst     (wr_regs.control.core_rst),
        .nReset  ('1),
        .ena     (wr_regs.control.core_en),
        .clk_cnt (wr_regs.clk.prescale),
        .start   (start),
        .stop    (stop),
        .read    (read),
        .write   (write),
        .ack_in  (read),
        .din     (i2c_tx_data),
        .cmd_ack (cmd_ack),
        .ack_out (i2c_ack),
        .dout    (i2c_rx_data),
        .i2c_busy(i2c_busy),
        .i2c_al  (i2c_al),
        .scl_i   (scl_pad_i),
        .scl_o   (scl_pad_o),
        .scl_oen (scl_padoen_o),
        .sda_i   (sda_pad_i),
        .sda_o   (sda_pad_o),
        .sda_oen (sda_padoen_o)
    );

    localparam int READ_LATENCY = 0;
    localparam int CDC_REG_NUM = 2;
    localparam FIFO_MODE = "sync";
    localparam RAM_STYLE = "distributed";

    fifo_wrap #(
        .FIFO_WIDTH  (I2C_DATA_WIDTH),
        .FIFO_DEPTH  (FIFO_DEPTH),
        .CDC_REG_NUM (CDC_REG_NUM),
        .FIFO_MODE   (FIFO_MODE),
        .READ_LATENCY(READ_LATENCY),
        .RAM_STYLE   (RAM_STYLE)
    ) i_fifo_tx (
        .wr_clk_i (clk_i),
        .wr_rst_i (fifo_rst),
        .wr_data_i(wr_regs.tx.data),
        .rd_clk_i (clk_i),
        .rd_rst_i (fifo_rst),
        .rd_data_o(i2c_tx_data),
        .push_i   (tx_fifo_push),
        .pop_i    (tx_fifo_pop),
        .empty_o  (tx_fifo_empty),
        .full_o   (tx_fifo_full),
        .a_empty_o(),
        .a_full_o ()
    );

    fifo_wrap #(
        .FIFO_WIDTH  (I2C_DATA_WIDTH),
        .FIFO_DEPTH  (FIFO_DEPTH),
        .CDC_REG_NUM (CDC_REG_NUM),
        .FIFO_MODE   (FIFO_MODE),
        .READ_LATENCY(READ_LATENCY),
        .RAM_STYLE   (RAM_STYLE)
    ) i_fifo_rx (
        .wr_clk_i (clk_i),
        .wr_rst_i (fifo_rst),
        .wr_data_i(i2c_rx_data),
        .rd_clk_i (clk_i),
        .rd_rst_i (fifo_rst),
        .rd_data_o(rx_data),
        .push_i   (rx_fifo_push),
        .pop_i    (rx_fifo_pop),
        .empty_o  (rx_fifo_empty),
        .full_o   (rx_fifo_full),
        .a_empty_o(),
        .a_full_o ()
    );

endmodule
