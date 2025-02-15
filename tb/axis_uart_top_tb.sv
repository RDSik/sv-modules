`timescale 1ns/1ps

`include "environment.sv"

module axis_uart_top_tb();

localparam CLK_FREQ   = 27_000_000;
localparam BAUD_RATE  = 115_200;
localparam DATA_WIDTH = 8;
localparam CLK_PER    = 2;

axis_uart_top_if dut_if();

environment env;

initial begin
    env = new(dut_if, CLK_PER, CLK_FREQ, BAUD_RATE, DATA_WIDTH);
    fork
        env.clk_gen();
        env.run();
    join_any
    `ifdef VERILATOR
    $finish();
    `else
    $stop();
    `endif
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
    .clk_i  (dut_if.clk_i  ),
    .arstn_i(dut_if.arstn_i),
    .rx_i   (dut_if.rx_i   ),
    .tx_o   (dut_if.tx_o   )
);

endmodule
