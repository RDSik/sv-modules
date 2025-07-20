/* verilator lint_off TIMESCALEMOD */
`include "../rtl/axis_uart_pkg.svh"

module apb_uart
    import axis_uart_pkg::*;
#(
    parameter int FIFO_DEPTH = 128,
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32
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

uart_regs_t uart_regs;

logic tx_reset;
logic rx_reset;

assign tx_reset = ~uart_regs.control.tx_reset;
assign rx_reset = ~uart_regs.control.rx_reset;

logic s_handshake;
logic m_handshake;

assign s_handshake = fifo_tx.tvalid & fifo_tx.tready;
assign m_handshake = fifo_rx.tvalid & fifo_rx.tready;

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) fifo_tx (
    .clk_i      (clk_i     ),
    .arstn_i    (tx_reset  )
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) fifo_rx (
    .clk_i      (clk_i     ),
    .arstn_i    (rx_reset  )
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) uart_tx (
    .clk_i      (clk_i     ),
    .arstn_i    (tx_reset  )
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) uart_rx (
    .clk_i      (clk_i     ),
    .arstn_i    (rx_reset  )
);

axis_uart_tx i_axis_uart_tx (
    .clk_divider_i (uart_regs.clk_divider        ),
    .parity_odd_i  (uart_regs.control.parity_odd ),
    .parity_even_i (uart_regs.control.parity_even),
    .uart_tx_o     (uart_tx_o                    ),
    .s_axis        (uart_tx                      )
);

axis_uart_rx i_axis_uart_rx (
    .clk_divider_i (uart_regs.clk_divider        ),
    .parity_odd_i  (uart_regs.control.parity_odd ),
    .parity_even_i (uart_regs.control.parity_even),
    .uart_rx_i     (uart_rx_i                    ),
    .m_axis        (uart_rx                      )
);

axis_fifo_wrap #(
    .FIFO_DEPTH (FIFO_DEPTH   ),
    .FIFO_WIDTH (DATA_WIDTH   ),
    .FIFO_MODE  ("sync"       ),
    .FIFO_TYPE  ("distributed")
) i_axis_fifo_tx (
    .s_axis     (fifo_tx      ),
    .m_axis     (uart_tx      )
);

axis_fifo_wrap #(
    .FIFO_DEPTH (FIFO_DEPTH   ),
    .FIFO_WIDTH (DATA_WIDTH   ),
    .FIFO_MODE  ("sync"       ),
    .FIFO_TYPE  ("distributed")
) i_axis_fifo_rx (
    .s_axis     (uart_rx      ),
    .m_axis     (fifo_rx      )
);

endmodule
