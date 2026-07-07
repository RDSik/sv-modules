module axis_reg_slice (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    logic enable;
    assign enable = m_axis.tready | ~m_axis.tvalid;

    assign s_axis.tready = enable;

    always_ff @(posedge s_axis.clk_i) begin
        if (s_axis.rst_i) begin
            m_axis.tvalid <= '0;
            m_axis.tlast  <= '0;
            m_axis.tdata  <= '0;
            m_axis.tkeep  <= '0;
            m_axis.tid    <= '0;
            m_axis.tdest  <= '0;
            m_axis.tstrb  <= '0;
            m_axis.tuser  <= '0;
        end else if (enable) begin
            m_axis.tvalid <= s_axis.tvalid;
            m_axis.tlast  <= s_axis.tlast;
            m_axis.tdata  <= s_axis.tdata;
            m_axis.tkeep  <= s_axis.tkeep;
            m_axis.tid    <= s_axis.tid;
            m_axis.tdest  <= s_axis.tdest;
            m_axis.tstrb  <= s_axis.tstrb;
            m_axis.tuser  <= s_axis.tuser;
        end
    end

endmodule
