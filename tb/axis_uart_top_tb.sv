`timescale 1ns/1ps

`include "test_pkg.svh"

module axis_uart_top_tb();

import test_pkg::*;

localparam int CLK_FREQ   = 50;
localparam int BAUD_RATE  = 115_200;
localparam int DATA_WIDTH = 8;
localparam int SIM_TIME   = 50000;

localparam int RESET_DELAY = 10;
localparam int CLK_PER     = 10**9/CLK_FREQ;

logic clk_i;
logic arstn_i;
logic uart;

axis_if s_axis (
    .clk_i   (clk_i  ),
    .arstn_i (arstn_i)
);

axis_if m_axis (
    .clk_i   (clk_i  ),
    .arstn_i (arstn_i)
);

initial begin
    arstn_i = 1'b0;
    repeat (RESET_DELAY) @(posedge clk_i);
    arstn_i = 1'b1;
    $display("Slave reset done in: %0t ns\n.", $time());
end

initial begin
    clk_i = 1'b0;
    forever begin
        #(CLK_PER/2) clk_i = ~clk_i;
    end
end

initial begin
    test_base test;
    test = new(s_axis, m_axis);
    test.run();
end

axis_uart_tx #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) i_axis_uart_tx (
    .uart_tx_o  (uart      ),
    .s_axis     (m_axis    )
);

axis_uart_rx #(
    .CLK_FREQ   (CLK_FREQ   ),
    .BAUD_RATE  (BAUD_RATE  ),
    .DATA_WIDTH (DATA_WIDTH )
) i_axis_uart_rx (
    .uart_rx_i  (uart       ),
    .m_axis     (s_axis     )
);

endmodule
