/* verilator lint_off TIMESCALEMOD */
module axis_fifo_wrap #(
    parameter int FIFO_WIDTH  = 32,
    parameter int FIFO_DEPTH  = 128,
    parameter int CDC_REG_NUM = 2,
    parameter     FIFO_MODE   = "sync",
    parameter     FIFO_TYPE   = "block"
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis,

    output logic a_full_o,
    output logic a_empty_o
);

    /* verilator lint_off WIDTHEXPAND */
    if ((FIFO_MODE != "sync") && (FIFO_MODE != "async")) begin : g_fifo_mode_err
        $error("Only sync or async FIFO_MODE is available!");
    end
    /* verilator lint_on WIDTHEXPAND */

    logic pop;
    logic push;
    logic empty;
    logic full;

    assign s_axis.tready = ~full;
    assign m_axis.tvalid = ~empty;

    assign push = s_axis.tvalid & s_axis.tready;
    assign pop = m_axis.tvalid & m_axis.tready;

    if (FIFO_MODE == "sync") begin : g_fifo
        sync_fifo #(
            .FIFO_WIDTH(FIFO_WIDTH),
            .FIFO_DEPTH(FIFO_DEPTH),
            .FIFO_TYPE (FIFO_TYPE)
        ) i_fifo (
            .clk_i    (s_axis.clk_i),
            .rstn_i   (s_axis.rstn_i),
            .data_i   (s_axis.tdata),
            .data_o   (m_axis.tdata),
            .push_i   (push),
            .pop_i    (pop),
            .empty_o  (empty),
            .full_o   (full),
            .a_empty_o(a_empty_o),
            .a_full_o (a_full_o)
        );
    end else if (FIFO_MODE == "async") begin : g_fifo
        async_fifo #(
            .FIFO_WIDTH (FIFO_WIDTH),
            .FIFO_DEPTH (FIFO_DEPTH),
            .FIFO_TYPE  (FIFO_TYPE),
            .CDC_REG_NUM(CDC_REG_NUM)
        ) i_fifo (
            .wr_clk_i (s_axis.clk_i),
            .wr_rstn_i(s_axis.rstn_i),
            .wr_data_i(s_axis.tdata),
            .rd_clk_i (m_axis.clk_i),
            .rd_rstn_i(m_axis.rstn_i),
            .rd_data_o(m_axis.tdata),
            .push_i   (push),
            .pop_i    (pop),
            .empty_o  (empty),
            .full_o   (full),
            .a_empty_o(a_empty_o),
            .a_full_o (a_full_o)
        );
    end else begin
        $error("Only sync or async FIFO_MODE is available!");
    end

endmodule
