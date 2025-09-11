`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_uart_tb ();

    import test_pkg::*;

    localparam int CLK_MHZ = 50;
    localparam int BAUD_RATE = 115_200;
    localparam logic PARITY_ODD = 1;
    localparam logic PARITY_EVEN = 0;
    localparam int DATA_WIDTH = 8;
    localparam int DIVIDER_WIDTH = 32;
    localparam int DIVIDER = (CLK_MHZ * 1_000_000) / BAUD_RATE;
    localparam int RESET_DELAY = 10;
    localparam int CLK_PER_NS = 1_000_000_000 / (CLK_MHZ * 1_000_000);

    logic clk_i;
    logic rstn_i;
    logic uart_data;
    logic parity_err;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) s_axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) m_axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    initial begin
        rstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        rstn_i = 1'b1;
        $display("Reset done in: %0t ns\n.", $time());
    end

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER_NS / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        env_base #(
            .DATA_WIDTH_IN (DATA_WIDTH),
            .DATA_WIDTH_OUT(DATA_WIDTH)
        ) env;
        env = new(s_axis, m_axis);
        env.run();
    end

    initial begin
        $dumpfile("axis_uart_tb.vcd");
        $dumpvars(0, axis_uart_tb);
    end

    axis_uart_tx #(
        .DATA_WIDTH   (DATA_WIDTH),
        .DIVIDER_WIDTH(DIVIDER_WIDTH)
    ) i_axis_uart_tx (
        .clk_divider_i(DIVIDER),
        .parity_odd_i (PARITY_ODD),
        .parity_even_i(PARITY_EVEN),
        .uart_tx_o    (uart_data),
        .s_axis       (m_axis)
    );

    axis_uart_rx #(
        .DATA_WIDTH   (DATA_WIDTH),
        .DIVIDER_WIDTH(DIVIDER_WIDTH)
    ) i_axis_uart_rx (
        .clk_divider_i(DIVIDER),
        .parity_odd_i (PARITY_ODD),
        .parity_even_i(PARITY_EVEN),
        .uart_rx_i    (uart_data),
        .parity_err_o (parity_err),
        .m_axis       (s_axis)
    );

endmodule
