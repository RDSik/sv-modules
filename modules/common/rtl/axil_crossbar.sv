/* verilator lint_off TIMESCALEMOD */
module axil_crossbar #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter int MASTER_NUM = 1,
    parameter int SLAVE_NUM = 3,
    parameter logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] SLAVE_LOW_ADDR = '{
        32'h43c0_0000,
        32'h43c1_0000,
        32'h43c2_0000
    },
    parameter logic [SLAVE_NUM-1:0][ADDR_WIDTH-1:0] SLAVE_HIGTH_ADDR = '{
        32'h43c0_ffff,
        32'h43c1_ffff,
        32'h43c2_ffff
    }
) (
    axil_if.slave  s_axil[MASTER_NUM-1:0],
    axil_if.master m_axil[ SLAVE_NUM-1:0]
);

    localparam int SEL_WIDTH = $clog2(SLAVE_NUM + 1);

    function automatic logic [SEL_WIDTH-1:0] get_index(input logic [ADDR_WIDTH-1:0] addr);
        begin
            get_index = SEL_WIDTH'(SLAVE_NUM);
            for (int i = 0; i < SLAVE_NUM; i++) begin
                if (addr >= SLAVE_LOW_ADDR[i] && addr <= SLAVE_HIGTH_ADDR[i]) begin
                    get_index = SEL_WIDTH'(i);
                end
            end
        end
    endfunction

    typedef enum logic [1:0] {
        IDLE  = 2'b00,
        WRITE = 2'b01,
        READ  = 2'b10
    } state_t;

    state_t state;

    logic   clk_i;
    logic   rstn_i;

    assign clk_i  = s_axil.clk_i;
    assign rstn_i = s_axil.rstn_i;

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
        assign s_wdata[i]        = s_axil[i].arb_wdata;
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

    logic [MASTER_NUM-1:0] req;
    logic [MASTER_NUM-1:0] grant;
    logic                  ack;

    always_comb begin
        for (int i = 0; i < MASTER_NUM; i++) begin
            req[i] = s_awvalid[i] | s_arvalid[i];
        end
    end

    round_robin_arbiter #(
        .MASTER_NUM(MASTER_NUM)
    ) i_round_robin_arbiter (
        .clk_i  (clk_i),
        .rst_i  (~rstn_i),
        .ack_i  (ack),
        .req_i  (req),
        .grant_o(grant)
    );

    logic [$clog2(MASTER_NUM)-1:0] grant_indx;
    logic [$clog2(MASTER_NUM)-1:0] grant_indx_reg;

    always_comb begin
        grant_indx = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            if (grant[i]) begin
                grant_indx = i;
                break;
            end
        end
    end

    logic [  ADDR_WIDTH-1:0] arb_awaddr;
    logic                    arb_awvalid;
    logic [  DATA_WIDTH-1:0] arb_wdata;
    logic [DATA_WIDTH/8-1:0] arb_wstrb;
    logic                    arb_wvalid;
    logic                    arb_bready;
    logic [  ADDR_WIDTH-1:0] arb_araddr;
    logic                    arb_arvalid;
    logic                    arb_rready;
    logic [             2:0] arb_arprot;
    logic [             2:0] arb_awprot;

    logic [   SEL_WIDTH-1:0] aw_m_indx;
    logic [   SEL_WIDTH-1:0] aw_m_indx_reg;
    logic [   SEL_WIDTH-1:0] ar_m_indx;
    logic [   SEL_WIDTH-1:0] ar_m_indx_reg;

    assign aw_m_indx = get_index(s_awaddr[grant_indx]);
    assign ar_m_indx = get_index(s_araddr[grant_indx]);

    always_comb begin
        m_awaddr[aw_m_indx_reg]  = arb_awaddr;
        m_awvalid[aw_m_indx_reg] = arb_awvalid;
        m_wdata[aw_m_indx_reg]   = arb_wdata;
        m_wstrb[aw_m_indx_reg]   = arb_wstrb;
        m_wvalid[aw_m_indx_reg]  = arb_wvalid;
        m_awprot[aw_m_indx_reg]  = arb_awprot;
        m_bready[aw_m_indx_reg]  = arb_bready;
        m_araddr[ar_m_indx_reg]  = arb_araddr;
        m_arvalid[ar_m_indx_reg] = arb_arvalid;
        m_rready[ar_m_indx_reg]  = arb_rready;
        m_arprot[ar_m_indx_reg]  = arb_arprot;
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (|grant) begin
                        grant_indx_reg <= grant_indx;
                        if (arb_awvalid) begin
                            s_awready[grant_indx] <= 1'b1;
                            arb_awvalid           <= 1'b1;
                            arb_awaddr            <= s_awaddr[grant_indx];
                            arb_awprot            <= s_awprot[grant_indx];
                            aw_m_indx_reg         <= aw_m_indx;

                            if (aw_m_indx == SLAVE_NUM) begin
                                state <= WRTIE_ERR;
                            end else begin
                                state <= WRTIE_DATA;
                            end
                        end else if (arb_arvalid) begin
                            s_arready[grant_indx] <= 1'b1;
                            arb_arvalid           <= 1'b1;
                            arb_araddr            <= s_araddr[grant_indx];
                            arb_arprot            <= s_arprot[grant_indx];
                            ar_m_indx_reg         <= ar_m_indx;

                            if (ar_m_indx == SLAVE_NUM) begin
                                state <= READ_ERR;
                            end else begin
                                state <= READ_DATA;
                            end
                        end
                    end
                end
                WRTIE_DATA: begin
                    if (m_awready[aw_m_indx_reg]) begin
                        arb_awvalid <= 1'b0;
                        if (s_wvalid[grant_indx_reg]) begin

                        end
                    end
                end
                READ_DATA: begin
                end
                default: state <= IDLE;
            endcase
        end
    end

endmodule
