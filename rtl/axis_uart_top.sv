/* verilator lint_off TIMESCALEMOD */
module axis_uart_top #(
    parameter CLK_FREQ   = 27_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
)(
    input  logic clk_i,
    input  logic arstn_i,
    input  logic uart_rx_i,
    output logic uart_tx_o
);

axis_if s_axis();
axis_if m_axis();

axis_fifo #(
    .DATA_WIDTH (DATA_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH)
) i_axis_fifo (
    .clk_i   (clk_i  ),
    .arstn_i (arstn_i),
    .m_axis  (s_axis ),
    .s_axis  (m_axis )
);

axis_uart_tx #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) i_axis_uart_tx (
    .clk_i     (clk_i    ),
    .arstn_i   (arstn_i  ),
    .uart_tx_o (uart_tx_o),
    .s_axis    (s_axis   )
);

axis_uart_rx #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) i_axis_uart_rx (
    .clk_i     (clk_i    ),
    .arstn_i   (arstn_i  ),
    .uart_rx_i (uart_rx_i),
    .m_axis    (m_axis   )
);

`ifdef COCOTB_SIM
    initial begin
        $dumpfile ("axis_uart_top.vcd");
        $dumpvars (0, axis_uart_top);
        #1;
    end
`endif

endmodule
