`ifndef RMII_PKG_SVH
`define RMII_PKG_SVH

package rmii_pkg;

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

endpackage

`endif  // RMII_PKG_SVH
