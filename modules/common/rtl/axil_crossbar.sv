/* verilator lint_off TIMESCALEMOD */
module axil_crossbar #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int MASTER_NUM = 1,
    parameter int SLAVE_NUM = 3,
    parameter logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] SLAVE_LOW_ADDR = '{default: '0},
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
        WR_IDLE = 2'b00,
        WR_ADDR = 2'b01,
        WR_DATA = 2'b10,
        WR_RESP = 2'b11
    } wr_state_t;

    wr_state_t wr_state, wr_next_state;

    typedef enum logic [1:0] {
        RD_IDLE = 2'b00,
        RD_ADDR = 2'b01,
        RD_DATA = 2'b10
    } rd_state_t;

    rd_state_t rd_state, rd_next_state;

    typedef struct packed {
        logic [SLAVE_SEL_WIDTH-1:0] indx;
        logic                       valid;
    } addr_decode_t;

    function automatic addr_decode_t get_addr_index(input logic [ADDR_WIDTH-1:0] addr);
        begin
            get_addr_index = '0;
            for (int i = 0; i < SLAVE_NUM; i++) begin
                if (addr >= SLAVE_LOW_ADDR[i] && addr <= SLAVE_HIGH_ADDR[i]) begin
                    get_addr_index.indx  = SLAVE_SEL_WIDTH'(i);
                    get_addr_index.valid = 1'b1;
                    break;
                end
            end
        end
    endfunction

    function automatic logic [MASTER_SEL_WIDTH-1:0] get_grant_index(
        input logic [MASTER_NUM-1:0] grant);
        begin
            get_grant_index = '0;
            for (int i = 0; i < MASTER_NUM; i++) begin
                if (grant[i]) begin
                    get_grant_index = MASTER_SEL_WIDTH'(i);
                    break;
                end
            end
        end
    endfunction

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_axil[0].clk_i;
    assign rstn_i = s_axil[0].rstn_i;

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

    for (genvar i = 0; i < MASTER_NUM; i++) begin : g_master
        assign s_awprot[i]       = s_axil[i].awprot;
        assign s_awaddr[i]       = s_axil[i].awaddr;
        assign s_awvalid[i]      = s_axil[i].awvalid;
        assign s_wdata[i]        = s_axil[i].wdata;
        assign s_wstrb[i]        = s_axil[i].wstrb;
        assign s_wvalid[i]       = s_axil[i].wvalid;
        assign s_bready[i]       = s_axil[i].bready;
        assign s_araddr[i]       = s_axil[i].araddr;
        assign s_arvalid[i]      = s_axil[i].arvalid;
        assign s_rready[i]       = s_axil[i].rready;
        assign s_arprot[i]       = s_axil[i].arprot;

        assign s_axil[i].awready = s_awready[i];
        assign s_axil[i].wready  = s_wready[i];
        assign s_axil[i].rresp   = s_rresp[i];
        assign s_axil[i].bresp   = s_bresp[i];
        assign s_axil[i].bvalid  = s_bvalid[i];
        assign s_axil[i].arready = s_arready[i];
        assign s_axil[i].rdata   = s_rdata[i];
        assign s_axil[i].rvalid  = s_rvalid[i];
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

    for (genvar i = 0; i < SLAVE_NUM; i++) begin : g_slave
        assign m_axil[i].awprot  = m_awprot[i];
        assign m_axil[i].awaddr  = m_awaddr[i];
        assign m_axil[i].awvalid = m_awvalid[i];
        assign m_axil[i].wdata   = m_wdata[i];
        assign m_axil[i].wstrb   = m_wstrb[i];
        assign m_axil[i].wvalid  = m_wvalid[i];
        assign m_axil[i].bready  = m_bready[i];
        assign m_axil[i].araddr  = m_araddr[i];
        assign m_axil[i].arvalid = m_arvalid[i];
        assign m_axil[i].rready  = m_rready[i];
        assign m_axil[i].arprot  = m_arprot[i];

        assign m_awready[i]      = m_axil[i].awready;
        assign m_wready[i]       = m_axil[i].wready;
        assign m_rresp[i]        = m_axil[i].rresp;
        assign m_bresp[i]        = m_axil[i].bresp;
        assign m_bvalid[i]       = m_axil[i].bvalid;
        assign m_arready[i]      = m_axil[i].arready;
        assign m_rdata[i]        = m_axil[i].rdata;
        assign m_rvalid[i]       = m_axil[i].rvalid;
    end

    logic [MASTER_NUM-1:0] wr_req;
    logic [MASTER_NUM-1:0] wr_grant;
    logic                  wr_ack;

    logic [MASTER_NUM-1:0] rd_req;
    logic [MASTER_NUM-1:0] rd_grant;
    logic                  rd_ack;

    if (MASTER_NUM == 1) begin : g_arbiter_disable
        assign wr_grant = (wr_state == WR_IDLE) && s_awvalid[0];
        assign rd_grant = (rd_state == RD_IDLE) && s_arvalid[0];
        assign wr_req   = '0;
        assign rd_req   = '0;
        assign wr_ack   = '0;
        assign rd_ack   = '0;
    end else begin : g_arbiter_enable
        always_comb begin
            for (int i = 0; i < MASTER_NUM; i++) begin
                wr_req[i] = (wr_state == WR_IDLE) && s_awvalid[i];
                rd_req[i] = (rd_state == RD_IDLE) && s_arvalid[i];
            end
        end

        assign wr_ack = (wr_state == WR_RESP) && (wr_next_state == WR_IDLE);
        assign rd_ack = (rd_state == RD_DATA) && (rd_next_state == RD_IDLE);

        round_robin_arbiter #(
            .MASTER_NUM(MASTER_NUM)
        ) i_wr_round_robin_arbiter (
            .clk_i  (clk_i),
            .rst_i  (~rstn_i),
            .ack_i  (wr_ack),
            .req_i  (wr_req),
            .grant_o(wr_grant)
        );

        round_robin_arbiter #(
            .MASTER_NUM(MASTER_NUM)
        ) i_rd_round_robin_arbiter (
            .clk_i  (clk_i),
            .rst_i  (~rstn_i),
            .ack_i  (rd_ack),
            .req_i  (rd_req),
            .grant_o(rd_grant)
        );
    end

    logic [MASTER_SEL_WIDTH-1:0] wr_grant_indx;
    logic [MASTER_SEL_WIDTH-1:0] wr_grant_indx_reg;
    logic [MASTER_SEL_WIDTH-1:0] rd_grant_indx;
    logic [MASTER_SEL_WIDTH-1:0] rd_grant_indx_reg;

    assign wr_grant_indx = get_grant_index(wr_grant);
    assign rd_grant_indx = get_grant_index(rd_grant);

    addr_decode_t m_awindx;
    addr_decode_t m_awindx_reg;
    addr_decode_t m_arindx;
    addr_decode_t m_arindx_reg;

    assign m_awindx = get_addr_index(s_awaddr[wr_grant_indx]);
    assign m_arindx = get_addr_index(s_araddr[rd_grant_indx]);

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            wr_state          <= WR_IDLE;
            m_awindx_reg      <= '0;
            wr_grant_indx_reg <= '0;
        end else begin
            wr_state <= wr_next_state;
            if (wr_state == WR_IDLE && |wr_grant) begin
                wr_grant_indx_reg <= wr_grant_indx;
                m_awindx_reg      <= m_awindx;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (~rstn_i) begin
            rd_state          <= RD_IDLE;
            m_arindx_reg      <= '0;
            rd_grant_indx_reg <= '0;
        end else begin
            rd_state <= rd_next_state;
            if (rd_state == RD_IDLE && |rd_grant) begin
                rd_grant_indx_reg <= rd_grant_indx;
                m_arindx_reg      <= m_arindx;
            end
        end
    end

    always_comb begin
        wr_next_state = wr_state;
        case (wr_state)
            WR_IDLE: begin
                if (|wr_grant) begin
                    wr_next_state = WR_ADDR;
                end
            end
            WR_ADDR: begin
                if (m_awindx_reg.valid) begin
                    if (m_awready[m_awindx_reg.indx] && m_awvalid[m_awindx_reg.indx]) begin
                        if (m_wready[m_awindx_reg.indx] && m_wvalid[m_awindx_reg.indx]) begin
                            wr_next_state = WR_RESP;
                        end else begin
                            wr_next_state = WR_DATA;
                        end
                    end
                end else begin
                    wr_next_state = WR_DATA;
                end
            end
            WR_DATA: begin
                if (m_awindx_reg.valid) begin
                    if (m_wready[m_awindx_reg.indx] && m_wvalid[m_awindx_reg.indx]) begin
                        wr_next_state = WR_RESP;
                    end
                end else if (s_wvalid[wr_grant_indx_reg]) begin
                    wr_next_state = WR_RESP;
                end
            end
            WR_RESP: begin
                if (m_awindx_reg.valid) begin
                    if (m_bready[m_awindx_reg.indx] && m_bvalid[m_awindx_reg.indx]) begin
                        wr_next_state = WR_IDLE;
                    end
                end else if (s_bready[wr_grant_indx_reg]) begin
                    wr_next_state = WR_IDLE;
                end
            end
            default: wr_next_state = wr_state;
        endcase
    end

    always_comb begin
        rd_next_state = rd_state;
        case (rd_state)
            RD_IDLE: begin
                if (|rd_grant) begin
                    rd_next_state = RD_ADDR;
                end
            end
            RD_ADDR: begin
                if (m_arindx_reg.valid) begin
                    if (m_arready[m_arindx_reg.indx] && m_arvalid[m_arindx_reg.indx]) begin
                        rd_next_state = RD_DATA;
                    end
                end else begin
                    rd_next_state = RD_DATA;
                end
            end
            RD_DATA: begin
                if (m_arindx_reg.valid) begin
                    if (m_rvalid[m_arindx_reg.indx] && m_rready[m_arindx_reg.indx]) begin
                        rd_next_state = RD_IDLE;
                    end
                end else if (s_rready[rd_grant_indx_reg]) begin
                    rd_next_state = RD_IDLE;
                end
            end
            default: rd_next_state = rd_state;
        endcase
    end

    always_comb begin
        for (int i = 0; i < SLAVE_NUM; i++) begin
            m_awaddr[i]  = '0;
            m_awprot[i]  = '0;
            m_awvalid[i] = '0;
            m_wdata[i]   = '0;
            m_wstrb[i]   = '0;
            m_wvalid[i]  = '0;
            m_bready[i]  = '0;
        end
        case (wr_state)
            WR_ADDR: begin
                m_awaddr[m_awindx_reg.indx]  = s_awaddr[wr_grant_indx_reg];
                m_awprot[m_awindx_reg.indx]  = s_awprot[wr_grant_indx_reg];
                m_awvalid[m_awindx_reg.indx] = s_awvalid[wr_grant_indx_reg] & m_awindx_reg.valid;

                m_wdata[m_awindx_reg.indx]   = s_wdata[wr_grant_indx_reg];
                m_wstrb[m_awindx_reg.indx]   = s_wstrb[wr_grant_indx_reg];
                m_wvalid[m_awindx_reg.indx]  = s_wvalid[wr_grant_indx_reg] & m_awindx_reg.valid;
            end
            WR_DATA: begin
                m_wdata[m_awindx_reg.indx]  = s_wdata[wr_grant_indx_reg];
                m_wstrb[m_awindx_reg.indx]  = s_wstrb[wr_grant_indx_reg];
                m_wvalid[m_awindx_reg.indx] = s_wvalid[wr_grant_indx_reg] & m_awindx_reg.valid;
            end
            WR_RESP: begin
                m_bready[m_awindx_reg.indx] = s_bready[wr_grant_indx_reg] & m_awindx_reg.valid;
            end
            default: ;
        endcase
    end

    always_comb begin
        for (int i = 0; i < SLAVE_NUM; i++) begin
            m_araddr[i]  = '0;
            m_arprot[i]  = '0;
            m_arvalid[i] = '0;
            m_rready[i]  = '0;
        end
        case (rd_state)
            RD_ADDR: begin
                m_araddr[m_arindx_reg.indx]  = s_araddr[rd_grant_indx_reg];
                m_arprot[m_arindx_reg.indx]  = s_arprot[rd_grant_indx_reg];
                m_arvalid[m_arindx_reg.indx] = s_arvalid[rd_grant_indx_reg] & m_arindx_reg.valid;
            end
            RD_DATA: begin
                m_rready[m_arindx_reg.indx] = s_rready[rd_grant_indx_reg] & m_arindx_reg.valid;
            end
            default: ;
        endcase
    end

    always_comb begin
        for (int i = 0; i < MASTER_NUM; i++) begin
            s_awready[i] = '0;
            s_wready[i]  = '0;
            s_bresp[i]   = RESP_OKAY;
            s_bvalid[i]  = '0;
        end
        case (wr_state)
            WR_ADDR: begin
                if (m_awindx_reg.valid) begin
                    s_awready[wr_grant_indx_reg] = m_awready[m_awindx_reg.indx];
                    s_wready[wr_grant_indx_reg]  = m_wready[m_awindx_reg.indx];
                end else begin
                    s_awready[wr_grant_indx_reg] = 1'b1;
                end
            end
            WR_DATA: begin
                if (m_awindx_reg.valid) begin
                    s_wready[wr_grant_indx_reg] = m_wready[m_awindx_reg.indx];
                end else begin
                    s_wready[wr_grant_indx_reg] = 1'b1;
                end
            end
            WR_RESP: begin
                if (m_awindx_reg.valid) begin
                    s_bvalid[wr_grant_indx_reg] = m_bvalid[m_awindx_reg.indx];
                    s_bresp[wr_grant_indx_reg]  = m_bresp[m_awindx_reg.indx];
                end else begin
                    s_bvalid[wr_grant_indx_reg] = 1'b1;
                    s_bresp[wr_grant_indx_reg]  = RESP_DECERR;
                end
            end
            default: ;
        endcase
    end

    always_comb begin
        for (int i = 0; i < MASTER_NUM; i++) begin
            s_arready[i] = '0;
            s_rdata[i]   = '0;
            s_rresp[i]   = RESP_OKAY;
            s_rvalid[i]  = '0;
        end
        case (rd_state)
            RD_ADDR: begin
                if (m_arindx_reg.valid) begin
                    s_arready[rd_grant_indx_reg] = m_arready[m_arindx_reg.indx];
                end else begin
                    s_arready[rd_grant_indx_reg] = 1'b1;
                end
            end
            RD_DATA: begin
                if (m_arindx_reg.valid) begin
                    s_rvalid[rd_grant_indx_reg] = m_rvalid[m_arindx_reg.indx];
                    s_rresp[rd_grant_indx_reg]  = m_rresp[m_arindx_reg.indx];
                    s_rdata[rd_grant_indx_reg]  = m_rdata[m_arindx_reg.indx];
                end else begin
                    s_rvalid[rd_grant_indx_reg] = 1'b1;
                    s_rresp[rd_grant_indx_reg]  = RESP_DECERR;
                    s_rdata[rd_grant_indx_reg]  = '0;
                end
            end
            default: ;
        endcase
    end

endmodule
