module axis_reg_slice (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    logic clk_i;
    logic arstn_i;

    assign clk_i   = s_axis.clk_i;
    assign arstn_i = s_axis.arstn_i;

    logic enable;
    assign enable = m_axis.tready | ~m_axis.tvalid;

    assign s_axis.tready = enable;

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            m_axis.tvalid <= '0;
            m_axis.tlast  <= '0;
            m_axis.tdata  <= '0;
        end else if (enable) begin
            m_axis.tvalid <= s_axis.tvalid;
            m_axis.tlast  <= s_axis.tlast;
            m_axis.tdata  <= s_axis.tdata;
        end
    end

endmodule
