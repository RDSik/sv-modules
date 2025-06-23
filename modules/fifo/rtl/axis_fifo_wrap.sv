/* verilator lint_off TIMESCALEMOD */
module axis_fifo_wrap #(
    parameter int FIFO_WIDTH  = 16,
    parameter int FIFO_DEPTH  = 64,
    parameter int CDC_REG_NUM = 2,
    parameter int CIRCLE_BUF  = 1,
    parameter     FIFO_TYPE   = "SYNC"
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

/* verilator lint_off WIDTHEXPAND */
if ((FIFO_TYPE != "SYNC") && (FIFO_TYPE != "ASYNC")) begin
    $error("Only SYNC or ASYNC FIFO_TYPE is available!");
end
/* verilator lint_on WIDTHEXPAND */

logic rd_clk_i;
logic wr_clk_i;
logic rd_arstn_i;
logic wr_arstn_i;
logic pop;
logic push;
logic empty;
logic full;

assign rd_clk_i = s_axis.clk_i;
assign wr_clk_i = m_axis.clk_i;

assign rd_arstn_i = s_axis.arstn_i;
assign wr_arstn_i = m_axis.arstn_i;

assign s_axis.tready = ~full;
assign m_axis.tvalid = ~empty;

assign push = s_axis.tvalid & s_axis.tready;
assign pop  = m_axis.tvalid & m_axis.tready;

if (FIFO_TYPE == "SYNC") begin: g_fifo
    sync_fifo #(
        .FIFO_WIDTH  (FIFO_WIDTH    ),
        .FIFO_DEPTH  (FIFO_DEPTH    ),
        .CIRCLE_BUF  (CIRCLE_BUF    )
    ) i_fifo (
        .clk_i       (rd_clk_i      ),
        .arstn_i     (rd_arstn_i    ),
        .data_i      (s_axis.tdata  ),
        .data_o      (m_axis.tdata  ),
        .push_i      (push          ),
        .pop_i       (pop           ),
        .full_o      (full          ),
        .empty_o     (empty         )
    );
end else if (FIFO_TYPE == "ASYNC") begin : g_fifo
    async_fifo #(
        .FIFO_WIDTH  (FIFO_WIDTH  ),
        .FIFO_DEPTH  (FIFO_DEPTH  ),
        .CDC_REG_NUM (CDC_REG_NUM )
    ) i_fifo (
        .wr_clk_i    (wr_clk_i    ),
        .wr_arstn_i  (wr_arstn_i  ),
        .wr_data_i   (s_axis.tdata),
        .rd_clk_i    (rd_clk_i    ),
        .rd_arstn_i  (rd_arstn_i  ),
        .rd_data_o   (m_axis.tdata),
        .push_i      (push        ),
        .pop_i       (pop         ),
        .full_o      (full        ),
        .empty_o     (empty       )
    );
end

endmodule
