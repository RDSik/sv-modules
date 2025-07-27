/* verilator lint_off TIMESCALEMOD */
module axis_data_gen #(
    parameter int DATA_WIDTH = 16
) (
    input logic                  en_i,
    input logic [DATA_WIDTH-1:0] poly_i,
    input logic [DATA_WIDTH-1:0] seed_i,

    axis_if.master m_axis
);

    localparam int PERIOD = 2 ** DATA_WIDTH;

    logic                  clk_i;
    logic                  rstn_i;
    logic [DATA_WIDTH-1:0] cnt;
    logic [DATA_WIDTH-1:0] lfsr;
    logic                  cnt_done;
    logic                  m_handshake;

    assign clk_i  = m_axis.clk_i;
    assign rstn_i = m_axis.rstn_i;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            cnt <= '0;
        end else if (en_i) begin
            if (cnt_done) begin
                cnt <= '0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    assign cnt_done = (cnt == PERIOD - 1);

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_axis.tvalid <= 1'b0;
            m_axis.tlast  <= 1'b0;
        end else if (m_handshake) begin
            m_axis.tvalid <= 1'b0;
            m_axis.tlast  <= 1'b0;
        end else if (en_i) begin
            m_axis.tvalid <= 1'b1;
            if (cnt_done) begin
                m_axis.tlast <= 1'b1;
            end
        end
    end

    lfsr #(
        .DATA_WIDTH(DATA_WIDTH)
    ) i_lfsr (
        .clk_i (clk_i),
        .rstn_i(rstn_i),
        .en_i  (en_i),
        .seed_i(seed_i),
        .poly_i(poly_i),
        .data_o(lfsr),
    );

    assign m_axis.tdata = lfsr;
    assign m_handshake  = m_axis.tvalid & m_axis.tready;

endmodule
