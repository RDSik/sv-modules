/* verilator lint_off TIMESCALEMOD */
module axis_fifo_wrap #(
    parameter int   FIFO_WIDTH   = 32,
    parameter int   FIFO_DEPTH   = 128,
    parameter int   CDC_REG_NUM  = 2,
    parameter int   READ_LATENCY = 1,
    parameter logic TLAST_EN     = 0,
    parameter       RAM_STYLE    = "block",
    parameter       FIFO_MODE    = "sync"
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis,

    output logic a_full_o,
    output logic a_empty_o,

    output logic [$clog2(FIFO_DEPTH):0] data_cnt_o
);

    localparam int FULL_WIDTH = FIFO_WIDTH + TLAST_EN;

    logic [FULL_WIDTH-1:0] wr_data;
    logic [FULL_WIDTH-1:0] rd_data;
    logic                  pop;
    logic                  push;
    logic                  empty;
    logic                  full;

    if (TLAST_EN) begin : g_tlast_en
        assign wr_data = {s_axis.tlast, s_axis.tdata};
        assign {m_axis.tlast, m_axis.tdata} = rd_data;
    end else begin : g_tlast_disable
        assign wr_data = s_axis.tdata;
        assign m_axis.tdata = rd_data;
    end

    assign s_axis.tready = ~full;
    assign m_axis.tvalid = ~empty;

    assign push = s_axis.tvalid & s_axis.tready;
    assign pop = m_axis.tvalid & m_axis.tready;

    if (FIFO_MODE == "sync") begin : g_sync_fifo
        sync_fifo #(
            .FIFO_WIDTH  (FULL_WIDTH),
            .FIFO_DEPTH  (FIFO_DEPTH),
            .READ_LATENCY(READ_LATENCY),
            .RAM_STYLE   (RAM_STYLE)
        ) i_sync_fifo (
            .clk_i     (s_axis.clk_i),
            .rst_i     (s_axis.rst_i),
            .data_i    (wr_data),
            .data_o    (rd_data),
            .push_i    (push),
            .pop_i     (pop),
            .empty_o   (empty),
            .full_o    (full),
            .a_empty_o (a_empty_o),
            .a_full_o  (a_full_o),
            .data_cnt_o(data_cnt_o)
        );
    end else if (FIFO_MODE == "async") begin : g_async_fifo
        async_fifo #(
            .FIFO_WIDTH  (FULL_WIDTH),
            .FIFO_DEPTH  (FIFO_DEPTH),
            .CDC_REG_NUM (CDC_REG_NUM),
            .READ_LATENCY(0),
            .RAM_STYLE   ("distributed")
        ) i_async_fifo (
            .wr_clk_i (s_axis.clk_i),
            .wr_rst_i (s_axis.rst_i),
            .wr_data_i(wr_data),
            .rd_clk_i (m_axis.clk_i),
            .rd_rst_i (m_axis.rst_i),
            .rd_data_o(rd_data),
            .push_i   (push),
            .pop_i    (pop),
            .empty_o  (empty),
            .full_o   (full),
            .a_empty_o(a_empty_o),
            .a_full_o (a_full_o)
        );

        assign data_cnt_o = '0;
    end else begin : g_fifo
        $error("Only sync or async FIFO_MODE is available!");
    end

endmodule
