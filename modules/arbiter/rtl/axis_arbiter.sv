/* verilator lint_off TIMESCALEMOD */
module axis_arbiter #(
    parameter int MASTER_NUM = 4,
    parameter int DATA_WIDTH = 16,
    parameter int USER_WIDTH = 2
) (
    axis_if.slave  s_axis[MASTER_NUM-1:0],
    axis_if.master m_axis
);

    logic                                  clk_i;
    logic                                  rst_i;
    logic                                  m_handshake;
    logic [MASTER_NUM-1:0]                 grant;
    logic [MASTER_NUM-1:0]                 grant_indx;
    logic [MASTER_NUM-1:0]                 s_axis_tvalid;
    logic [MASTER_NUM-1:0][DATA_WIDTH-1:0] s_axis_tdata;
    logic [MASTER_NUM-1:0][USER_WIDTH-1:0] m_axis_tuser;

    assign clk_i         = m_axis.clk_i;
    assign rst_i         = m_axis.rst_i;
    assign m_handshake   = m_axis.tvalid & m_axis.tready;
    assign m_axis.tvalid = |grant;

    for (genvar i = 0; i < MASTER_NUM; i++) begin : g_axis
        assign s_axis[i].tready = m_axis.tready & grant[i];
        assign s_axis_tvalid[i] = s_axis[i].tvalid;
        assign s_axis_tdata[i]  = s_axis[i].tdata;
    end

    assign m_axis.tdata = s_axis_tdata[grant_indx];
    assign m_axis.tuser = grant_indx;

    onehot_to_indx #(
        .MASTER_NUM(MASTER_NUM)
    ) i_onehot_to_indx (
        .onehot_i(grant),
        .indx_o  (grant_indx)
    );

    round_robin_arbiter #(
        .MASTER_NUM(MASTER_NUM)
    ) i_round_robin_arbiter (
        .clk_i  (clk_i),
        .rst_i  (rst_i),
        .ack_i  (m_handshake),
        .req_i  (s_axis_tvalid),
        .grant_o(grant)
    );

endmodule
