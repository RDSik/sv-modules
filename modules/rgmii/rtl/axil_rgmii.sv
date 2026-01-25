`include "rgmii_pkg.svh"

module axil_rgmii
    import rgmii_pkg::*;
#(
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   RGMII_WIDTH     = 4,
    parameter logic ILA_EN          = 0,
    parameter       MODE            = "sync",
    parameter       VENDOR          = "xilinx"
) (
    inout        eth_mdio_io,
    output logic eth_mdc_o,

    rgmii_if rgmii,

    axis_if.slave  s_axis,
    axis_if.master m_axis,

    axil_if.slave s_axil
);

    localparam int PAYLOAD_WIDTH = 11;
    localparam int AXIS_DATA_WIDTH = 8;

    rgmii_reg_t                     rd_regs;
    rgmii_reg_t                     wr_regs;

    logic       [RGMII_REG_NUM-1:0] rd_request;
    logic       [RGMII_REG_NUM-1:0] rd_valid;
    logic       [RGMII_REG_NUM-1:0] wr_valid;

    axil_reg_file_wrap #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (RGMII_REG_NUM),
        .reg_t         (rgmii_reg_t),
        .REG_INIT      (RGMII_REG_INIT),
        .ILA_EN        (ILA_EN),
        .MODE          (MODE)
    ) i_axil_reg_file (
        .clk_i       (rgmii.rxc),
        .s_axil      (s_axil),
        .rd_regs_i   (rd_regs),
        .rd_valid_i  (rd_valid),
        .rd_request_o(rd_request),
        .wr_regs_o   (wr_regs),
        .wr_valid_o  (wr_valid)
    );

    logic reset;

    assign reset = wr_regs.control.reset;

    logic crc_err;

    always_comb begin
        rd_valid                 = '1;
        rd_regs                  = wr_regs;

        rd_regs.param.reg_num    = RGMII_REG_NUM;
        rd_regs.param.fifo_depth = 2 ** PAYLOAD_WIDTH;

        rd_regs.status.crc_err   = crc_err;
    end

    axis_if #(
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axis_dw_conv (
        .clk_i(rgmii.rxc),
        .rst_i(reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) m_axis_dw_conv (
        .clk_i(rgmii.rxc),
        .rst_i(reset)
    );

    axis_rgmii #(
        .PAYLOAD_WIDTH  (PAYLOAD_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
        .RGMII_WIDTH    (RGMII_WIDTH),
        .VENDOR         (VENDOR)
    ) i_axis_rgmii (
        .rst_i              (reset),
        .eth_mdio_io        (eth_mdio_io),
        .eth_mdc_o          (eth_mdc_o),
        .check_destination_i(wr_regs.control.check_destination),
        .payload_bytes_i    (wr_regs.control.payload_bytes),
        .fpga_port_i        (wr_regs.port.fpga),
        .fpga_ip_i          (wr_regs.ip.fpga),
        .fpga_mac_i         (wr_regs.mac.fpga),
        .host_port_i        (wr_regs.port.host),
        .host_ip_i          (wr_regs.ip.host),
        .host_mac_i         (wr_regs.mac.host),
        .crc_err_o          (crc_err),
        .rgmii              (rgmii),
        .s_axis             (m_axis_dw_conv),
        .m_axis             (s_axis_dw_conv)
    );

    localparam int CDC_REG_NUM = 3;
    localparam logic TLAST_EN = 1;

    axis_dw_conv_wrap #(
        .DATA_WIDTH_IN (AXIL_DATA_WIDTH),
        .DATA_WIDTH_OUT(AXIS_DATA_WIDTH),
        .FIFO_DEPTH    (2 ** PAYLOAD_WIDTH),
        .CDC_REG_NUM   (CDC_REG_NUM),
        .TLAST_EN      (TLAST_EN),
        .FIFO_FIRST    (0),
        .MODE          (MODE)
    ) i_s_dw_conv (
        .m_axis(m_axis_dw_conv),
        .s_axis(s_axis)
    );

    axis_dw_conv_wrap #(
        .DATA_WIDTH_IN (AXIS_DATA_WIDTH),
        .DATA_WIDTH_OUT(AXIL_DATA_WIDTH),
        .FIFO_DEPTH    (2 ** PAYLOAD_WIDTH),
        .CDC_REG_NUM   (CDC_REG_NUM),
        .TLAST_EN      (TLAST_EN),
        .FIFO_FIRST    (1),
        .MODE          (MODE)
    ) i_m_dw_conv (
        .m_axis(m_axis),
        .s_axis(s_axis_dw_conv)
    );

endmodule
