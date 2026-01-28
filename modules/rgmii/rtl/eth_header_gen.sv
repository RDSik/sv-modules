`include "rgmii_pkg.svh"

module eth_header_gen
    import rgmii_pkg::*;
#(
    parameter int PAYLOAD_WIDTH = 11
) (
    input logic clk_i,

    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    input logic [PAYLOAD_WIDTH-1:0] payload_bytes_i,

    output ethernet_header_t output_header_o
);

    localparam logic [15:0] ETHERTYPE = 16'h0800;
    localparam logic [7:0] VERSION_IHL = 8'h45;
    localparam logic [7:0] TOS = 8'h00;
    localparam logic [15:0] IDENTIFICATION = 16'h0000;
    localparam logic [15:0] FLAGS_FRAGMENT_OFFSET = 16'h0000;
    localparam logic [7:0] TIME_TO_LIVE = 8'h40;
    localparam logic [7:0] PROTOCOL = 8'h11;
    localparam logic [15:0] UDP_CHECKSUM = 16'h0000;

    logic [15:0] udp_length;
    logic [15:0] ipv4_length;
    logic [31:0] temp_sum;
    logic [31:0] sum;
    logic [15:0] header_checksum;

    ethernet_header_t header;

    always_ff @(posedge clk_i) begin
        udp_length <= UDP_HEADER_BYTES + payload_bytes_i;
        ipv4_length <= IPV4_HEADER_BYTES + udp_length;
        temp_sum  <= {VERSION_IHL, TOS} + ipv4_length + IDENTIFICATION + FLAGS_FRAGMENT_OFFSET + {TIME_TO_LIVE, PROTOCOL} + fpga_ip_i[31:16] + fpga_ip_i[15:0] + host_ip_i[31:16] + host_ip_i[15:0];
        sum <= temp_sum[15:0] + temp_sum[31:16];
        header_checksum <= ~(sum[15:0] + sum[31:16]);
    end

    always_comb begin
        header.mac_source = {<<8{fpga_mac_i}};
        header.mac_destination = {<<8{host_mac_i}};
        header.eth_type_length = {<<8{ETHERTYPE}};

        header.ipv4.version_ihl = {<<8{VERSION_IHL}};
        header.ipv4.tos = {<<8{TOS}};
        header.ipv4.total_length = {<<8{ipv4_length}};
        header.ipv4.identification = {<<8{IDENTIFICATION}};
        header.ipv4.flags_fragment_offset = {<<8{FLAGS_FRAGMENT_OFFSET}};
        header.ipv4.time_to_live = {<<8{TIME_TO_LIVE}};
        header.ipv4.protocol = {<<8{PROTOCOL}};
        header.ipv4.header_checksum = {<<8{header_checksum}};
        header.ipv4.ip_source = {<<8{fpga_ip_i}};
        header.ipv4.ip_destination = {<<8{host_ip_i}};

        header.ipv4.udp.port_source = {<<8{fpga_port_i}};
        header.ipv4.udp.port_destination = {<<8{host_port_i}};
        header.ipv4.udp.length = {<<8{udp_length}};
        header.ipv4.udp.udp_checksum = {<<8{UDP_CHECKSUM}};
    end

    assign output_header_o = header;

endmodule
