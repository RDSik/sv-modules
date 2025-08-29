`timescale 1ns / 1ps

module axis_dw_conv_tb ();

    localparam int DATA_WIDTH_IN = 32;
    localparam int DATA_WIDTH_OUT = 128;
    localparam int RESET_DELAY = 10;
    localparam int CLK_PER_NS = 2;

    logic clk_i;
    logic rstn_i;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH_IN),
    ) s_axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH_OUT),
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

    end

    initial begin
        $dumpfile("axis_dw_conv_tb.vcd");
        $dumpvars(0, axis_dw_conv_tb);
    end

    axis_dw_conv #(
        .DATA_WIDTH_IN (DATA_WIDTH_IN),
        .DATA_WIDTH_OUT(DATA_WIDTH_OUT)
    ) dut (
        .m_axis(s_axis),
        .s_axis(m_axis)
    );

endmodule
