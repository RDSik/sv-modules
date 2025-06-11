`timescale 1ns/1ps

`include "modules/verification/tb/test_pkg.svh"

module axis_spi_top_tb ();

import test_pkg::*;

localparam int SPI_MODE    = 3;
localparam int MAIN_CLK    = 27_000_000;
localparam int SPI_CLK     = 6_750_000;
localparam int SLAVE_NUM   = 1;
localparam int WAIT_TIME   = 50;
localparam int DIVIDER     = MAIN_CLK/SPI_CLK;
localparam int CLK_PER_NS  = 10**9/MAIN_CLK;
localparam int RESET_DELAY = 10;

logic                 clk_i;
logic                 arstn_i;
logic                 spi_data;
logic                 spi_clk_o;
logic [SLAVE_NUM-1:0] spi_cs_o;


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
    $display("Reset done in: %0t ns\n.", $time());
end

initial begin
    clk_i = 1'b0;
    forever begin
        #(CLK_PER_NS/2) clk_i = ~clk_i;
    end
end

initial begin
    test_base test;
    test = new(s_axis, m_axis);
    test.run();
end

initial begin
    $dumpfile("axis_spi_top_tb.vcd");
    $dumpvars(0, axis_spi_top_tb);
end

axis_spi_master #(
    .SLAVE_NUM     (SLAVE_NUM),
    .WAIT_TIME     (WAIT_TIME)
) dut (
    .clk_divider_i (DIVIDER  ),
    .mode_i        (SPI_MODE ),
    .addr_i        ('0       ),
    .spi_clk_o     (spi_clk_o),
    .spi_cs_o      (spi_cs_o ),
    .spi_mosi_o    (spi_data ),
    .spi_miso_i    (spi_data ),
    .s_axis        (m_axis   ),
    .m_axis        (s_axis   )
);

endmodule
