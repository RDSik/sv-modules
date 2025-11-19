// Based on https://github.com/ZipCPU/wb2axip/blob/53dafe2d54e7a72304afe36e73875a940a351b70/bench/formal/xlnxdemo.v#L309-L314

/* verilator lint_off TIMESCALEMOD */
module axil_reg_file #(
    parameter int   REG_DATA_WIDTH = 32,
    parameter int   REG_ADDR_WIDTH = 32,
    parameter int   REG_NUM        = 5,
    parameter type  reg_t          = logic          [REG_NUM-1:0][REG_DATA_WIDTH-1:0],
    parameter reg_t REG_INIT       = '{default: '0},
    parameter logic ILA_EN         = 0
) (
    input reg_t               rd_regs_i,
    input logic [REG_NUM-1:0] rd_valid_i,

    output logic [REG_NUM-1:0] rd_request_o,

    output reg_t               wr_regs_o,
    output logic [REG_NUM-1:0] wr_valid_o,

    axil_if.slave s_axil
);

    typedef logic [REG_DATA_WIDTH-1:0] reg_unpack_t[REG_NUM-1:0];

    localparam int ADDR_LSB = REG_DATA_WIDTH / 32 + 1;
    localparam int ADDR_MSB = ADDR_LSB + $clog2(REG_NUM);

    localparam reg_unpack_t REG_INIT_UNPACK = reg_unpack_t'(REG_INIT);

    logic [REG_DATA_WIDTH-1:0] wr_reg       [REG_NUM-1:0];
    logic [REG_DATA_WIDTH-1:0] rd_reg       [REG_NUM-1:0];
    logic [REG_DATA_WIDTH-1:0] rd_reg_unpack[REG_NUM-1:0];

    logic                      clk_i;
    logic                      rstn_i;
    logic [       REG_NUM-1:0] wr_valid;
    logic [       REG_NUM-1:0] rd_valid;

    assign clk_i  = s_axil.clk_i;
    assign rstn_i = s_axil.rstn_i;

    always_ff @(posedge clk_i) begin
        wr_regs_o     <= reg_t'(wr_reg);
        wr_valid_o    <= wr_valid;
        rd_reg_unpack <= reg_unpack_t'(rd_regs_i);
        rd_valid      <= rd_valid_i;
    end

    logic [REG_ADDR_WIDTH-1:0] awaddr;
    logic [REG_ADDR_WIDTH-1:0] araddr;
    logic [REG_DATA_WIDTH-1:0] reg_data_out;
    logic                      slv_reg_wren;
    logic                      slv_reg_rden;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.awready <= '0;
            awaddr         <= '0;
        end else begin
            if (s_axil.awvalid & s_axil.wvalid & ~s_axil.awready) begin
                s_axil.awready <= 1'b1;
                awaddr         <= s_axil.awaddr;
            end else begin
                s_axil.awready <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.wready <= 1'b0;
        end else begin
            if (s_axil.awvalid & s_axil.wvalid & ~s_axil.wready) begin
                s_axil.wready <= 1'b1;
            end else begin
                s_axil.wready <= 1'b0;
            end
        end
    end

    assign slv_reg_wren = s_axil.awvalid & s_axil.wvalid & s_axil.awready & s_axil.wready;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            wr_valid <= '0;
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                wr_reg[reg_indx] <= REG_INIT_UNPACK[reg_indx];
            end
        end else begin
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                if (slv_reg_wren) begin
                    if (awaddr[ADDR_MSB:ADDR_LSB] == reg_indx) begin
                        for (int i = 0; i < REG_DATA_WIDTH / 8; i++) begin
                            if (s_axil.wstrb[i]) begin
                                wr_reg[reg_indx][i*8+:8] <= s_axil.wdata[i*8+:8];
                            end
                        end
                        wr_valid[reg_indx] <= 1'b1;
                    end
                end else begin
                    wr_valid[reg_indx] <= 1'b0;
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.bvalid <= 1'b0;
            s_axil.bresp  <= 2'b0;
        end else begin
            if (slv_reg_wren & ~s_axil.bvalid) begin
                s_axil.bvalid <= 1'b1;
                s_axil.bresp  <= 2'b0;
            end else if (s_axil.bready & s_axil.bvalid) begin
                s_axil.bvalid <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.arready <= '0;
            araddr         <= '0;
        end else begin
            if (s_axil.arvalid & ~s_axil.arready) begin
                s_axil.arready <= 1'b1;
                araddr         <= s_axil.araddr;
            end else begin
                s_axil.arready <= 1'b0;
            end
        end
    end

    assign slv_reg_rden = s_axil.arvalid & s_axil.arready & ~s_axil.rvalid;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.rvalid <= 1'b0;
            s_axil.rresp  <= 2'b0;
        end else begin
            if (slv_reg_rden) begin
                s_axil.rvalid <= 1'b1;
                s_axil.rresp  <= 2'b0;
            end else if (s_axil.rvalid & s_axil.rready) begin
                s_axil.rvalid <= 1'b0;
            end
        end
    end

    always_comb begin
        reg_data_out = '0;
        for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
            if (araddr[ADDR_MSB:ADDR_LSB] == reg_indx) begin
                reg_data_out = rd_reg[reg_indx];
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.rdata <= '0;
        end else if (slv_reg_rden) begin
            s_axil.rdata <= reg_data_out;
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                rd_reg[reg_indx] <= REG_INIT_UNPACK[reg_indx];
            end
        end else begin
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                if (rd_valid[reg_indx]) begin
                    rd_reg[reg_indx] <= rd_reg_unpack[reg_indx];
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            rd_request_o <= '0;
        end else begin
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                if (slv_reg_rden) begin
                    if (araddr[ADDR_MSB:ADDR_LSB] == reg_indx) begin
                        rd_request_o[reg_indx] <= 1'b1;
                    end
                end else begin
                    rd_request_o[reg_indx] <= 1'b0;
                end
            end
        end
    end

    if (ILA_EN) begin : g_ila
        axil_ila i_axil_ila (
            .clk    (clk_i),
            .probe0 (s_axil.awvalid),
            .probe1 (s_axil.awaddr),
            .probe2 (s_axil.bresp),
            .probe3 (s_axil.bvalid),
            .probe4 (s_axil.bready),
            .probe5 (s_axil.wdata),
            .probe6 (s_axil.wvalid),
            .probe7 (s_axil.wready),
            .probe8 (s_axil.awready),
            .probe9 (s_axil.rready),
            .probe10(s_axil.araddr),
            .probe11(s_axil.arvalid),
            .probe12(s_axil.arready),
            .probe13(s_axil.rresp),
            .probe14(s_axil.rdata),
            .probe15(s_axil.wstrb),
            .probe16(s_axil.rvalid),
            .probe17(s_axil.arprot),
            .probe18(s_axil.awprot)
        );
    end

endmodule
