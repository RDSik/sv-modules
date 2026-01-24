`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_dw_conv_tb ();

    import test_pkg::*;

    localparam int DATA_WIDTH_IN = 32;
    localparam int DATA_WIDTH_OUT = 8;
    localparam int RESET_DELAY = 10;
    localparam int CLK_PER_NS = 2;
    localparam int FIFO_DEPTH = 16;
    localparam int CDC_REG_NUM = 3;
    localparam logic TLAST_EN = 1;
    localparam MODE = "async";

    localparam int M_CLK_PER = 2;
    localparam int S_CLK_PER = 4;
    localparam int M_RESET_DELAY = 10;
    localparam int S_RESET_DELAY = 10;

    localparam logic FIFO_FIRST = (S_CLK_PER > M_CLK_PER);

    logic s_axis_clk;
    logic m_axis_clk;
    logic s_axis_rst;
    logic m_axis_rst;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH_IN)
    ) s_axis (
        .clk_i(s_axis_clk),
        .rst_i(s_axis_rst)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH_OUT)
    ) m_axis (
        .clk_i(m_axis_clk),
        .rst_i(m_axis_rst)
    );

    initial begin
        s_axis_rst = 1'b1;
        repeat (S_RESET_DELAY) @(posedge s_axis_clk);
        s_axis_rst = 1'b0;
        $display("Master reset done in: %0t ns\n.", $time());
    end

    initial begin
        s_axis_clk = 1'b0;
        forever begin
            #(S_CLK_PER / 2) s_axis_clk = ~s_axis_clk;
        end
    end

    initial begin
        m_axis_rst = 1'b1;
        repeat (M_RESET_DELAY) @(posedge m_axis_clk);
        m_axis_rst = 1'b0;
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
            .DATA_WIDTH_IN (DATA_WIDTH_OUT),
            .DATA_WIDTH_OUT(DATA_WIDTH_IN),
            .TLAST_EN      (TLAST_EN)
        ) env;
        env = new(s_axis, m_axis);
        env.run();
    end

    initial begin
        $dumpfile("axis_dw_conv_tb.vcd");
        $dumpvars(0, axis_dw_conv_tb);
    end

    axis_dw_conv_wrap #(
        .DATA_WIDTH_IN (DATA_WIDTH_OUT),
        .DATA_WIDTH_OUT(DATA_WIDTH_IN),
        .FIFO_DEPTH    (FIFO_DEPTH),
        .CDC_REG_NUM   (CDC_REG_NUM),
        .TLAST_EN      (TLAST_EN),
        .FIFO_FIRST    (FIFO_FIRST),
        .MODE          (MODE)
    ) dut (
        .m_axis(s_axis),
        .s_axis(m_axis)
    );

endmodule
