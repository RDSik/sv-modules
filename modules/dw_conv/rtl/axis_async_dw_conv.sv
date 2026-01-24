/* verilator lint_off TIMESCALEMOD */
module axis_async_dw_conv #(
    parameter int   DATA_WIDTH_IN  = 32,
    parameter int   DATA_WIDTH_OUT = 128,
    parameter int   FIFO_DEPTH     = 128,
    parameter int   CDC_REG_NUM    = 128,
    parameter logic TLAST_EN       = 0,
    parameter logic FIFO_FIRST     = 1
) (
    axis_if.master m_axis,
    axis_if.slave  s_axis,

    output logic a_full_o,
    output logic a_empty_o
);

    localparam int READ_LATENCY = 0;
    localparam FIFO_MODE = "async";
    localparam RAM_STYLE = "distributed";

    logic s_clk;
    logic m_clk;

    assign s_clk = s_axis.clk_i;
    assign m_clk = m_axis.clk_i;

    logic s_rst;
    logic m_rst;

    assign s_rst = s_axis.rst_i;
    assign m_rst = m_axis.rst_i;

    if (FIFO_FIRST) begin : g_fast_to_slow
        axis_if #(
            .DATA_WIDTH(DATA_WIDTH_IN)
        ) axis (
            .clk_i(m_clk),
            .rst_i(m_rst)
        );

        axis_fifo #(
            .FIFO_DEPTH  (FIFO_DEPTH),
            .FIFO_WIDTH  (DATA_WIDTH_IN),
            .FIFO_MODE   (FIFO_MODE),
            .READ_LATENCY(READ_LATENCY),
            .RAM_STYLE   (RAM_STYLE),
            .CDC_REG_NUM (CDC_REG_NUM),
            .TLAST_EN    (TLAST_EN)
        ) i_axis_fifo (
            .s_axis   (s_axis),
            .m_axis   (axis),
            .a_full_o (a_full_o),
            .a_empty_o(a_empty_o)
        );

        axis_dw_conv #(
            .DATA_WIDTH_IN (DATA_WIDTH_IN),
            .DATA_WIDTH_OUT(DATA_WIDTH_OUT),
            .TLAST_EN      (TLAST_EN)
        ) i_axis_dw_conv (
            .m_axis(m_axis),
            .s_axis(axis)
        );
    end else begin : g_slow_to_fast
        axis_if #(
            .DATA_WIDTH(DATA_WIDTH_OUT)
        ) axis (
            .clk_i(s_clk),
            .rst_i(s_rst)
        );

        axis_dw_conv #(
            .DATA_WIDTH_IN (DATA_WIDTH_IN),
            .DATA_WIDTH_OUT(DATA_WIDTH_OUT),
            .TLAST_EN      (TLAST_EN)
        ) i_axis_dw_conv (
            .m_axis(axis),
            .s_axis(s_axis)
        );

        axis_fifo #(
            .FIFO_DEPTH  (FIFO_DEPTH),
            .FIFO_WIDTH  (DATA_WIDTH_OUT),
            .FIFO_MODE   (FIFO_MODE),
            .READ_LATENCY(READ_LATENCY),
            .RAM_STYLE   (RAM_STYLE),
            .CDC_REG_NUM (CDC_REG_NUM),
            .TLAST_EN    (TLAST_EN)
        ) i_axis_fifo (
            .s_axis   (axis),
            .m_axis   (m_axis),
            .a_full_o (a_full_o),
            .a_empty_o(a_empty_o)
        );
    end

endmodule
