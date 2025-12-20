module axis_rmii #(
    parameter logic [15:0] HEADER_CHECKSUM   = 16'h65b3,
    parameter logic        CHECK_DESTINATION = 1,
    parameter int          MII_WIDTH         = 2,
    parameter int          FIFO_DEPTH        = 2048,
    parameter int          AXIS_DATA_WIDTH   = 8,
    parameter int          AXIS_USER_WIDTH   = 11
) (
    inout        eth_mdio_io,
    output logic eth_mdc_o,

    input  logic                 eth_crsdv_i,
    input  logic                 eth_rxerr_i,
    input  logic [MII_WIDTH-1:0] eth_rxd_i,
    output logic [MII_WIDTH-1:0] eth_txd_o,
    output logic                 eth_ten_o,

    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    packet_gen #(
        .HEADER_CHECKSUM(HEADER_CHECKSUM),
        .MII_WIDTH      (MII_WIDTH),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
        .AXIS_USER_WIDTH(AXIS_USER_WIDTH)
    ) packet_gen_i (
        .tx_en_o    (eth_ten_o),
        .tx_d_o     (eth_txd_o),
        .fpga_port_i(fpga_port_i),
        .fpga_ip_i  (fpga_ip_i),
        .fpga_mac_i (fpga_mac_i),
        .host_port_i(host_port_i),
        .host_ip_i  (host_ip_i),
        .host_mac_i (host_mac_i),
        .s_axis     (s_axis)
    );

    packet_recv #(
        .CHECK_DESTINATION(CHECK_DESTINATION),
        .MII_WIDTH        (MII_WIDTH),
        .AXIS_DATA_WIDTH  (AXIS_DATA_WIDTH)
    ) packet_recv_i (
        .rx_dv_i    (eth_crsdv_i),
        .rx_d_i     (eth_rxd_i),
        .fpga_port_i(fpga_port_i),
        .fpga_ip_i  (fpga_ip_i),
        .fpga_mac_i (fpga_mac_i),
        .host_port_i(host_port_i),
        .host_ip_i  (host_ip_i),
        .host_mac_i (host_mac_i),
        .m_axis     (m_axis)
    );

endmodule
