/* verilator lint_off TIMESCALEMOD */
module axis_fork #(
    parameter int SLAVE_NUM = 4
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis[SLAVE_NUM-1:0]
);

    logic [SLAVE_NUM-1:0] m_axis_tready;

    for (genvar i = 0; i < SLAVE_NUM; i++) begin : g_axis
        assign m_axis[i].tdata  = s_axis.tdata;
        assign m_axis[i].tvalid = (s_axis.tdest == i) && s_axis.tvalid;
        assign m_axis_tready[i] = m_axis[i].tready;
    end

    assign s_axis.tready = m_axis_tready[s_axis.tdest];

endmodule
