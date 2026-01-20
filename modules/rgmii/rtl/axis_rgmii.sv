module axis_rgmii #(
    parameter int RGMII_WIDTH     = 4,
    parameter int PAYLOAD_WIDTH   = 11,
    parameter int AXIS_DATA_WIDTH = 8
) (
    inout        eth_mdio_io,
    output logic eth_mdc_o,

    output logic                   eth_tx_clk_o,
    output logic [RGMII_WIDTH-1:0] eth_txd_o,
    output logic                   eth_tx_ctl_o,

    input logic                   eth_rx_clk_i,
    input logic [RGMII_WIDTH-1:0] eth_rxd_i,
    input logic                   eth_rx_ctl_i,

    input logic check_destination_i,

    input logic [PAYLOAD_WIDTH-1:0] payload_bytes_i,

    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    output logic crc_err_o,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    localparam int GMII_WIDTH = 8;

    logic [GMII_WIDTH-1:0] tx_d;
    logic                  tx_en;

    packet_gen #(
        .GMII_WIDTH     (GMII_WIDTH),
        .PAYLOAD_WIDTH  (PAYLOAD_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
    ) i_packet_gen (
        .tx_en_o        (tx_en),
        .tx_d_o         (tx_d),
        .payload_bytes_i(payload_bytes_i),
        .fpga_port_i    (fpga_port_i),
        .fpga_ip_i      (fpga_ip_i),
        .fpga_mac_i     (fpga_mac_i),
        .host_port_i    (host_port_i),
        .host_ip_i      (host_ip_i),
        .host_mac_i     (host_mac_i),
        .s_axis         (s_axis)
    );

    logic [GMII_WIDTH-1:0] rx_d;
    logic                  rx_dv;

    packet_recv #(
        .GMII_WIDTH     (GMII_WIDTH),
        .PAYLOAD_WIDTH  (PAYLOAD_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
    ) i_packet_recv (
        .rx_dv_i            (rx_dv),
        .rx_d_i             (rx_d),
        .check_destination_i(check_destination_i),
        .payload_bytes_i    (payload_bytes_i),
        .fpga_port_i        (fpga_port_i),
        .fpga_ip_i          (fpga_ip_i),
        .fpga_mac_i         (fpga_mac_i),
        .host_port_i        (host_port_i),
        .host_ip_i          (host_ip_i),
        .host_mac_i         (host_mac_i),
        .crc_err_o          (crc_err_o),
        .m_axis             (m_axis)
    );

    BUFG BUFG_inst (
        .I(eth_rx_clk_i),  // 1-bit input: Clock input
        .O(eth_tx_clk_o)   // 1-bit output: Clock output
    );

    rgmii_tx #(
        .GMII_WIDTH (GMII_WIDTH),
        .RGMII_WIDTH(RGMII_WIDTH)
    ) i_rgmii_tx (
        .clk_i         (eth_rx_clk_i),
        .gmii_tx_en_i  (tx_en),
        .gmii_txd_i    (tx_d),
        .rgmii_txd_o   (eth_txd_o),
        .rgmii_tx_ctl_o(eth_tx_ctl_o)
    );

    rgmii_rx #(
        .GMII_WIDTH (GMII_WIDTH),
        .RGMII_WIDTH(RGMII_WIDTH)
    ) i_rgmii_rx (
        .clk_i         (eth_rx_clk_i),
        .rgmii_rx_ctl_i(eth_rx_ctl_i),
        .rgmii_rxd_i   (eth_rxd_i),
        .gmii_rx_en_o  (rx_dv),
        .gmii_rxd_o    (rx_d)
    );

endmodule
