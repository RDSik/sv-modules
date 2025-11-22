`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_spi_tb ();

    import test_pkg::*;

    localparam int MAIN_CLK = 27_000_000;
    localparam int SPI_CLK = 6_750_000;

    localparam int SLAVE_NUM = 1;
    localparam int WAIT_TIME = 100;
    localparam int DIVIDER_WIDTH = 32;
    localparam int WAIT_WIDTH = 32;
    localparam int DATA_WIDTH = 8;

    localparam int CLK_PER_NS = 10 ** 9 / MAIN_CLK;
    localparam int RESET_DELAY = 10;

    localparam logic CPHA = 0;
    localparam logic CPOL = 0;
    localparam int DIVIDER = MAIN_CLK / SPI_CLK;

    logic clk_i;
    logic rst_i;

    spi_if #(.CS_WIDTH(SLAVE_NUM)) m_spi ();

    assign m_spi.miso = m_spi.mosi;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) s_axis (
        .clk_i(clk_i),
        .rst_i(rst_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
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
            .DATA_WIDTH_IN (DATA_WIDTH),
            .DATA_WIDTH_OUT(DATA_WIDTH),
            .TLAST_EN      (1)
        ) env;
        env = new(s_axis, m_axis);
        env.run();
    end

    initial begin
        $dumpfile("axis_spi_tb.vcd");
        $dumpvars(0, axis_spi_tb);
    end

    axis_spi_master #(
        .SLAVE_NUM    (SLAVE_NUM),
        .WAIT_WIDTH   (WAIT_WIDTH),
        .DIVIDER_WIDTH(DIVIDER_WIDTH),
        .DATA_WIDTH   (DATA_WIDTH)
    ) dut (
        .wait_time_i  (WAIT_TIME),
        .clk_divider_i(DIVIDER),
        .cpol_i       (CPHA),
        .cpha_i       (CPOL),
        .addr_i       ('0),
        .m_spi        (m_spi),
        .s_axis       (m_axis),
        .m_axis       (s_axis)
    );

endmodule
