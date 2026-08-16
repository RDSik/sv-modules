/* verilator lint_off TIMESCALEMOD */
module axis_dw_conv_wrap #(
    parameter int   FIFO_DEPTH    = 128,
    parameter int   CDC_REG_NUM   = 3,
    parameter logic TLAST_EN      = 0,
    parameter logic FIFO_FIRST    = 1,
    parameter logic ASYNC_MODE_EN = 0

) (
    input logic s_clk_i,
    input logic s_rst_i,
    input logic m_clk_i,
    input logic m_rst_i,

    axis_if.master m_axis,
    axis_if.slave  s_axis
);

    localparam int S_DATA_WIDTH = s_axis.DATA_WIDTH;
    localparam int M_DATA_WIDTH = m_axis.DATA_WIDTH;

    if (ASYNC_MODE_EN) begin : g_async
        if (FIFO_FIRST) begin : g_fast_to_slow
            axis_if #(
                .DATA_WIDTH(S_DATA_WIDTH)
            ) axis (
                .clk_i  (m_clk_i),
                .arstn_i(~m_rst_i)
            );

            axis_fifo #(
                .FIFO_DEPTH   (FIFO_DEPTH),
                .FIFO_WIDTH   (S_DATA_WIDTH),
                .CDC_REG_NUM  (CDC_REG_NUM),
                .TLAST_EN     (TLAST_EN),
                .ASYNC_MODE_EN(ASYNC_MODE_EN)
            ) i_axis_fifo (
                .s_clk_i  (s_clk_i),
                .s_rst_i  (s_rst_i),
                .m_clk_i  (m_clk_i),
                .m_rst_i  (m_rst_i),
                .s_axis   (s_axis),
                .m_axis   (axis),
                .a_full_o (),
                .a_empty_o()
            );

            axis_dw_conv #(
                .TLAST_EN(TLAST_EN)
            ) i_axis_dw_conv (
                .clk_i (m_clk_i),
                .rst_i (m_rst_i),
                .m_axis(m_axis),
                .s_axis(axis)
            );
        end else begin : g_slow_to_fast
            axis_if #(
                .DATA_WIDTH(M_DATA_WIDTH)
            ) axis (
                .clk_i  (s_clk_i),
                .arstn_i(~s_rst_i)
            );

            axis_dw_conv #(
                .TLAST_EN(TLAST_EN)
            ) i_axis_dw_conv (
                .clk_i (s_clk_i),
                .rst_i (s_rst_i),
                .m_axis(axis),
                .s_axis(s_axis)
            );

            axis_fifo #(
                .FIFO_DEPTH   (FIFO_DEPTH),
                .FIFO_WIDTH   (M_DATA_WIDTH),
                .CDC_REG_NUM  (CDC_REG_NUM),
                .TLAST_EN     (TLAST_EN),
                .ASYNC_MODE_EN(ASYNC_MODE_EN)
            ) i_axis_fifo (
                .s_clk_i  (s_clk_i),
                .s_rst_i  (s_rst_i),
                .m_clk_i  (m_clk_i),
                .m_rst_i  (m_rst_i),
                .s_axis   (axis),
                .m_axis   (m_axis),
                .a_full_o (),
                .a_empty_o()
            );
        end
    end else begin : g_sync
        axis_dw_conv #(
            .TLAST_EN(TLAST_EN)
        ) i_axis_dw_conv (
            .clk_i (s_clk_i),
            .rst_i (s_rst_i),
            .m_axis(m_axis),
            .s_axis(s_axis)
        );
    end

endmodule
