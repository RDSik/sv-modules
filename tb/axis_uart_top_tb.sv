`timescale 1ns/1ps

`include "environment.sv"

module axis_uart_top_tb();

localparam CLK_FREQ   = 27_000_000;
localparam BAUD_RATE  = 115_200;
localparam DATA_WIDTH = 8;
localparam CLK_PER    = 2;
localparam SIM_TIME   = 50000;

axis_uart_top_if dut_if();

environment env;

initial begin
    env = new(dut_if, CLK_PER, CLK_FREQ, BAUD_RATE, DATA_WIDTH, SIM_TIME);
    env.run();
end

initial begin
    $dumpfile("axis_uart_top_tb.vcd");
    $dumpvars(0, axis_uart_top_tb);
end

axis_uart_top #(
    .CLK_FREQ   (CLK_FREQ  ),
    .BAUD_RATE  (BAUD_RATE ),
    .DATA_WIDTH (DATA_WIDTH)
) dut (
    .clk_i     (dut_if.clk_i    ),
    .arstn_i   (dut_if.arstn_i  ),
    .uart_rx_i (dut_if.uart_rx_i),
    .uart_tx_o (dut_if.uart_tx_o)
);

endmodule
