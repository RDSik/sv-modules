/* verilator lint_off TIMESCALEMOD */
`include "axis_uart_pkg.svh"

module axis_uart_bram_ctrl
    import axis_uart_pkg::*;
#(
    parameter int FIFO_DEPTH = 128,
    parameter int BYTE_NUM   = 4,
    parameter int BYTE_WIDTH = 8,
    parameter int ADDR_WIDTH = 32,
    parameter int MEM_WIDTH  = BYTE_NUM * BYTE_WIDTH
) (
    input  logic                  clk_i,
    input  logic                  arstn_i,

    input  logic                  uart_rx_i,
    output logic                  uart_tx_o,

    input  logic [MEM_WIDTH-1:0]  data_i,
    output logic [MEM_WIDTH-1:0]  data_o,
    output logic [ADDR_WIDTH-1:0] addr_o,
    output logic [BYTE_NUM-1:0]   wr_en_o
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) s_axis (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   )
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) m_axis (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   )
);

logic s_handshake;
logic m_handshake;

typedef enum logic [3:0] {
    IDLE              = 4'b0000,
    DIVIDER_ADDR      = 4'b0001,
    DIVIDER_WAIT_DATA = 4'b0010,
    DIVIDER_DATA      = 4'b0011,
    PARITY_ADDR       = 4'b0100,
    PARITY_WAIT_DATA  = 4'b0101,
    PARITY_DATA       = 4'b0110,
    TX_ADDR           = 4'b0111,
    TX_WAIT_DATA      = 4'b1000,
    TX_DATA           = 4'b1001,
    RX_ADDR           = 4'b1010,
    RX_WAIT_DATA      = 4'b1011,
    RX_DATA           = 4'b1100
} state_e;

state_e state;

uart_regs_t uart_regs;

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        state   <= IDLE;
        addr_o  <= UART_CONTROL_REG_ADDR;
        wr_en_o <= '0;
        data_o  <= '0;
        wr_en_o <= '0;
    end else begin
        case (state)
            IDLE: begin
                addr_o <= UART_CONTROL_REG_ADDR;
                unique case (data_i)
                    UART_CLK_DIVIDER_REG_ADDR: begin
                        state <= DIVIDER_ADDR;
                    end
                    UART_PARITY_REG_ADDR: begin
                        state <= PARITY_ADDR;
                    end
                    UART_TX_DATA_REG_ADDR: begin
                        state <= TX_ADDR;
                    end
                    UART_RX_DATA_REG_ADDR: begin
                        state <= RX_WAIT_DATA;
                    end
                endcase
            end
            DIVIDER_ADDR: begin
                state  <= DIVIDER_WAIT_DATA;
                addr_o <= UART_CLK_DIVIDER_REG_ADDR;
            end
            DIVIDER_WAIT_DATA: begin
                state <= DIVIDER_DATA;
            end
            DIVIDER_DATA: begin
                uart_regs.clk_divider <= data_i;
                addr_o <= UART_CONTROL_REG_ADDR;
                state  <= IDLE;
            end
            PARITY_ADDR: begin
                state  <= PARITY_WAIT_DATA;
                addr_o <= UART_PARITY_REG_ADDR;
            end
            PARITY_WAIT_DATA: begin
                state <= PARITY_DATA;
            end
            PARITY_DATA: begin
                uart_regs.parity <= data_i;
                addr_o <= UART_CONTROL_REG_ADDR;
                state  <= IDLE;
            end
            TX_ADDR: begin
                state  <= TX_WAIT_DATA;
                addr_o <= UART_TX_DATA_REG_ADDR;
            end
            TX_WAIT_DATA: begin
                state <= TX_DATA;
            end
            TX_DATA: begin
                uart_regs.tx <= data_i;
                if (s_handshake) begin
                    addr_o <= UART_CONTROL_REG_ADDR;
                    state  <= IDLE;
                end
            end
            RX_WAIT_DATA: begin
                if (m_handshake) begin
                    uart_regs.rx <= {{MEM_WIDTH-DATA_WIDTH{1'b0}}, m_axis.tdata};
                    state <= RX_DATA;
                end
            end
            RX_DATA: begin
                state   <= RX_ADDR;
                addr_o  <= UART_RX_DATA_REG_ADDR;
                data_o  <= uart_regs.rx;
                wr_en_o <= '1;
            end
            RX_ADDR: begin
                wr_en_o <= '0;
                addr_o  <= UART_CONTROL_REG_ADDR;
                state   <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        s_axis.tvalid <= 1'b0;
    end else if (s_handshake) begin
        s_axis.tvalid <= 1'b0;
    end else if (state == TX_DATA) begin
        s_axis.tvalid <= 1'b1;
    end
end

assign s_axis.tdata = uart_regs.tx.data;

assign m_axis.tready = (state == RX_WAIT_DATA);

assign s_handshake = s_axis.tvalid & s_axis.tready;
assign m_handshake = m_axis.tvalid & m_axis.tready;

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) uart_tx (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   )
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) uart_rx (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   )
);

axis_uart_tx i_axis_uart_tx (
    .clk_divider_i (uart_regs.clk_divider),
    .parity_i      (uart_regs.parity     ),
    .uart_tx_o     (uart_tx_o            ),
    .s_axis        (uart_tx.slave        )
);

axis_uart_rx i_axis_uart_rx (
    .clk_divider_i (uart_regs.clk_divider),
    .parity_i      (uart_regs.parity     ),
    .uart_rx_i     (uart_rx_i            ),
    .m_axis        (uart_rx.master       )
);

axis_fifo_wrap #(
    .FIFO_DEPTH (FIFO_DEPTH    ),
    .FIFO_WIDTH (DATA_WIDTH    ),
    .CIRCLE_BUF (1             ),
    .FIFO_TYPE  ("SYNC"        )
) i_axis_fifo_tx (
    .s_axis     (s_axis.slave  ),
    .m_axis     (uart_tx.master)
);

axis_fifo_wrap #(
    .FIFO_DEPTH (FIFO_DEPTH   ),
    .FIFO_WIDTH (DATA_WIDTH   ),
    .CIRCLE_BUF (1            ),
    .FIFO_TYPE  ("SYNC"       )
) i_axis_fifo_rx (
    .s_axis     (uart_rx.slave),
    .m_axis     (m_axis.master)
);

endmodule
