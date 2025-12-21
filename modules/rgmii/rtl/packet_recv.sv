`include "../rtl/rgmii_pkg.svh"

module packet_recv
    import rgmii_pkg::*;
#(
    parameter logic CHECK_DESTINATION = 1,
    parameter int   GMII_WIDTH        = 8,
    parameter int   AXIS_DATA_WIDTH   = 8

) (
    input logic [GMII_WIDTH-1:0] rx_d_i,
    input logic                  rx_dv_i,

    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    axis_if.master m_axis
);

    localparam int WORD_BYTES = 4;

    logic clk_i;
    logic rst_i;

    assign clk_i = m_axis.clk_i;
    assign rst_i = m_axis.rst_i;

    logic [2:0][GMII_WIDTH-1:0] rxd_z;
    logic [2:0]                 rxdv_z;

    logic [7:0]                 first_i_packet_count;

    localparam int FIRST_PACKET_IGNORE = 0;

    always @(posedge clk_i) begin
        if (rst_i) begin
            rxd_z                <= 0;
            rxdv_z               <= 0;
            first_i_packet_count <= 0;
        end else begin
            rxd_z[0]    <= rx_d_i;
            rxd_z[2:1]  <= rxd_z[1:0];
            rxdv_z[0]   <= rx_dv_i;
            rxdv_z[2:1] <= rxdv_z[1:0];
            if (packet_done & first_i_packet_count < FIRST_PACKET_IGNORE) begin
                first_i_packet_count <= first_i_packet_count + 1;
            end
        end
    end

    logic packet_done;
    logic packet_start;

    assign packet_start = (~rxdv_z[2] & rxdv_z[1]);
    assign packet_done  = (rxdv_z[2] & ~rxdv_z[1]);

    localparam int HEADER_BYTES = $bits(ethernet_header_t) / 2;
    localparam int PREAMBLE_SFD_BYTES = 8 * 8 / GMII_WIDTH;
    localparam int FCS_BYTES = 4 * 8 / GMII_WIDTH;

    logic             [AXIS_DATA_WIDTH-1:0] data_buffer;
    logic             [               63:0] preamble_sfd_buffer;
    logic             [               63:0] preamble_sfd_buffer_next;
    ethernet_header_t                       header_buffer;

    typedef enum {
        IDLE,
        PREAMBLE_SFD,
        HEADER,
        DATA
    } state_type_t;

    state_type_t        current_state = IDLE;
    state_type_t        next_state = IDLE;

    logic        [31:0] state_counter;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state_counter <= '0;
        end else begin
            if (current_state != next_state) begin
                state_counter <= '0;
            end else begin
                state_counter <= state_counter + 1'b1;
            end
        end
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (packet_start) begin
                    next_state = PREAMBLE_SFD;
                end
            end
            PREAMBLE_SFD: begin
                if (preamble_sfd_buffer_next == 64'hd555555555555555) begin
                    next_state = HEADER;
                end
            end
            HEADER: begin
                if (state_counter == HEADER_BYTES - 1) begin
                    next_state = DATA;
                end
                if (packet_done) begin
                    next_state = IDLE;
                end
            end
            DATA: begin
                if (packet_done) begin
                    next_state = IDLE;
                end
            end
            default: next_state = current_state;
        endcase
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    logic data_valid;
    logic data_last;

    logic [47:0] packet_destination;
    assign packet_destination              = {<<8{header_buffer.mac_destination}};

    assign preamble_sfd_buffer_next[63:56] = rst_i ? 0 : rxd_z[2];
    assign preamble_sfd_buffer_next[55:0]  = rst_i ? 0 : preamble_sfd_buffer[63:8];

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            preamble_sfd_buffer <= 0;
            header_buffer       <= 0;
            data_buffer         <= 0;
            data_valid          <= 0;
            data_last           <= 0;
        end else begin
            data_valid <= 0;
            data_last  <= 0;
            if (current_state == PREAMBLE_SFD) begin
                preamble_sfd_buffer <= preamble_sfd_buffer_next;
            end
            if (current_state == HEADER) begin
                header_buffer[(HEADER_BYTES*GMII_WIDTH)-1-:GMII_WIDTH] <= rxd_z[2];
                header_buffer[(HEADER_BYTES*GMII_WIDTH)-9:0] <= header_buffer[(HEADER_BYTES*GMII_WIDTH)-1:GMII_WIDTH];
            end
            if (current_state == DATA) begin
                // data_buffer[7:6] <= rxd_z[2];
                // data_buffer[5:0] <= data_buffer[7:2];
                // if ((state_counter[1:0]==3) && (~CHECK_DESTINATION || (packet_destination == fpga_mac_i))) begin
                data_buffer <= rxd_z[2];
                if (~CHECK_DESTINATION || (packet_destination == fpga_mac_i)) begin
                    data_valid <= 1;
                end
                if (packet_done) begin
                    data_last <= 1;
                end
            end
        end
    end

    assign m_axis.tvalid = data_valid;
    assign m_axis.tdata  = data_buffer;
    assign m_axis.tlast  = data_last;

endmodule
