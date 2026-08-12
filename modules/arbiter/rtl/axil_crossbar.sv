/* verilator lint_off TIMESCALEMOD */
module axil_crossbar #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int MASTER_NUM = 1,
    parameter int SLAVE_NUM  = 3,

    parameter logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] SLAVE_LOW_ADDR  = '{default: '0},
    parameter logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] SLAVE_HIGH_ADDR = '{default: '0}
) (
    axil_if.slave  s_axil[MASTER_NUM-1:0],
    axil_if.master m_axil[ SLAVE_NUM-1:0]
);

    localparam logic [1:0] RESP_OKAY = 2'b00;
    localparam logic [1:0] RESP_DECERR = 2'b11;

    localparam int SLAVE_SEL_WIDTH = (SLAVE_NUM > 1) ? $clog2(SLAVE_NUM) : 1;
    localparam int MASTER_SEL_WIDTH = (MASTER_NUM > 1) ? $clog2(MASTER_NUM) : 1;

    typedef enum logic [1:0] {
        WR_IDLE,
        WR_SEND,
        WR_RESP
    } wr_state_e;

    typedef enum logic [1:0] {
        RD_IDLE,
        RD_SEND,
        RD_RESP
    } rd_state_e;

    wr_state_e wr_state;
    rd_state_e rd_state;

    typedef struct packed {
        logic [SLAVE_SEL_WIDTH-1:0] indx;
        logic                       valid;
    } addr_decode_t;

    function automatic addr_decode_t get_addr_indx(input logic [ADDR_WIDTH-1:0] addr);
        begin
            get_addr_indx = '0;
            for (int i = 0; i < SLAVE_NUM; i++) begin
                if (addr >= SLAVE_LOW_ADDR[i] && addr <= SLAVE_HIGH_ADDR[i]) begin
                    get_addr_indx.indx  = SLAVE_SEL_WIDTH'(i);
                    get_addr_indx.valid = 1'b1;
                    break;
                end
            end
        end
    endfunction

    logic clk_i;
    logic arstn_i;

    assign clk_i   = s_axil[0].clk_i;
    assign arstn_i = s_axil[0].arstn_i;

    logic [MASTER_NUM-1:0][  ADDR_WIDTH-1:0] s_awaddr;
    logic [MASTER_NUM-1:0]                   s_awvalid;
    logic [MASTER_NUM-1:0]                   s_awready;
    logic [MASTER_NUM-1:0][             2:0] s_awprot;
    logic [MASTER_NUM-1:0][  DATA_WIDTH-1:0] s_wdata;
    logic [MASTER_NUM-1:0][DATA_WIDTH/8-1:0] s_wstrb;
    logic [MASTER_NUM-1:0]                   s_wvalid;
    logic [MASTER_NUM-1:0]                   s_wready;
    logic [MASTER_NUM-1:0][             1:0] s_bresp;
    logic [MASTER_NUM-1:0]                   s_bvalid;
    logic [MASTER_NUM-1:0]                   s_bready;
    logic [MASTER_NUM-1:0][  ADDR_WIDTH-1:0] s_araddr;
    logic [MASTER_NUM-1:0]                   s_arvalid;
    logic [MASTER_NUM-1:0]                   s_arready;
    logic [MASTER_NUM-1:0][             2:0] s_arprot;
    logic [MASTER_NUM-1:0][  DATA_WIDTH-1:0] s_rdata;
    logic [MASTER_NUM-1:0]                   s_rvalid;
    logic [MASTER_NUM-1:0]                   s_rready;
    logic [MASTER_NUM-1:0][             1:0] s_rresp;

    logic [MASTER_NUM-1:0]                   aw_buf_valid;
    logic [MASTER_NUM-1:0][  ADDR_WIDTH-1:0] aw_buf_addr;
    logic [MASTER_NUM-1:0][             2:0] aw_buf_prot;

    logic [MASTER_NUM-1:0]                   w_buf_valid;
    logic [MASTER_NUM-1:0][  DATA_WIDTH-1:0] w_buf_data;
    logic [MASTER_NUM-1:0][DATA_WIDTH/8-1:0] w_buf_strb;

    logic [MASTER_NUM-1:0]                   ar_buf_valid;
    logic [MASTER_NUM-1:0][  ADDR_WIDTH-1:0] ar_buf_addr;
    logic [MASTER_NUM-1:0][             2:0] ar_buf_prot;

    for (genvar m = 0; m < MASTER_NUM; m++) begin : g_master
        assign s_awprot[m]       = s_axil[m].awprot;
        assign s_awaddr[m]       = s_axil[m].awaddr;
        assign s_awvalid[m]      = s_axil[m].awvalid;
        assign s_wdata[m]        = s_axil[m].wdata;
        assign s_wstrb[m]        = s_axil[m].wstrb;
        assign s_wvalid[m]       = s_axil[m].wvalid;
        assign s_bready[m]       = s_axil[m].bready;
        assign s_araddr[m]       = s_axil[m].araddr;
        assign s_arvalid[m]      = s_axil[m].arvalid;
        assign s_rready[m]       = s_axil[m].rready;
        assign s_arprot[m]       = s_axil[m].arprot;

        assign s_axil[m].awready = s_awready[m];
        assign s_axil[m].wready  = s_wready[m];
        assign s_axil[m].rresp   = s_rresp[m];
        assign s_axil[m].bresp   = s_bresp[m];
        assign s_axil[m].bvalid  = s_bvalid[m];
        assign s_axil[m].arready = s_arready[m];
        assign s_axil[m].rdata   = s_rdata[m];
        assign s_axil[m].rvalid  = s_rvalid[m];

        assign s_awready[m]      = !aw_buf_valid[m];
        assign s_wready[m]       = !w_buf_valid[m];
        assign s_arready[m]      = !ar_buf_valid[m];
    end

    logic [SLAVE_NUM-1:0][  ADDR_WIDTH-1:0] m_awaddr;
    logic [SLAVE_NUM-1:0]                   m_awvalid;
    logic [SLAVE_NUM-1:0]                   m_awready;
    logic [SLAVE_NUM-1:0][             2:0] m_awprot;
    logic [SLAVE_NUM-1:0][  DATA_WIDTH-1:0] m_wdata;
    logic [SLAVE_NUM-1:0][DATA_WIDTH/8-1:0] m_wstrb;
    logic [SLAVE_NUM-1:0]                   m_wvalid;
    logic [SLAVE_NUM-1:0]                   m_wready;
    logic [SLAVE_NUM-1:0][             1:0] m_bresp;
    logic [SLAVE_NUM-1:0]                   m_bvalid;
    logic [SLAVE_NUM-1:0]                   m_bready;
    logic [SLAVE_NUM-1:0][  ADDR_WIDTH-1:0] m_araddr;
    logic [SLAVE_NUM-1:0]                   m_arvalid;
    logic [SLAVE_NUM-1:0]                   m_arready;
    logic [SLAVE_NUM-1:0][             2:0] m_arprot;
    logic [SLAVE_NUM-1:0][  DATA_WIDTH-1:0] m_rdata;
    logic [SLAVE_NUM-1:0]                   m_rvalid;
    logic [SLAVE_NUM-1:0]                   m_rready;
    logic [SLAVE_NUM-1:0][             1:0] m_rresp;

    for (genvar s = 0; s < SLAVE_NUM; s++) begin : g_slave
        assign m_axil[s].awprot  = m_awprot[s];
        assign m_axil[s].awaddr  = m_awaddr[s];
        assign m_axil[s].awvalid = m_awvalid[s];
        assign m_axil[s].wdata   = m_wdata[s];
        assign m_axil[s].wstrb   = m_wstrb[s];
        assign m_axil[s].wvalid  = m_wvalid[s];
        assign m_axil[s].bready  = m_bready[s];
        assign m_axil[s].araddr  = m_araddr[s];
        assign m_axil[s].arvalid = m_arvalid[s];
        assign m_axil[s].rready  = m_rready[s];
        assign m_axil[s].arprot  = m_arprot[s];

        assign m_awready[s]      = m_axil[s].awready;
        assign m_wready[s]       = m_axil[s].wready;
        assign m_rresp[s]        = m_axil[s].rresp;
        assign m_bresp[s]        = m_axil[s].bresp;
        assign m_bvalid[s]       = m_axil[s].bvalid;
        assign m_arready[s]      = m_axil[s].arready;
        assign m_rdata[s]        = m_axil[s].rdata;
        assign m_rvalid[s]       = m_axil[s].rvalid;
    end

    logic [      MASTER_NUM-1:0] wr_req;
    logic [      MASTER_NUM-1:0] wr_grant;
    logic                        wr_ack;

    logic [      MASTER_NUM-1:0] rd_req;
    logic [      MASTER_NUM-1:0] rd_grant;
    logic                        rd_ack;

    logic [MASTER_SEL_WIDTH-1:0] wr_grant_indx;
    logic [MASTER_SEL_WIDTH-1:0] rd_grant_indx;

    logic                        wr_grant_valid;
    logic                        rd_grant_valid;

    assign wr_grant_valid = |wr_grant;
    assign rd_grant_valid = |rd_grant;

    always_comb begin
        for (int m = 0; m < MASTER_NUM; m++) begin
            wr_req[m] = (wr_state == WR_IDLE) && aw_buf_valid[m] && w_buf_valid[m];
            rd_req[m] = (rd_state == RD_IDLE) && ar_buf_valid[m];
        end
    end

    assign wr_ack = (wr_state == WR_IDLE) && wr_grant_valid;
    assign rd_ack = (rd_state == RD_IDLE) && rd_grant_valid;

    if (MASTER_NUM == 1) begin : g_no_arbiters
        assign wr_grant      = wr_req;
        assign wr_grant_indx = '0;
        assign rd_grant      = rd_req;
        assign rd_grant_indx = '0;
    end else begin : g_arbiters
        round_robin_arbiter #(
            .MASTER_NUM(MASTER_NUM)
        ) i_wr_round_robin_arbiter (
            .clk_i  (clk_i),
            .rst_i  (~arstn_i),
            .ack_i  (wr_ack),
            .req_i  (wr_req),
            .grant_o(wr_grant),
            .indx_o (wr_grant_indx)
        );

        round_robin_arbiter #(
            .MASTER_NUM(MASTER_NUM)
        ) i_rd_round_robin_arbiter (
            .clk_i  (clk_i),
            .rst_i  (~arstn_i),
            .ack_i  (rd_ack),
            .req_i  (rd_req),
            .grant_o(rd_grant),
            .indx_o (rd_grant_indx)
        );
    end

    logic         [MASTER_SEL_WIDTH-1:0] wr_owner;
    logic         [ SLAVE_SEL_WIDTH-1:0] wr_target;
    logic                                wr_target_valid;

    logic         [      ADDR_WIDTH-1:0] wr_addr_reg;
    logic         [                 2:0] wr_prot_reg;
    logic         [      DATA_WIDTH-1:0] wr_data_reg;
    logic         [    DATA_WIDTH/8-1:0] wr_strb_reg;

    logic                                wr_aw_done;
    logic                                wr_w_done;

    addr_decode_t                        wr_grant_decode;
    addr_decode_t                        rd_grant_decode;

    assign wr_grant_decode = get_addr_indx(aw_buf_addr[wr_grant_indx]);
    assign rd_grant_decode = get_addr_indx(ar_buf_addr[rd_grant_indx]);

    logic wr_aw_handshake;
    logic wr_w_handshake;

    assign wr_aw_handshake = (wr_state == WR_SEND) && wr_target_valid && !wr_aw_done && m_awready[wr_target];
    assign wr_w_handshake  = (wr_state == WR_SEND) && wr_target_valid && !wr_w_done && m_wready[wr_target];

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            aw_buf_valid <= '0;
            w_buf_valid  <= '0;
            ar_buf_valid <= '0;
            aw_buf_addr  <= '0;
            aw_buf_prot  <= '0;
            w_buf_data   <= '0;
            w_buf_strb   <= '0;
            ar_buf_addr  <= '0;
            ar_buf_prot  <= '0;
        end else begin
            for (int m = 0; m < MASTER_NUM; m++) begin
                if (s_awvalid[m] & s_awready[m]) begin
                    aw_buf_valid[m] <= 1'b1;
                    aw_buf_addr[m]  <= s_awaddr[m];
                    aw_buf_prot[m]  <= s_awprot[m];
                end

                if (s_wvalid[m] & s_wready[m]) begin
                    w_buf_valid[m] <= 1'b1;
                    w_buf_data[m]  <= s_wdata;
                    w_buf_strb[m]  <= s_wstrb;
                end

                if (s_arvalid[m] & s_arready[m]) begin
                    ar_buf_valid[m] <= 1'b1;
                    ar_buf_addr[m]  <= s_araddr;
                    ar_buf_prot[m]  <= s_arprot;
                end
            end

            if (wr_ack) begin
                aw_buf_valid[wr_grant_indx] <= 1'b0;
                w_buf_valid[wr_grant_indx]  <= 1'b0;
            end

            if (rd_ack) begin
                ar_buf_valid[rd_grant_indx] <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            wr_state        <= WR_IDLE;
            wr_owner        <= '0;
            wr_target       <= '0;
            wr_target_valid <= '0;
            wr_addr_reg     <= '0;
            wr_prot_reg     <= '0;
            wr_data_reg     <= '0;
            wr_strb_reg     <= '0;
            wr_aw_done      <= '0;
            wr_w_done       <= '0;
        end else begin
            case (wr_state)
                WR_IDLE: begin
                    wr_aw_done <= 1'b0;
                    wr_w_done  <= 1'b0;

                    if (wr_grant_valid) begin
                        wr_owner        <= wr_grant_indx;
                        wr_target       <= wr_grant_decode.indx;
                        wr_target_valid <= wr_grant_decode.valid;

                        wr_addr_reg     <= aw_buf_addr[wr_grant_indx];
                        wr_prot_reg     <= aw_buf_prot[wr_grant_indx];
                        wr_data_reg     <= w_buf_data[wr_grant_indx];
                        wr_strb_reg     <= w_buf_strb[wr_grant_indx];

                        if (wr_grant_decode.valid) begin
                            wr_state <= WR_SEND;
                        end else begin
                            wr_state <= WR_RESP;
                        end
                    end
                end

                WR_SEND: begin
                    if (wr_aw_handshake) begin
                        wr_aw_done <= 1'b1;
                    end

                    if (wr_w_handshake) begin
                        wr_w_done <= 1'b1;
                    end

                    if ((wr_aw_done | wr_aw_handshake) && (wr_w_done | wr_w_handshake)) begin
                        wr_state <= WR_RESP;
                    end
                end

                WR_RESP: begin
                    if (wr_target_valid) begin
                        if (m_bvalid[wr_target] & s_bready[wr_owner]) begin
                            wr_state <= WR_IDLE;
                        end
                    end else begin
                        if (s_bready[wr_owner]) begin
                            wr_state <= WR_IDLE;
                        end
                    end
                end

                default: wr_state <= WR_IDLE;
            endcase
        end
    end

    logic [MASTER_SEL_WIDTH-1:0] rd_owner;
    logic [ SLAVE_SEL_WIDTH-1:0] rd_target;
    logic                        rd_target_valid;

    logic [      ADDR_WIDTH-1:0] rd_addr_reg;
    logic [                 2:0] rd_prot_reg;

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            rd_state        <= RD_IDLE;
            rd_owner        <= '0;
            rd_target       <= '0;
            rd_target_valid <= '0;
            rd_addr_reg     <= '0;
            rd_prot_reg     <= '0;
        end else begin
            case (rd_state)
                RD_IDLE: begin
                    if (rd_grant_valid) begin
                        rd_owner        <= rd_grant_indx;
                        rd_target       <= rd_grant_decode.indx;
                        rd_target_valid <= rd_grant_decode.valid;
                        rd_addr_reg     <= ar_buf_addr[rd_grant_indx];
                        rd_prot_reg     <= ar_buf_prot[rd_grant_indx];

                        if (rd_grant_decode.valid) begin
                            rd_state <= RD_SEND;
                        end else begin
                            rd_state <= RD_RESP;
                        end
                    end
                end

                RD_SEND: begin
                    if (m_arready[rd_target]) begin
                        rd_state <= RD_RESP;
                    end
                end

                RD_RESP: begin
                    if (rd_target_valid) begin
                        if (m_rvalid[rd_target] & s_rready[rd_owner]) begin
                            rd_state <= RD_IDLE;
                        end
                    end else begin
                        if (s_rready[rd_owner]) begin
                            rd_state <= RD_IDLE;
                        end
                    end
                end

                default: rd_state <= RD_IDLE;
            endcase
        end
    end

    always_comb begin
        for (int s = 0; s < SLAVE_NUM; s++) begin
            m_awaddr[s]  = '0;
            m_awprot[s]  = '0;
            m_awvalid[s] = '0;
            m_wdata[s]   = '0;
            m_wstrb[s]   = '0;
            m_wvalid[s]  = '0;
            m_bready[s]  = '0;
            m_araddr[s]  = '0;
            m_arprot[s]  = '0;
            m_arvalid[s] = '0;
            m_rready[s]  = '0;
        end

        if ((wr_state == WR_SEND) && wr_target_valid) begin
            m_awaddr[wr_target]  = wr_addr_reg;
            m_awprot[wr_target]  = wr_prot_reg;
            m_awvalid[wr_target] = ~wr_aw_done;
            m_wdata[wr_target]   = wr_data_reg;
            m_wstrb[wr_target]   = wr_strb_reg;
            m_wvalid[wr_target]  = ~wr_w_done;
        end

        if ((wr_state == WR_RESP) && wr_target_valid) begin
            m_bready[wr_target] = s_bready[wr_owner];
        end

        if ((rd_state == RD_SEND) && rd_target_valid) begin
            m_araddr[rd_target]  = rd_addr_reg;
            m_arprot[rd_target]  = rd_prot_reg;
            m_arvalid[rd_target] = 1'b1;
        end

        if ((rd_state == RD_RESP) && rd_target_valid) begin
            m_rready[rd_target] = s_rready[rd_owner];
        end
    end

    always_comb begin
        for (int m = 0; m < MASTER_NUM; m++) begin
            s_bvalid[m] = 1'b0;
            s_bresp[m]  = RESP_OKAY;
            s_rvalid[m] = 1'b0;
            s_rresp[m]  = RESP_OKAY;
            s_rdata[m]  = '0;
        end

        if (wr_state == WR_RESP) begin
            if (wr_target_valid) begin
                s_bvalid[wr_owner] = m_bvalid[wr_target];
                s_bresp[wr_owner]  = m_bresp[wr_target];
            end else begin
                s_bvalid[wr_owner] = 1'b1;
                s_bresp[wr_owner]  = RESP_DECERR;
            end
        end

        if (rd_state == RD_RESP) begin
            if (rd_target_valid) begin
                s_rvalid[rd_owner] = m_rvalid[rd_target];
                s_rresp[rd_owner]  = m_rresp[rd_target];
                s_rdata[rd_owner]  = m_rdata[rd_target];
            end else begin
                s_rvalid[rd_owner] = 1'b1;
                s_rresp[rd_owner]  = RESP_DECERR;
                s_rdata[rd_owner]  = '0;
            end
        end
    end

endmodule
