`ifndef RGMII_PKG_SVH
`define RGMII_PKG_SVH

package rgmii_pkg;

    typedef struct packed {
        logic [1:0][7:0] udp_checksum;
        logic [1:0][7:0] length;
        logic [1:0][7:0] port_destination;
        logic [1:0][7:0] port_source;
    } udp_header_t;

    typedef struct packed {
        udp_header_t     udp;
        logic [3:0][7:0] ip_destination;
        logic [3:0][7:0] ip_source;
        logic [1:0][7:0] header_checksum;
        logic [7:0]      protocol;
        logic [7:0]      time_to_live;
        logic [1:0][7:0] flags_fragment_offset;
        logic [1:0][7:0] identification;
        logic [1:0][7:0] total_length;
        logic [7:0]      dcsp_ecn;
        logic [7:0]      version_ihl;
    } ipv4_header_t;

    typedef struct packed {
        ipv4_header_t ipv4;
        logic [1:0][7:0] eth_type_length;
        logic [5:0][7:0] mac_source;
        logic [5:0][7:0] mac_destination;
    } ethernet_header_t;

    localparam logic [15:0] UDP_HEADER_BYTES = $bits(udp_header_t) / 8;
    localparam logic [15:0] IPV4_HEADER_BYTES = $bits(ipv4_header_t) / 8;
    localparam int HEADER_BYTES = $bits(ethernet_header_t) / 8;
    localparam int SFD_BYTES = 1;
    localparam int PREAMBLE_BYTES = 7;
    localparam int FCS_BYTES = 4;

    localparam logic [55:0] PREAMBULE_VAL = 56'h55555555555555;
    localparam logic [7:0] SFD_VAL = 8'hd5;

endpackage

`endif  // RGMII_PKG_SVH
