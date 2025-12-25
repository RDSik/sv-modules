`timescale 1ns / 1ps

`include "modules/spi/tb/axil_spi_class.svh"

module axil_spi_tb ();

    localparam int FIFO_DEPTH = 128;
    localparam int CS_WIDTH = 8;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic clk_i;
    logic rstn_i;

    spi_if #(.CS_WIDTH(CS_WIDTH)) m_spi ();

    assign m_spi.miso = m_spi.mosi;

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil (
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
        axil_spi_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (BASE_ADDR)
        ) spi;
        spi = new(s_axil);
        spi.spi_start();
        #10 $stop;
    end

    initial begin
        $dumpfile("axil_spi_tb.vcd");
        $dumpvars(0, axil_spi_tb);
    end

    axil_spi #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .SLAVE_NUM      (CS_WIDTH),
        .ILA_EN         (0),
        .MODE           ("sync")
    ) i_axil_spi (
        .clk_i (clk_i),
        .s_axil(s_axil),
        .m_spi (m_spi)
    );

endmodule
