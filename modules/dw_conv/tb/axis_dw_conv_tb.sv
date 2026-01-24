`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_dw_conv_tb ();

    import test_pkg::*;

    localparam int DATA_WIDTH_IN = 32;
    localparam int DATA_WIDTH_OUT = 8;
    localparam int RESET_DELAY = 10;
    localparam int CLK_PER_NS = 2;
    localparam logic TLAST_EN = 1;

    logic clk_i;
    logic rst_i;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH_IN)
    ) s_axis (
        .clk_i(clk_i),
        .rst_i(rst_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH_OUT)
    ) m_axis (
        .clk_i(clk_i),
        .rst_i(rst_i)
    );

    initial begin
        rst_i = 1'b1;
        repeat (RESET_DELAY) @(posedge clk_i);
        rst_i = 1'b0;
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

    axis_dw_conv #(
        .DATA_WIDTH_IN (DATA_WIDTH_OUT),
        .DATA_WIDTH_OUT(DATA_WIDTH_IN),
        .TLAST_EN      (TLAST_EN)
    ) dut (
        .m_axis(s_axis),
        .s_axis(m_axis)
    );

endmodule
