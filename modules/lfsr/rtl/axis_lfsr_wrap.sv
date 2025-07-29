/* verilator lint_off TIMESCALEMOD */
module axis_lfsr_wrap #(
    parameter logic CRC_MODE_EN = 0,
    parameter int   DATA_WIDTH  = 16,
    parameter int   CRC_WIDTH   = 16
) (
    input logic                  en_i,
    input logic [DATA_WIDTH-1:0] seed_i,
    input logic [DATA_WIDTH-1:0] poly_i,

    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    logic clk_i;
    logic rstn_i;

    assign clk_i         = m_axis.clk_i;
    assign rstn_i        = m_axis.rstn_i;
    assign s_axis.tready = s_axis.rstn_i;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_axis.tvalid <= 1'b0;
        end else if (en_i) begin
            m_axis.tvalid <= s_axis.tvalid;
        end
    end

    if (CRC_MODE_EN) begin : g_crc
        crc #(
            .DATA_WIDTH(DATA_WIDTH),
            .CRC_WIDTH (CRC_WIDTH)
        ) i_crc (
            .clk_i (clk_i),
            .rstn_i(rstn_i),
            .en_i  (en_i),
            .data_i(s_axis.tdata),
            .crc_o (m_axis.tdata)
        );
    end else begin : g_lfsr
        lfsr #(
            .DATA_WIDTH(DATA_WIDTH)
        ) i_lfsr (
            .clk_i (clk_i),
            .rstn_i(rstn_i),
            .en_i  (en_i),
            .poly_i(poly_i),
            .seed_i(seed_i),
            .data_o(m_axis.tdata)
        );
    end

endmodule
