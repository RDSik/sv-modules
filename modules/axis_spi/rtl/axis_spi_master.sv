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
    parameter int SLAVE_NUM     = 1,
    parameter int ADDR_WIDTH    = $clog2(SLAVE_NUM)
) (
    input logic [   ADDR_WIDTH-1:0] addr_i,
    input logic [   WAIT_WIDTH-1:0] wait_time_i,
    input logic [DIVIDER_WIDTH-1:0] clk_divider_i,
    input logic                     cpha_i,
    input logic                     cpol_i,

    spi_if.master  m_spi,
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    localparam int EDGE_NUM = DATA_WIDTH * 2;  // need 16 edges to transmit 8 bits
    localparam int DATA_CNT_WIDTH = $clog2(DATA_WIDTH);

    logic [    WAIT_WIDTH-1:0] wait_cnt;
    logic                      wait_done;

    logic [ DIVIDER_WIDTH-1:0] clk_cnt;
    logic                      clk_done;
    logic                      half_clk_done;

    logic [$clog2(EDGE_NUM):0] edge_cnt;
    logic                      edge_done;
    logic                      edge_done_d;

    logic                      spi_clk_reg;
    logic                      spi_cs_reg;
    logic                      tlast_flag;

    logic [    DATA_WIDTH-1:0] tx_data;
    logic [DATA_CNT_WIDTH-1:0] tx_bit_cnt;

    logic [    DATA_WIDTH-1:0] rx_data;
    logic [DATA_CNT_WIDTH-1:0] rx_bit_cnt;
    logic                      rx_bit_done;

    logic                      leading_edge;
    logic                      trailing_edge;

    logic                      m_handshake;
    logic                      s_handshake;
    logic                      s_handshake_d;

    logic                      clk_i;
    logic                      rstn_i;

    assign clk_i  = s_axis.clk_i;
    assign rstn_i = s_axis.rstn_i;

    typedef enum logic [1:0] {
        IDLE = 2'b00,
        DATA = 2'b01,
        WAIT = 2'b10
    } state_e;

    state_e state;

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

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            state      <= IDLE;
            spi_cs_reg <= 1'b1;
            tlast_flag <= 1'b0;
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
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    // WAIT TIME counter-------------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            wait_cnt <= '0;
        end else if (wait_done) begin
            wait_cnt <= '0;
        end else if (state == WAIT) begin
            wait_cnt <= wait_cnt + 1'b1;
        end
    end

    assign wait_done = (wait_cnt == wait_time_i - 1);
    // ------------------------------------------------------------

    // SPI clock counters------------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            clk_cnt <= '0;
        end else if (clk_done) begin
            clk_cnt <= '0;
        end else if (~edge_done) begin
            clk_cnt <= clk_cnt + 1'b1;
        end
    end

    /* verilator lint_off WIDTHEXPAND */
    assign clk_done      = (clk_cnt == clk_divider_i - 1);
    assign half_clk_done = (clk_cnt == (clk_divider_i / 2) - 1);
    /* verilator lint_on WIDTHEXPAND */

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            trailing_edge <= 1'b0;
            leading_edge  <= 1'b0;
            edge_cnt      <= '0;
            spi_clk_reg   <= cpol_i;
        end else begin
            trailing_edge <= 1'b0;
            leading_edge  <= 1'b0;
            if (s_handshake) begin
                edge_cnt <= EDGE_NUM;
            end else if (~edge_done) begin
                if (clk_done) begin
                    trailing_edge <= 1'b1;
                    edge_cnt      <= edge_cnt - 1'b1;
                    spi_clk_reg   <= ~spi_clk_reg;
                end else if (half_clk_done) begin
                    leading_edge <= 1'b1;
                    edge_cnt     <= edge_cnt - 1'b1;
                    spi_clk_reg  <= ~spi_clk_reg;
                end
            end
        end
    end

    assign edge_done = ~(|edge_cnt);

    always_ff @(posedge clk_i) begin
        edge_done_d <= (state == WAIT) ? 1'b0 : edge_done;
    end
    // ------------------------------------------------------------

    // SPI clock---------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_spi.clk <= cpol_i;
        end else begin
            m_spi.clk <= spi_clk_reg;
        end
    end
    // ------------------------------------------------------------

    // MISO data---------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            rx_bit_cnt <= '0;
            rx_data    <= '0;
        end else if (rx_bit_done) begin
            rx_bit_cnt <= '0;
        end else if ((leading_edge & ~cpha_i) || (trailing_edge & cpha_i)) begin
            rx_bit_cnt <= rx_bit_cnt + 1'b1;
            rx_data    <= {rx_data[DATA_WIDTH-2:0], m_spi.miso};
        end
    end

    /* verilator lint_off WIDTHEXPAND */
    assign rx_bit_done = (rx_bit_cnt == DATA_WIDTH - 1);
    /* verilator lint_on WIDTHEXPAND */
    // ------------------------------------------------------------

    // MOSI data---------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            /* verilator lint_off WIDTHTRUNC */
            tx_bit_cnt <= DATA_WIDTH - 1;
            /* verilator lint_on WIDTHTRUNC */
            m_spi.mosi <= '0;
        end else if (s_handshake) begin
            /* verilator lint_off WIDTHTRUNC */
            tx_bit_cnt <= DATA_WIDTH - 1;
            /* verilator lint_on WIDTHTRUNC */
        end else if (s_handshake_d & ~cpha_i) begin // Catch the case where we start transaction and CPHA = 0
            /* verilator lint_off WIDTHTRUNC */
            tx_bit_cnt <= DATA_WIDTH - 2;
            /* verilator lint_on WIDTHTRUNC */
            m_spi.mosi <= tx_data[DATA_WIDTH-1];
        end else if ((leading_edge & cpha_i) || (trailing_edge & ~cpha_i)) begin
            tx_bit_cnt <= tx_bit_cnt - 1'b1;
            m_spi.mosi <= tx_data[tx_bit_cnt];
        end
    end
    // ------------------------------------------------------------

    // Slave AXI-Stream data---------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            tx_data <= '0;
        end else if (s_handshake) begin
            tx_data <= s_axis.tdata;
        end
    end

    assign s_axis.tready = (state == IDLE);
    assign s_handshake   = s_axis.tvalid & s_axis.tready;

    always_ff @(posedge clk_i) begin
        s_handshake_d <= s_handshake;
    end
    // ------------------------------------------------------------

    // Master AXI-Stream data--------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_axis.tlast  <= '0;
            m_axis.tvalid <= '0;
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
