/* verilator lint_off TIMESCALEMOD */
module axis_dw_conv #(
    parameter int DATA_WIDTH_IN  = 32,
    parameter int DATA_WIDTH_OUT = 128
) (
    axis_if.master m_axis,
    axis_if.slave  s_axis
);

    logic clk_i;
    logic rst_i;
    logic s_handshake;
    logic m_handshake;

    assign clk_i       = s_axis.clk_i;
    assign rst_i       = s_axis.rst_i;
    assign s_handshake = s_axis.tvalid & s_axis.tready;
    assign m_handshake = m_axis.tvalid & m_axis.tready;

    if (DATA_WIDTH_IN > DATA_WIDTH_OUT) begin : g_down_size
        localparam int RATIO = DATA_WIDTH_IN / DATA_WIDTH_OUT;

        logic [$clog2(RATIO)-1:0]                     cnt;
        logic                                         cnt_done;
        logic                                         busy;
        logic [        RATIO-1:0][DATA_WIDTH_OUT-1:0] m_axis_tdata;

        /* verilator lint_off WIDTHEXPAND */
        assign cnt_done = (cnt == RATIO - 1);
        /* verilator lint_on WIDTHEXPAND */

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                cnt <= '0;
            end else if (m_handshake) begin
                if (cnt_done) begin
                    cnt <= '0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                busy <= 1'b0;
            end else begin
                if (s_handshake) begin
                    busy <= 1'b1;
                end else if (m_handshake & cnt_done) begin
                    busy <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                m_axis_tdata <= '0;
            end else if (s_handshake) begin
                m_axis_tdata <= s_axis.tdata;
            end
        end

        assign m_axis.tdata  = m_axis_tdata[cnt];
        assign m_axis.tvalid = busy;
        assign s_axis.tready = ~busy;

    end else if (DATA_WIDTH_IN < DATA_WIDTH_OUT) begin : g_up_size

        localparam int RATIO = DATA_WIDTH_OUT / DATA_WIDTH_IN;

        logic [$clog2(RATIO)-1:0]                    cnt;
        logic                                        cnt_done;
        logic                                        m_axis_tvalid;
        logic [        RATIO-1:0][DATA_WIDTH_IN-1:0] m_axis_tdata;

        /* verilator lint_off WIDTHEXPAND */
        assign cnt_done = (cnt == RATIO - 1);
        /* verilator lint_on WIDTHEXPAND */

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                cnt <= '0;
            end else if (s_handshake) begin
                if (cnt_done) begin
                    cnt <= '0;
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                m_axis_tvalid <= 1'b0;
            end else if (cnt_done & s_handshake) begin
                m_axis_tvalid <= 1'b1;
            end else if (m_handshake) begin
                m_axis_tvalid <= 1'b0;
            end
        end

        always_ff @(posedge clk_i) begin
            if (s_handshake) begin
                m_axis_tdata[cnt] <= s_axis.tdata;
            end
        end

        assign m_axis.tdata  = m_axis_tdata;
        assign m_axis.tvalid = m_axis_tvalid;
        assign s_axis.tready = m_axis.tready;

    end else begin : g_bypass
        assign m_axis.tvalid = s_axis.tvalid;
        assign m_axis.tdata  = s_axis.tdata;
        assign s_axis.tready = m_axis.tready;
    end

endmodule
