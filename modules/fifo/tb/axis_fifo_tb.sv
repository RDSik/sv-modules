`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_fifo_tb ();

    import test_pkg::*;

    localparam int FIFO_WIDTH = 16;
    localparam int FIFO_DEPTH = 64;
    localparam int RAM_READ_LATENCY = 2;
    localparam FIFO_MODE = "sync";

    localparam int M_CLK_PER = 2;
    localparam int S_CLK_PER = 2;
    localparam int M_RESET_DELAY = 10;
    localparam int S_RESET_DELAY = 10;

    logic s_axis_clk;
    logic m_axis_clk;
    logic s_axis_rstn;
    logic m_axis_rstn;
    logic a_full;
    logic a_empty;

    axis_if #(
        .DATA_WIDTH(FIFO_WIDTH)
    ) s_axis (
        .clk_i (s_axis_clk),
        .rstn_i(s_axis_rstn)
    );

    axis_if #(
        .DATA_WIDTH(FIFO_WIDTH)
    ) m_axis (
        .clk_i (m_axis_clk),
        .rstn_i(m_axis_rstn)
    );

    initial begin
        s_axis_rstn = 1'b0;
        repeat (S_RESET_DELAY) @(posedge s_axis_clk);
        s_axis_rstn = 1'b1;
        $display("Master reset done in: %0t ns\n.", $time());
    end

    initial begin
        s_axis_clk = 1'b0;
        forever begin
            #(S_CLK_PER / 2) s_axis_clk = ~s_axis_clk;
        end
    end

    initial begin
        m_axis_rstn = 1'b0;
        repeat (M_RESET_DELAY) @(posedge m_axis_clk);
        m_axis_rstn = 1'b1;
        $display("Slave reset done in: %0t ns\n.", $time());
    end

    initial begin
        m_axis_clk = 1'b0;
        forever begin
            #(M_CLK_PER / 2) m_axis_clk = ~m_axis_clk;
        end
    end

    initial begin
        env_base #(
            .DATA_WIDTH_IN (FIFO_WIDTH),
            .DATA_WIDTH_OUT(FIFO_WIDTH)
        ) env;
        env = new(s_axis, m_axis);
        env.run();
    end

    axis_fifo_wrap #(
        .FIFO_DEPTH      (FIFO_DEPTH),
        .FIFO_WIDTH      (FIFO_WIDTH),
        .FIFO_MODE       (FIFO_MODE),
        .RAM_READ_LATENCY(RAM_READ_LATENCY)
    ) dut (
        .s_axis   (m_axis),
        .m_axis   (s_axis),
        .a_full_o (a_full),
        .a_empty_o(a_empty)
    );

endmodule
