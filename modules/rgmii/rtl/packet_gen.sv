`include "rgmii_pkg.svh"

module packet_gen
    import rgmii_pkg::*;
#(
    parameter int GMII_WIDTH      = 8,
    parameter int PAYLOAD_WIDTH   = 11,
    parameter int AXIS_DATA_WIDTH = 8
) (
    output logic                  tx_en_o,
    output logic [GMII_WIDTH-1:0] tx_d_o,

    input logic [PAYLOAD_WIDTH-1:0] payload_bytes_i,

    input logic [15:0] fpga_port_i,
    input logic [31:0] fpga_ip_i,
    input logic [47:0] fpga_mac_i,

    input logic [15:0] host_port_i,
    input logic [31:0] host_ip_i,
    input logic [47:0] host_mac_i,

    axis_if.slave s_axis
);

    localparam int WAIT_BYTES = 12;
    localparam int SFD_BYTES = 1;
    localparam int PREAMBLE_BYTES = 7;
    localparam int FCS_BYTES = 4;

    localparam int HEADER_BYTES = $bits(ethernet_header_t) / 8;
    localparam int HEADER_LENGTH = HEADER_BYTES * 8 / GMII_WIDTH;
    localparam int WAIT_LENGTH = WAIT_BYTES * 8 / GMII_WIDTH;
    localparam int SFD_LENGTH = SFD_BYTES * 8 / GMII_WIDTH;
    localparam int PREAMBLE_LENGTH = PREAMBLE_BYTES * 8 / GMII_WIDTH;
    localparam int FCS_LENGTH = FCS_BYTES * 8 / GMII_WIDTH;
    // localparam int WORD_BYTES = 1;
    // localparam int DATA_COUNTER_BITS = $clog2(WORD_BYTES * 8 / GMII_WIDTH);

    logic clk_i;
    logic rst_i;
    logic s_handshake;

    assign clk_i       = s_axis.clk_i;
    assign rst_i       = s_axis.rst_i;
    assign s_handshake = s_axis.tvalid && s_axis.tready;

    logic s_axis_tfirst_i;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            s_axis_tfirst_i <= 1;
        end else begin
            if (s_handshake) begin
                if (s_axis.tlast) begin
                    s_axis_tfirst_i <= 1;
                end else begin
                    s_axis_tfirst_i <= 0;
                end
            end
        end
    end

    ethernet_header_t                                  header;
    logic             [$bits(ethernet_header_t)-1 : 0] header_buffer;
    logic             [           AXIS_DATA_WIDTH-1:0] data_buffer;
    logic             [          PREAMBLE_BYTES*8-1:0] preamble_buffer;
    logic             [               SFD_BYTES*8-1:0] sfd_buffer;
    logic             [               FCS_BYTES*8-1:0] fcs;
    logic             [               FCS_BYTES*8-1:0] fcs_buffer;

    logic             [                          31:0] data_length;
    assign data_length = payload_bytes_i * 8 / GMII_WIDTH;

    typedef enum {
        IDLE,
        PREAMBLE,
        SFD,
        HEADER,
        DATA,
        FCS,
        WAIT
    } state_type_t;

    state_type_t                        current_state = IDLE;
    state_type_t                        next_state = IDLE;

    localparam int FIFO_DEPTH = 2**PAYLOAD_WIDTH;

    logic                               fifo_full;
    logic                               fifo_empty;
    logic        [$clog2(FIFO_DEPTH):0] fifo_count;
    logic        [ AXIS_DATA_WIDTH-1:0] fifo_out;
    logic                               fifo_rd_en;
    logic                               fifo_wr_en;
    logic                               packet_start_valid;
    logic                               packet_valid;
    logic                               fifo_has_space;

    assign fifo_has_space = (fifo_count < FIFO_DEPTH - payload_bytes_i);

    assign packet_start_valid = s_handshake && s_axis_tfirst_i && fifo_has_space;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            packet_valid <= 0;
        end else begin
            if (packet_start_valid) begin
                packet_valid <= 1;
            end
            if (packet_valid && s_handshake && s_axis.tlast) begin
                packet_valid <= 0;
            end
        end
    end

    assign fifo_wr_en = s_handshake & (packet_start_valid || packet_valid);

    assign s_axis.tready = (fifo_has_space & s_axis_tfirst_i) | packet_valid;

    eth_header_gen #(
        .PAYLOAD_WIDTH(PAYLOAD_WIDTH)
    ) eth_header_gen (
        .fpga_port_i    (fpga_port_i),
        .fpga_ip_i      (fpga_ip_i),
        .fpga_mac_i     (fpga_mac_i),
        .host_port_i    (host_port_i),
        .host_ip_i      (host_ip_i),
        .host_mac_i     (host_mac_i),
        .payload_bytes_i(payload_bytes_i),
        .output_header_o(header)
    );

    fifo_wrap #(
        .FIFO_WIDTH  (AXIS_DATA_WIDTH),
        .FIFO_DEPTH  (FIFO_DEPTH),
        .FIFO_MODE   ("sync"),
        .READ_LATENCY(0),
        .RAM_STYLE   ("distributed")
    ) i_fifo_wrap (
        .wr_clk_i  (clk_i),
        .wr_rst_i  (rst_i),
        .wr_data_i (s_axis.tdata),
        .rd_clk_i  (clk_i),
        .rd_rst_i  (rst_i),
        .push_i    (fifo_wr_en),
        .pop_i     (fifo_rd_en),
        .rd_data_o (fifo_out),
        .full_o    (fifo_full),
        .empty_o   (fifo_empty),
        .data_cnt_o(fifo_count),
        .a_empty_o (),
        .a_full_o  ()
    );

    logic [31:0] state_counter;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state_counter <= '0;
        end else begin
            if (current_state != next_state) begin
                state_counter <= '0;
            end else begin
                state_counter <= state_counter + 'd1;
            end
        end
    end

    always_comb begin
        case (current_state)
            IDLE: begin
                if (fifo_count >= payload_bytes_i) begin
                    next_state = PREAMBLE;
                end else begin
                    next_state = current_state;
                end
            end
            PREAMBLE: begin
                if (state_counter == PREAMBLE_LENGTH - 1) begin
                    next_state = SFD;
                end else begin
                    next_state = current_state;
                end
            end
            SFD: begin
                if (state_counter == SFD_LENGTH - 1) begin
                    next_state = HEADER;
                end else begin
                    next_state = current_state;
                end
            end
            HEADER: begin
                if (state_counter == HEADER_LENGTH - 1) begin
                    next_state = DATA;
                end else begin
                    next_state = current_state;
                end
            end
            DATA: begin
                if (state_counter == data_length - 1) begin
                    next_state = FCS;
                end else begin
                    next_state = current_state;
                end
            end
            FCS: begin
                if (state_counter == FCS_LENGTH - 1) begin
                    next_state = WAIT;
                end else begin
                    next_state = current_state;
                end
            end
            WAIT: begin
                if (state_counter == WAIT_LENGTH - 1) begin
                    next_state = IDLE;
                end else begin
                    next_state = current_state;

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

    logic [GMII_WIDTH-1:0] tx_data;
    logic                  tx_valid;
    logic                  fcs_en;
    logic                  fcs_rst_i;

    always_comb begin
        case (current_state)
            IDLE: begin
                tx_valid  = 0;
                tx_data   = 0;
                fcs_en    = 0;
                fcs_rst_i = 1;
            end
            PREAMBLE: begin
                tx_valid  = 1;
                tx_data   = preamble_buffer[GMII_WIDTH-1:0];
                fcs_en    = 0;
                fcs_rst_i = 0;
            end
            SFD: begin
                tx_valid  = 1;
                tx_data   = sfd_buffer[GMII_WIDTH-1:0];
                fcs_en    = 0;
                fcs_rst_i = 0;
            end
            HEADER: begin
                tx_valid  = 1;
                tx_data   = header_buffer[GMII_WIDTH-1:0];
                fcs_en    = 1;
                fcs_rst_i = 0;
            end
            DATA: begin
                tx_valid  = 1;
                tx_data   = data_buffer[GMII_WIDTH-1:0];
                fcs_en    = 1;
                fcs_rst_i = 0;
            end
            FCS: begin
                tx_valid  = 1;
                tx_data   = fcs_buffer[GMII_WIDTH-1:0];
                fcs_en    = 0;
                fcs_rst_i = 0;
            end
            WAIT: begin
                tx_valid  = 0;
                tx_data   = 0;
                fcs_en    = 0;
                fcs_rst_i = 0;
            end
            default: begin
                tx_valid  = 0;
                tx_data   = 0;
                fcs_en    = 0;
                fcs_rst_i = 0;
            end
        endcase
    end

    // logic [DATA_COUNTER_BITS-1:0] data_ones;
    // assign data_ones = '1;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            header_buffer   <= 0;
            preamble_buffer <= 0;
            fifo_rd_en      <= 0;
        end else begin
            fifo_rd_en <= 0;
            if (current_state == IDLE) begin
                header_buffer   <= header;
                preamble_buffer <= 56'h55555555555555;
                sfd_buffer      <= 8'hd5;
            end
            if (next_state == FCS && current_state != FCS) begin
                fcs_buffer <= fcs;
            end
            if (next_state == DATA && current_state != DATA) begin
                data_buffer <= fifo_out;
            end
            if (current_state == HEADER) begin
                header_buffer <= header_buffer >> GMII_WIDTH;
            end
            if (current_state == PREAMBLE) begin
                preamble_buffer <= preamble_buffer >> GMII_WIDTH;
            end
            if (current_state == SFD) begin
                sfd_buffer <= sfd_buffer >> GMII_WIDTH;
            end
            if (current_state == DATA && next_state == DATA) begin
                // if (state_counter[DATA_COUNTER_BITS-1:0] == data_ones) begin
                data_buffer <= fifo_out;
                fifo_rd_en  <= 1;
                // end else begin
                // data_buffer <= data_buffer >> GMII_WIDTH;
                // end
            end
            if (current_state == FCS) begin
                fcs_buffer <= fcs_buffer >> GMII_WIDTH;
            end
        end
    end

    crc #(
        .DATA_WIDTH(GMII_WIDTH),
        .CRC_WIDTH (32),
        .LSB_FIRST (1),
        .INVERT_OUT(1),
        .LEFT_SHIFT(0)
    ) i_crc (
        .clk_i (clk_i),
        .rst_i (rst_i || fcs_rst_i),
        .data_i(tx_data),
        .en_i  (fcs_en),
        .crc_o (fcs)
    );

    always @(posedge clk_i) begin
        if (rst_i) begin
            tx_en_o <= 0;
        end else begin
            tx_en_o <= tx_valid;
        end
        tx_d_o <= tx_data;
    end

endmodule
