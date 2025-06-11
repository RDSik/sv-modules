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
    IDLE      = 4'b0000,
    DIVIDER_1 = 4'b0001,
    DIVIDER_2 = 4'b0010,
    DIVIDER_3 = 4'b0011,
    PARITY_1  = 4'b0100,
    PARITY_2  = 4'b0101,
    PARITY_3  = 4'b0110,
    TX_1      = 4'b0111,
    TX_2      = 4'b1000,
    TX_3      = 4'b1001,
    RX_1      = 4'b1010,
    RX_2      = 4'b1011,
    RX_3      = 4'b1100
} state_e;

state_e state;

uart_regs_t uart_regs;

always_ff @(posedge s_axis.clk_i or negedge s_axis.arstn_i) begin
    if (~s_axis.arstn_i) begin
        state   <= IDLE;
        addr_o  <= '0;
        wr_en_o <= '0;
        data_o  <= '0;
    end else begin
        case (state)
            IDLE: begin
                addr_o <= UART_CONTROL_REG_ADDR;
                unique case (data_i)
                    UART_CLK_DIVIDER_REG_ADDR: begin
                        state <= READ_ADDR;
                    end
                    UART_PARITY_REG_ADDR: begin
                        state <= READ_ADDR;
                    end
                    UART_TX_DATA_REG_ADDR: begin
                        state <= READ_ADDR;
                    end
                    UART_RX_DATA_REG_ADDR: begin
                        state <= WRITE_ADDR;
                    end
                endcase
            end
            default: state <= IDLE;
        endcase
    end
end

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
    .s_axis     (s_axis        ),
    .m_axis     (uart_tx.master)
);

axis_fifo_wrap #(
    .FIFO_DEPTH (FIFO_DEPTH   ),
    .FIFO_WIDTH (DATA_WIDTH   ),
    .CIRCLE_BUF (1            ),
    .FIFO_TYPE  ("SYNC"       )
) i_axis_fifo_rx (
    .s_axis     (uart_rx.slave),
    .m_axis     (m_axis       )
);

endmodule
