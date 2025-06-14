/* verilator lint_off TIMESCALEMOD */
`include "../rtl/axis_uart_pkg.svh"

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

localparam int DELAY     = 4;
localparam int CNT_WIDTH = $clog2(DELAY);

logic [CNT_WIDTH-1:0] cnt;
logic                 cnt_done;
logic                 cnt_en;
logic                 s_handshake;
logic                 m_handshake;

typedef enum logic [2:0] {
    IDLE    = 3'b000,
    DIVIDER = 3'b001,
    PARITY  = 3'b010,
    TX_DATA = 3'b011,
    RX_DATA = 3'b100
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
        cnt_en  <= '0;
    end else begin
        case (state)
            IDLE: begin
                addr_o <= UART_CONTROL_REG_ADDR;
                unique case (data_i)
                    UART_CLK_DIVIDER_REG_ADDR: begin
                        state  <= DIVIDER;
                        cnt_en <= 1'b1;
                    end
                    UART_PARITY_REG_ADDR: begin
                        state  <= PARITY;
                        cnt_en <= 1'b1;
                    end
                    UART_TX_DATA_REG_ADDR: begin
                        state  <= TX_DATA;
                        cnt_en <= 1'b1;
                    end
                    UART_RX_DATA_REG_ADDR: begin
                        state  <= RX_DATA;
                        cnt_en <= 1'b0;
                    end
                endcase
            end
            DIVIDER: begin
                unique case (cnt)
                    0: begin
                        addr_o <= UART_CLK_DIVIDER_REG_ADDR;
                    end
                    2: begin
                        uart_regs.clk_divider <= data_i;
                        addr_o <= UART_CONTROL_REG_ADDR;
                    end
                    3: begin
                        state  <= IDLE;
                        cnt_en <= 1'b0;
                    end
                endcase
            end
            PARITY: begin
                unique case (cnt)
                    0: begin
                        addr_o <= UART_PARITY_REG_ADDR;
                    end
                    2: begin
                        uart_regs.parity <= data_i;
                        addr_o <= UART_CONTROL_REG_ADDR;
                    end
                    3: begin
                        state  <= IDLE;
                        cnt_en <= 1'b0;
                    end
                endcase
            end
            TX_DATA: begin
                unique case (cnt)
                    0: begin
                        addr_o <= UART_TX_DATA_REG_ADDR;
                    end
                    1: begin
                        cnt_en <= 1'b0;
                    end
                    2: begin
                        uart_regs.tx <= data_i;
                        if (s_handshake) begin
                            addr_o <= UART_CONTROL_REG_ADDR;
                            cnt_en <= 1'b1;
                        end
                    end
                    3: begin
                        state  <= IDLE;
                        cnt_en <= 1'b0;
                    end
                endcase
            end
            RX_DATA: begin
                unique case (cnt)
                    0: begin
                        if (m_handshake) begin
                            uart_regs.rx <= {{MEM_WIDTH-DATA_WIDTH{1'b0}}, m_axis.tdata};
                            cnt_en       <= 1'b1;
                        end
                    end
                    1: begin
                        addr_o  <= UART_RX_DATA_REG_ADDR;
                        data_o  <= uart_regs.rx;
                        wr_en_o <= '1;
                    end
                    2: begin
                        wr_en_o <= '0;
                        addr_o  <= UART_CONTROL_REG_ADDR;
                    end
                    3: begin
                        state  <= IDLE;
                        cnt_en <= 1'b0;
                    end
                endcase
            end
            default: state <= IDLE;
        endcase
    end
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        cnt <= '0;
    end else if (cnt_done) begin
        cnt <= '0;
    end else if (cnt_en) begin
        cnt <= cnt + 1'b1;
    end
end

assign cnt_done = (cnt == DELAY - 1);

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        s_axis.tvalid <= 1'b0;
    end else if (s_handshake) begin
        s_axis.tvalid <= 1'b0;
    end else if ((state == TX_DATA) && (cnt == 2)) begin
        s_axis.tvalid <= 1'b1;
    end
end

assign s_axis.tdata = uart_regs.tx.data;

assign m_axis.tready = (state == RX_DATA) && (cnt == 0);

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
