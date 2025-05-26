/* verilator lint_off TIMESCALEMOD */
module axis_uart_top #(
    parameter int CLK_FREQ   = 50,
    parameter int BAUD_RATE  = 115_200,
    parameter int DATA_WIDTH = 8
) (
    input  logic clk_i,
    input  logic arstn_i,

    input  logic uart_rx_i,
    output logic uart_tx_o
);

axis_if #(
    .DATA_WIDTH (DATA_WIDTH)
) axis (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   )
);

axis_uart_tx #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) i_axis_uart_tx (
    .uart_tx_o  (uart_tx_o ),
    .s_axis     (axis.slave)
);

axis_uart_rx #(
    .CLK_FREQ   (CLK_FREQ   ),
    .BAUD_RATE  (BAUD_RATE  ),
    .DATA_WIDTH (DATA_WIDTH )
) i_axis_uart_rx (
    .uart_rx_i  (uart_rx_i  ),
    .m_axis     (axis.master)
);

`ifdef COCOTB_SIM
    initial begin
        $dumpfile ("axis_uart_top.vcd");
        $dumpvars (0, axis_uart_top);
        #1;
    end
`endif

endmodule
