module axil_rgmii #(
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   RGMII_WIDTH     = 4,
    parameter logic ILA_EN          = 0,
    parameter       MODE            = "sync"
) (
    input logic clk_i,

    inout        eth_mdio_io,
    output logic eth_mdc_o,

    output logic                   eth_txc_o,
    output logic [RGMII_WIDTH-1:0] eth_txd_o,
    output logic                   eth_tx_ctl_o,

    input logic [RGMII_WIDTH-1:0] eth_rxd_i,
    input logic                   eth_rx_ctl_i,

    axis_if.slave  s_axis,
    axis_if.master m_axis,

    axil_if.slave s_axil
);

    localparam int PAYLOAD_WIDTH = 11;
    localparam int AXIS_DATA_WIDTH = 8;

    logic eth_rxc;
    logic rst;

    clk_wiz_eth(
        .reset(rst), .clk_in1(clk_i), .clk_out1(eth_rxc)
    );

    xpm_cdc_async_rst #(
        .DEST_SYNC_FF   (3),
        .INIT_SYNC_FF   (0),
        .RST_ACTIVE_HIGH(0)
    ) i_xpm_cdc_async_rst (
        .src_arst (~s_axil.rstn_i),
        .dest_clk (eth_rxc),
        .dest_arst(rst)
    );

    axil_reg_file_wrap #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (),
        .reg_t         (),
        .REG_INIT      (),
        .ILA_EN        (ILA_EN),
        .MODE          (MODE)
    ) i_axil_reg_file (
        .clk_i       (eth_rxc),
        .s_axil      (s_axil),
        .rd_regs_i   (),
        .rd_valid_i  (),
        .rd_request_o(),
        .wr_regs_o   (),
        .wr_valid_o  ()
    );

    axis_rgmii #(
        .PAYLOAD_WIDTH  (PAYLOAD_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
        .RGMII_WIDTH    (RGMII_WIDTH)
    ) i_axis_rgmii (
        .eth_mdio_io        (eth_mdio_io),
        .eth_mdc_o          (eth_mdc_o),
        .eth_txd_o          (eth_txd_o),
        .eth_tx_ctl_o       (eth_tx_ctl_o),
        .eth_txc_o          (eth_txc_o),
        .eth_rxc_i          (eth_rxc),
        .eth_rxd_i          (eth_rxd_i),
        .eth_rx_ctl_i       (eth_rx_ctl_i),
        .check_destination_i(),
        .payload_bytes_i    (),
        .fpga_port_i        (),
        .fpga_ip_i          (),
        .fpga_mac_i         (),
        .host_port_i        (),
        .host_ip_i          (),
        .host_mac_i         (),
        .crc_err_o          (),
        .s_axis             (s_axis),
        .m_axis             (m_axis)
    );

endmodule
