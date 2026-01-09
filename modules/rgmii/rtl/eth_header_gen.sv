`include "rgmii_pkg.svh"

module eth_header_gen
    import rgmii_pkg::*;
#(
    parameter int PAYLOAD_WIDTH = 11
) (
    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    input logic [PAYLOAD_WIDTH-1:0] payload_bytes_i,

    output ethernet_header_t output_header_o
);

    localparam logic [15:0] HEADER_CHECKSUM = 16'h65b3;
    localparam logic [15:0] ETHERTYPE = 16'h0800;
    localparam logic [7:0] VERSION_IHL = 8'h45;
    localparam logic [7:0] TOS = 8'h00;
    localparam logic [15:0] IDENTIFICATION = 16'h0000;
    localparam logic [15:0] FLAGS_FRAGMENT_OFFSET = 16'h0000;
    localparam logic [7:0] TIME_TO_LIVE = 8'h40;
    localparam logic [7:0] PROTOCOL = 8'h11;
    localparam logic [15:0] UDP_CHECKSUM = 16'h0000;

    logic [15:0] udp_length;
    assign udp_length = UDP_HEADER_BYTES + payload_bytes_i;

    logic [15:0] ipv4_length;
    assign ipv4_length = IPV4_HEADER_BYTES + payload_bytes_i;

    ethernet_header_t header;

    assign header.mac_source                 = {<<8{fpga_mac_i}};
    assign header.mac_destination            = {<<8{host_mac_i}};
    assign header.eth_type_length            = {<<8{ETHERTYPE}};

    assign header.ipv4.version_ihl           = {<<8{VERSION_IHL}};
    assign header.ipv4.tos               = {<<8{TOS}};
    assign header.ipv4.total_length          = {<<8{ipv4_length}};
    assign header.ipv4.identification        = {<<8{IDENTIFICATION}};
    assign header.ipv4.flags_fragment_offset = {<<8{FLAGS_FRAGMENT_OFFSET}};
    assign header.ipv4.time_to_live          = {<<8{TIME_TO_LIVE}};
    assign header.ipv4.protocol              = {<<8{PROTOCOL}};
    assign header.ipv4.header_checksum       = {<<8{HEADER_CHECKSUM}};
    assign header.ipv4.ip_source             = {<<8{fpga_ip_i}};
    assign header.ipv4.ip_destination        = {<<8{host_ip_i}};

    assign header.ipv4.udp.port_source       = {<<8{fpga_port_i}};
    assign header.ipv4.udp.port_destination  = {<<8{host_port_i}};
    assign header.ipv4.udp.length            = {<<8{udp_length}};
    assign header.ipv4.udp.udp_checksum      = {<<8{UDP_CHECKSUM}};

    assign output_header_o                   = header;

endmodule
