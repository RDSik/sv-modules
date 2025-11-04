// -------------------------------------------------------------------------
// Parameter: SPI_MODE can be 0, 1, 2, or 3.
//            Can be configured in one of 4 modes:
//            Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//            0   |             0             |        0
//            1   |             0             |        1
//            2   |             1             |        0
//            3   |             1             |        1
// -------------------------------------------------------------------------

/* verilator lint_off TIMESCALEMOD */
module axis_spi_master #(
    parameter int DATA_WIDTH    = 8,
    parameter int DIVIDER_WIDTH = 32,
    parameter int WAIT_WIDTH    = 32,
    parameter int SLAVE_NUM     = 1
) (
    /* verilator lint_off ASCRANGE */
    input logic [$clog2(SLAVE_NUM)-1:0] addr_i,
    /* verilator lint_on ASCRANGE */
    input logic [       WAIT_WIDTH-1:0] wait_time_i,
    input logic [    DIVIDER_WIDTH-1:0] clk_divider_i,
    input logic                         cpha_i,
    input logic                         cpol_i,

    spi_if.master m_spi,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        DATA = 2'b01,
        WAIT = 2'b10
    } state_e;

    state_e state;

    logic   clk_i;
    logic   rstn_i;

    assign clk_i  = s_axis.clk_i;
    assign rstn_i = s_axis.rstn_i;

    logic m_handshake;
    logic s_handshake;

    logic pos_edge;
    logic neg_edge;
    logic edge_done;
    logic edge_done_d;

    spi_clk_gen #(
        .DIVIDER_WIDTH(DIVIDER_WIDTH)
    ) i_spi_clk_gen (
        .clk_i        (clk_i),
        .rstn_i       (rstn_i),
        .enable_i     (s_handshake || (state == WAIT)),
        .cpol_i       (cpol_i),
        .clk_divider_i(clk_divider_i),
        .edge_done_o  (edge_done),
        .neg_edge_o   (neg_edge),
        .pos_edge_o   (pos_edge),
        .clk_o        (m_spi.clk)
    );

    always_ff @(posedge clk_i) begin
        edge_done_d <= edge_done;
    end

    logic [DATA_WIDTH-1:0] rx_data;

    spi_shift #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_spi_shift (
        .clk_i     (clk_i),
        .rstn_i    (rstn_i),
        .enable_i  (s_handshake),
        .cpha_i    (cpha_i),
        .pos_edge_i(pos_edge),
        .neg_edge_i(neg_edge),
        .data_i    (s_axis.tdata),
        .data_o    (rx_data),
        .miso_i    (m_spi.miso),
        .mosi_o    (m_spi.mosi)
    );

    logic spi_cs_reg;

    if (SLAVE_NUM == 1) begin : g_one_slave
        assign m_spi.cs = spi_cs_reg;
    end else begin : g_many_slaves
        always_comb begin
            for (int i = 0; i < SLAVE_NUM; i++) begin
                if (i == addr_i) begin
                    m_spi.cs[i] = spi_cs_reg;
                end else begin
                    m_spi.cs[i] = 1'b1;
                end
            end
        end
    end

    logic [WAIT_WIDTH-1:0] wait_cnt;
    logic                  wait_done;

    logic                  tlast_flag;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            state      <= IDLE;
            spi_cs_reg <= '1;
            tlast_flag <= '0;
            wait_cnt   <= '0;
        end else begin
            case (state)
                IDLE: begin
                    if (s_handshake) begin
                        state      <= DATA;
                        spi_cs_reg <= 1'b0;
                        tlast_flag <= s_axis.tlast;
                    end
                end
                DATA: begin
                    if (edge_done) begin
                        if (tlast_flag) begin
                            state      <= WAIT;
                            spi_cs_reg <= 1'b1;
                            tlast_flag <= 1'b0;
                        end else begin
                            state <= IDLE;
                        end
                    end
                end
                WAIT: begin
                    if (wait_done) begin
                        wait_cnt <= '0;
                        state    <= IDLE;
                    end else begin
                        wait_cnt <= wait_cnt + 1'b1;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    assign wait_done = (wait_cnt == wait_time_i - 1);

    assign s_axis.tready = (state == IDLE) && rstn_i;
    assign s_handshake = s_axis.tvalid & s_axis.tready;

    // Master AXI-Stream data--------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_axis.tvalid <= 1'b0;
            m_axis.tlast  <= 1'b0;
        end else if (m_handshake) begin
            m_axis.tvalid <= 1'b0;
            m_axis.tlast  <= 1'b0;
        end else if (edge_done_d) begin
            if (state == WAIT) begin
                m_axis.tlast <= 1'b1;
            end
            m_axis.tvalid <= 1'b1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (edge_done_d) begin
            m_axis.tdata <= rx_data;
        end
    end

    assign m_handshake = m_axis.tvalid & m_axis.tready;
    // ------------------------------------------------------------

endmodule
