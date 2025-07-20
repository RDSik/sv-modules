`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_fifo_tb ();

    import test_pkg::*;

    localparam int FIFO_WIDTH = 8;
    localparam int FIFO_DEPTH = 3;
    localparam int CIRCLE_BUF = 1;
    localparam FIFO_MODE = "sync";
    localparam FIFO_TYPE = "block";

    localparam int M_CLK_PER = 2;
    localparam int S_CLK_PER = 2;
    localparam int M_RESET_DELAY = 10;
    localparam int S_RESET_DELAY = 10;

    logic s_axis_clk;
    logic m_axis_clk;
    logic s_axis_rstn;
    logic m_axis_rstn;

    axis_if s_axis (
        .clk_i (s_axis_clk),
        .rstn_i(s_axis_rstn)
    );

    axis_if m_axis (
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
        test_base test;
        test = new(s_axis, m_axis);
        test.run();
    end

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(FIFO_WIDTH),
        .FIFO_MODE (FIFO_MODE),
        .FIFO_TYPE (FIFO_TYPE)
    ) dut (
        .s_axis(m_axis),
        .m_axis(s_axis)
    );

endmodule
