`timescale 1ns / 1ps

`include "../../verification/tb/test_pkg.svh"

module axis_rgmii_tb ();

    import test_pkg::*;

    localparam int GMII_WIDTH = 8;
    localparam int PAYLOAD_WIDTH = 11;
    localparam int AXIS_DATA_WIDTH = 8;

    localparam int RESET_DELAY = 10;
    localparam int CLK_PER_NS = 2;

    localparam logic CHECK_DESTINATION = 1;
    localparam logic [7:0] FPGA_IP_1 = 10;
    localparam logic [7:0] FPGA_IP_2 = 0;
    localparam logic [7:0] FPGA_IP_3 = 0;
    localparam logic [7:0] FPGA_IP_4 = 240;
    localparam logic [7:0] HOST_IP_1 = 10;
    localparam logic [7:0] HOST_IP_2 = 0;
    localparam logic [7:0] HOST_IP_3 = 0;
    localparam logic [7:0] HOST_IP_4 = 10;
    localparam logic [15:0] FPGA_PORT = 17767;
    localparam logic [15:0] HOST_PORT = 17767;
    localparam logic [47:0] FPGA_MAC = 48'he86a64e7e830;
    localparam logic [47:0] HOST_MAC = 48'he86a64e7e829;

    localparam logic [PAYLOAD_WIDTH-1:0] PAYLOAD = 340;
    localparam logic [31:0] HOST_IP = {HOST_IP_1, HOST_IP_2, HOST_IP_3, HOST_IP_4};
    localparam logic [31:0] FPGA_IP = {FPGA_IP_1, FPGA_IP_2, FPGA_IP_3, FPGA_IP_4};

    logic                  clk_i;
    logic                  rst_i;
    logic [GMII_WIDTH-1:0] data;
    logic                  en;

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) s_axis (
        .clk_i(clk_i),
        .rst_i(rst_i)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
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
            .DATA_WIDTH_IN (AXIS_DATA_WIDTH),
            .DATA_WIDTH_OUT(AXIS_DATA_WIDTH),
            .TLAST_EN      (0)
        ) env;
        env = new(s_axis, m_axis);
        env.run();
    end

    initial begin
        $dumpfile("axis_rgmii_tb.vcd");
        $dumpvars(0, axis_rgmii_tb);
    end

    packet_gen #(
        .GMII_WIDTH     (GMII_WIDTH),
        .PAYLOAD_WIDTH  (PAYLOAD_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
    ) i_packet_gen (
        .clk_i          (clk_i),
        .rst_i          (rst_i),
        .tx_en_o        (en),
        .tx_d_o         (data),
        .payload_bytes_i(PAYLOAD),
        .fpga_port_i    (FPGA_PORT),
        .fpga_ip_i      (FPGA_IP),
        .fpga_mac_i     (FPGA_MAC),
        .host_port_i    (HOST_PORT),
        .host_ip_i      (HOST_IP),
        .host_mac_i     (HOST_MAC),
        .s_axis         (m_axis)
    );

    packet_recv #(
        .GMII_WIDTH     (GMII_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
    ) i_packet_recv (
        .clk_i              (clk_i),
        .rst_i              (rst_i),
        .rx_dv_i            (en),
        .rx_d_i             (data),
        .check_destination_i(CHECK_DESTINATION),
        .payload_bytes_i    (PAYLOAD),
        .fpga_port_i        (FPGA_PORT),
        .fpga_ip_i          (FPGA_IP),
        .fpga_mac_i         (FPGA_MAC),
        .host_port_i        (HOST_PORT),
        .host_ip_i          (HOST_IP),
        .host_mac_i         (HOST_MAC),
        .m_axis             (s_axis)
    );

endmodule
