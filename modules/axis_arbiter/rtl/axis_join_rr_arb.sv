/* verilator lint_off TIMESCALEMOD */
module axis_join_rr_arb #(
    parameter int MASTER_NUM = 4
) (
    axis_if.slave  s_axis[MASTER_NUM-1:0],
    axis_if.master m_axis
);

    localparam int PTR_WIDTH = $clog2(MASTER_NUM);

    logic                      clk_i;
    logic                      rstn_i;

    logic [    MASTER_NUM-1:0] req;
    logic [    MASTER_NUM-1:0] grant;
    logic [    MASTER_NUM-1:0] req_shift;
    logic [    MASTER_NUM-1:0] grant_shift;

    logic [(MASTER_NUM*2)-1:0] req_shift_double;
    logic [(MASTER_NUM*2)-1:0] grant_shift_double;

    logic [     PTR_WIDTH-1:0] ptr;
    logic [     PTR_WIDTH-1:0] ptr_next;

    logic                      m_handshake;

    assign clk_i  = m_axis.clk_i;
    assign rstn_i = m_axis.rstn_i;

    for (genvar i = 0; i < MASTER_NUM; i++) begin : g_axis
        assign s_axis[i].tready = m_axis.tready & grant[i];
        assign req[i]           = s_axis[i].tvalid;
    end

    assign req_shift_double   = {req, req} >> ptr;
    assign req_shift          = req_shift_double[MASTER_NUM-1:0];

    assign grant_shift_double = {grant_shift, grant_shift} << ptr;
    assign grant              = grant_shift_double[(MASTER_NUM*2)-1:MASTER_NUM];

    assign m_axis.tvalid      = |grant;

    always_comb begin
        m_axis.data  = '0;
        m_axis.tuser = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (grant[i]) begin
                m_axis.tdata = s_axis[i].tdata;
                m_axis.tuser = i;
            end
        end
    end

    always_comb begin
        grant_shift = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (req_shift[i]) begin
                grant_shift[i] = 1'b1;
                break;
            end
        end
    end

    always_comb begin
        ptr_next = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (grant[i]) begin
                ptr_next = (i + 1) % MASTER_NUM;
                break;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            ptr <= '0;
        end else if (m_handshake) begin
            ptr <= ptr_next;
        end
    end

    assign m_handshake = m_axis.tvalid & m_axis.tready;

endmodule
