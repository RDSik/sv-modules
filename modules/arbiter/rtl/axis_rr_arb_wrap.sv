/* verilator lint_off TIMESCALEMOD */
module axis_rr_arb_wrap #(
    parameter int MASTER_NUM = 4,
    parameter int DATA_WIDTH = 16,
    parameter int USER_WIDTH = 2
) (
    axis_if.slave  s_axis[MASTER_NUM-1:0],
    axis_if.master m_axis
);

    logic                                  clk_i;
    logic                                  rstn_i;
    logic                                  m_handshake;
    logic [MASTER_NUM-1:0]                 grant;
    logic [MASTER_NUM-1:0]                 s_axis_tvalid;
    logic [MASTER_NUM-1:0][DATA_WIDTH-1:0] m_axis_tdata;
    logic [MASTER_NUM-1:0][USER_WIDTH-1:0] m_axis_tuser;

    assign clk_i         = m_axis.clk_i;
    assign rst_i         = m_axis.rst_i;
    assign m_handshake   = m_axis.tvalid & m_axis.tready;
    assign m_axis.tvalid = |grant;

    for (genvar i = 0; i < MASTER_NUM; i++) begin : g_axis
        assign s_axis[i].tready = m_axis.tready & grant[i];
        assign s_axis_tvalid[i] = s_axis[i].tvalid;
        assign m_axis_tdata[i]  = {DATA_WIDTH{grant[i]}} & s_axis[i].tdata;
        assign m_axis_tuser[i]  = {USER_WIDTH{grant[i]}} & USER_WIDTH'(i);
    end

    always_comb begin
        m_axis.tdata = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (m_axis_tdata[i] != 0) begin
                m_axis.tdata = m_axis_tdata[i];
            end
        end
    end

    always_comb begin
        m_axis.tuser = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (m_axis_tuser[i] != 0) begin
                m_axis.tuser = m_axis_tuser[i];
            end
        end
    end

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
