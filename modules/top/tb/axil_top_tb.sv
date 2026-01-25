`timescale 1ns / 1ps

`include "modules/spi/tb/axil_spi_class.svh"
`include "modules/uart/tb/axil_uart_class.svh"
`include "modules/i2c/tb/axil_i2c_class.svh"
`include "modules/rgmii/tb/axil_rgmii_class.svh"

module axil_top_tb ();

    localparam int FIFO_DEPTH = 128;
    localparam int CS_WIDTH = 8;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;
    localparam int MASTER_NUM = 1;
    localparam int SLAVE_NUM = 4;

    localparam logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_LOW_ADDR = '{
        32'h43c0_0000,
        32'h43c1_0000,
        32'h43c2_0000,
        32'h43c3_0000
    };
    localparam logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_HIGH_ADDR = '{
        32'h43c0_ffff,
        32'h43c1_ffff,
        32'h43c2_ffff,
        32'h43c3_ffff
    };

    localparam int WAT_CYCLES = 250;
    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic clk_i;
    logic rstn_i;
    logic uart;

    spi_if #(.CS_WIDTH(CS_WIDTH)) m_spi ();

    assign m_spi.miso = m_spi.mosi;

    rgmii_if rgmii_if ();

    assign rgmii_if.rxd    = rgmii_if.txd;
    assign rgmii_if.rx_ctl = rgmii_if.tx_ctl;
    assign rgmii_if.rxc    = clk_i;

    axis_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) m_axis (
        .clk_i(clk_i),
        .rst_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axis (
        .clk_i(clk_i),
        .rst_i(rstn_i)
    );

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil[MASTER_NUM-1:0] (
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
        axil_uart_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (SLAVE_LOW_ADDR[0])
        ) uart;
        axil_spi_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (SLAVE_LOW_ADDR[1])
        ) spi;
        axil_i2c_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (SLAVE_LOW_ADDR[2])
        ) i2c;
        axil_rgmii_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .TLAST_EN  (1),
            .BASE_ADDR (SLAVE_LOW_ADDR[3])
        ) rgmii;
        uart  = new(s_axil[0]);
        spi   = new(s_axil[0]);
        rgmii = new(s_axil[0], m_axis, s_axis);
        i2c   = new(s_axil[0]);
        uart.uart_start();
        spi.spi_start();
        i2c.i2c_start();
        rgmii.rgmii_start();
        $stop;
    end

    initial begin
        $dumpfile("axil_top_tb.vcd");
        $dumpvars(0, axil_top_tb);
    end

    axil_top #(
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .SPI_CS_WIDTH   (CS_WIDTH),
        .RGMII_WIDTH    (rgmii_if.DATA_WIDTH),
        .SLAVE_NUM      (SLAVE_NUM),
        .MASTER_NUM     (MASTER_NUM),
        .SLAVE_LOW_ADDR (SLAVE_LOW_ADDR),
        .SLAVE_HIGH_ADDR(SLAVE_HIGH_ADDR),
        .ILA_EN         (0),
        .MODE           ("sync"),
        .VENDOR         ("")
    ) i_axil_top (
        .clk_i    (clk_i),
        .uart_rx_i(uart),
        .uart_tx_o(uart),
        .s_axil   (s_axil),
        .s_axis   (m_axis),
        .m_axis   (s_axis),
        .m_spi    (m_spi),
        .rgmii    (rgmii_if)
    );

endmodule
