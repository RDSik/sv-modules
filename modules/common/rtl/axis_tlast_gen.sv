module axis_tlast_gen #(
    parameter int TLAST_VAL = 256
) (
    axis_if.slave  s_axis,
    axis_if.master m_axis
);

    logic handshake;
    assign handshake = s_axis.tvalid & s_axis.tready;

    logic cnt_last;

    cnt #(
        .MAX_VAL(TLAST_VAL)
    ) i_cnt (
        .clk_i     (s_axis.clk_i),
        .rst_i     (~s_axis.arstn_i),
        .en_i      (handshake),
        .cnt_last_o(cnt_last),
        .cnt_o     ()
    );

    axis_if #(
        .DEST_WIDTH(s_axis.DEST_WIDTH),
        .DATA_WIDTH(s_axis.DATA_WIDTH),
        .ID_WIDTH  (s_axis.ID_WIDTH),
        .USER_WIDTH(s_axis.USER_WIDTH)
    ) axis (
        .clk_i  (s_axis.clk_i),
        .arstn_i(s_axis.arstn_i)
    );

    assign axis.tdata  = s_axis.tdata;
    assign axis.tvalid = s_axis.tvalid;
    assign axis.tlast  = cnt_last;
    assign axis.tid    = s_axis.tid;
    assign axis.tdest  = s_axis.tdest;
    assign axis.tstrb  = s_axis.tstrb;
    assign axis.tuser  = s_axis.tuser;
    assign axis.tkeep  = s_axis.tkeep;

    assign s_axis.tready = axis.tready;

    axis_reg_slice i_axis_reg_slice (
        .s_axis(axis),
        .m_axis(m_axis)
    );

endmodule
