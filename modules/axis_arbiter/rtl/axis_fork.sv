/* verilator lint_off TIMESCALEMOD */
module axis_fork #(
    parameter int SLAVE_NUM = 4
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis[SLAVE_NUM-1:0]
);

    for (genvar i = 0; i < SLAVE_NUM; i++) begin : g_axis
        assign m_axis[i].tdata  = s_axis.tdata;
        assign m_axis[i].tvalid = (s_axis.tdest == i) && s_axis.tvalid;
        assign s_axis.tready    = (s_axis.tdest == i) ? m_axis[i].tready : 1'b0;
    end

endmodule
