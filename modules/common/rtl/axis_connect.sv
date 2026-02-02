module axis_connect (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    always_ff @(posedge m_axis.clk_i) begin
        if (m_axis.rst_i) begin
            m_axis.tvalid <= '0;
            m_axis.tlast  <= '0;
            m_axis.tdata  <= '0;
        end else if (m_axis.tready | ~m_axis.tvalid) begin
            m_axis.tvalid <= s_axis.tvalid;
            m_axis.tlast  <= s_axis.tlast;
            m_axis.tdata  <= s_axis.tdata;
        end
    end

    assign s_axis.tready = m_axis.tready | ~m_axis.tvalid;

endmodule
