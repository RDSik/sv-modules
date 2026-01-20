`include "rgmii_pkg.svh"

module packet_recv
    import rgmii_pkg::*;
#(
    parameter int GMII_WIDTH      = 8,
    parameter int PAYLOAD_WIDTH   = 11,
    parameter int AXIS_DATA_WIDTH = 8
) (
    input logic [GMII_WIDTH-1:0] rx_d_i,
    input logic                  rx_dv_i,

    input logic check_destination_i,

    input logic [PAYLOAD_WIDTH-1:0] payload_bytes_i,

    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    output logic crc_err_o,

    axis_if.master m_axis
);

    logic clk_i;
    logic rst_i;

    assign clk_i = m_axis.clk_i;
    assign rst_i = m_axis.rst_i;

    logic [2:0][GMII_WIDTH-1:0] rxd_z;
    logic [2:0]                 rxdv_z;

    logic                       packet_done;
    logic                       packet_start;

    assign packet_start = (rxdv_z[2] == 0 && rxdv_z[1] == 1);
    assign packet_done  = (rxdv_z[2] == 1 && rxdv_z[1] == 0);

    always @(posedge clk_i) begin
        if (rst_i) begin
            rxd_z  <= 0;
            rxdv_z <= 0;
        end else begin
            rxd_z  <= {rxd_z[1:0], rx_d_i};
            rxdv_z <= {rxdv_z[1:0], rx_dv_i};
        end
    end

    localparam int HEADER_BITS = HEADER_BYTES * 8;
    localparam int PREAMBLE_SFD_BITS = (PREAMBLE_BYTES + SFD_BYTES) * 8;
    localparam int FCS_BITS = FCS_BYTES * 8;

    localparam int HEADER_LENGTH = HEADER_BYTES * 8 / GMII_WIDTH;
    localparam int SFD_LENGTH = SFD_BYTES * 8 / GMII_WIDTH;
    localparam int PREAMBLE_LENGTH = PREAMBLE_BYTES * 8 / GMII_WIDTH;
    localparam int FCS_LENGTH = FCS_BYTES * 8 / GMII_WIDTH;

    ethernet_header_t                         header_buffer;
    logic             [  AXIS_DATA_WIDTH-1:0] data_buffer;
    logic             [PREAMBLE_SFD_BITS-1:0] preamble_sfd;
    logic             [PREAMBLE_SFD_BITS-1:0] preamble_sfd_buffer;
    logic             [         FCS_BITS-1:0] fcs;
    logic             [         FCS_BITS-1:0] fcs_buffer;
    logic             [         FCS_BITS-1:0] calculated_fcs;

    typedef enum {
        IDLE,
        PREAMBLE_SFD,
        HEADER,
        DATA,
        FCS,
        CRC_CHECK
    } state_type_t;

    state_type_t current_state, next_state;

    logic [31:0] state_counter;

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

    assign preamble_sfd = {<<8{preamble_sfd_buffer}};

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (packet_start) begin
                    next_state = PREAMBLE_SFD;
                end
            end
            PREAMBLE_SFD: begin
                if (state_counter == PREAMBLE_LENGTH + SFD_LENGTH - 1) begin
                    next_state = HEADER;
                end
            end
            HEADER: begin
                if (state_counter == HEADER_LENGTH - 1) begin
                    next_state = DATA;
                end
                if (packet_done | (preamble_sfd != {PREAMBULE_VAL, SFD_VAL})) begin
                    next_state = IDLE;
                end
            end
            DATA: begin
                if (state_counter == payload_bytes_i - 1) begin
                    next_state = FCS;
                end
            end
            FCS: begin
                if (state_counter == FCS_LENGTH - 1) begin
                    next_state = CRC_CHECK;
                end
            end
            CRC_CHECK: begin
                next_state = IDLE;
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
    logic fcs_en;
    logic fcs_rst;

    assign fcs_en  = (current_state == HEADER) || (current_state == DATA);
    assign fcs_rst = (current_state == IDLE);

    crc #(
        .DATA_WIDTH(GMII_WIDTH),
        .CRC_WIDTH (FCS_BYTES * 8),
        .LSB_FIRST (1),
        .INVERT_OUT(1),
        .LEFT_SHIFT(0)
    ) i_crc (
        .clk_i (clk_i),
        .rst_i (rst_i || fcs_rst),
        .data_i(rxd_z[2]),
        .en_i  (fcs_en),
        .crc_o (fcs)
    );

    logic [47:0] packet_destination;
    assign packet_destination = {<<8{header_buffer.mac_destination}};

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            preamble_sfd_buffer <= 0;
            header_buffer       <= 0;
            fcs_buffer          <= 0;
            data_buffer         <= 0;
            data_valid          <= 0;
            data_last           <= 0;
            crc_err_o           <= 0;
        end else begin
            data_valid <= 0;
            data_last  <= 0;
            if (current_state == PREAMBLE_SFD) begin
                preamble_sfd_buffer[PREAMBLE_SFD_BITS-1-:GMII_WIDTH] <= rxd_z[2];
                preamble_sfd_buffer[PREAMBLE_SFD_BITS-GMII_WIDTH-1:0] <= preamble_sfd_buffer[PREAMBLE_SFD_BITS-1:GMII_WIDTH];
            end
            if (current_state == HEADER) begin
                header_buffer[HEADER_BITS-1-:GMII_WIDTH] <= rxd_z[2];
                header_buffer[HEADER_BITS-GMII_WIDTH-1:0] <= header_buffer[HEADER_BITS-1:GMII_WIDTH];
            end
            if (current_state == DATA) begin
                data_buffer <= rxd_z[2];
                data_valid  <= ~check_destination_i || (packet_destination == host_mac_i);
                data_last   <= (next_state == FCS);
            end
            if (current_state == FCS) begin
                fcs_buffer[FCS_BITS-1-:GMII_WIDTH]  <= rxd_z[2];
                fcs_buffer[FCS_BITS-GMII_WIDTH-1:0] <= fcs_buffer[FCS_BITS-1:GMII_WIDTH];
            end
            if ((current_state == DATA) && (next_state == FCS)) begin
                calculated_fcs <= fcs;
            end
            if (current_state == CRC_CHECK) begin
                crc_err_o <= (calculated_fcs != fcs_buffer);
            end
        end
    end

    localparam int FIFO_DEPTH = 2 ** PAYLOAD_WIDTH;

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) s_axis (
        .clk_i(clk_i),
        .rst_i(rst_i)
    );

    assign s_axis.tvalid = data_valid;
    assign s_axis.tdata  = data_buffer;
    assign s_axis.tlast  = data_last;

    axis_fifo #(
        .FIFO_DEPTH  (FIFO_DEPTH),
        .FIFO_WIDTH  (AXIS_DATA_WIDTH),
        .TLAST_EN    (1),
        .FIFO_MODE   ("sync"),
        .READ_LATENCY(1),
        .RAM_STYLE   ("distributed")
    ) i_axis_fifo_rx (
        .s_axis    (s_axis),
        .m_axis    (m_axis),
        .data_cnt_o(),
        .a_full_o  (),
        .a_empty_o ()
    );

endmodule
