module axis_fork #(
    parameter int SLAVE_NUM = 4
) (
    axis_if.slave                  s_axis,
    axis_if.master [SLAVE_NUM-1:0] m_axis
);

    for (genvar i = 0; i < SLAVE_NUM; i++) begin : g_m_tvalid_tdata
        assign m_axis[i].tdata  = s_axis.tdata;
        assign m_axis[i].tvalid = s_axis.tvalid && (s_axis.tdest == i);
    end

    always_comb begin
        for (i = 0; i < SLAVE_NUM; i++) begin
            if (s_axis.tdest == i) begin
                s_axis.tready = m_axis[i].tready;
            end else begin
                s_axis.tready = 1'b0;
            end
        end
    end

endmodule
