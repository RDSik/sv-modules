`timescale 1ns / 1ps

`include "modules/rgmii/tb/axil_rgmii_class.svh"

module axil_rgmii_tb ();

    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;
    localparam int RGMII_WIDTH = 4;

    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic clk_i;
    logic rstn_i;

    eth_if #(.DATA_WIDTH(RGMII_WIDTH)) m_eth ();

    assign m_eth.rxd    = m_eth.txd;
    assign m_eth.rx_ctl = m_eth.tx_ctl;
    assign m_eth.rx_clk = clk_i;

    axis_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH / 4)
    ) m_axis (
        .clk_i(clk_i),
        .rst_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH / 4)
    ) s_axis (
        .clk_i(clk_i),
        .rst_i(rstn_i)
    );

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
        axil_rgmii_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .TLAST_EN  (1),
            .BASE_ADDR (BASE_ADDR)
        ) rgmii;
        rgmii = new(s_axil, m_axis, s_axis);
        rgmii.rgmii_start();
        #10 $stop;
    end

    initial begin
        $dumpfile("axil_rgmii_tb.vcd");
        $dumpvars(0, axil_rgmii_tb);
    end

    axil_rgmii #(
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .ILA_EN         (0),
        .MODE           ("sync"),
        .VENDOR         ("")
    ) i_axil_rgmii (
        .s_axil(s_axil),
        .s_axis(m_axis),
        .m_axis(s_axis),
        .m_eth (m_eth)
    );

endmodule
