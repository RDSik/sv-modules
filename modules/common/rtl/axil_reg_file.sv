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

    logic wr_handshake;
    logic write_valid;

    assign wr_handshake = write_valid & s_axil.awready & s_axil.wready;
    assign write_valid  = s_axil.awvalid & s_axil.wvalid;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                wr_reg[reg_indx]   <= REG_INIT_UNPACK[reg_indx];
                wr_valid[reg_indx] <= 1'b0;
            end
        end else begin
            if (wr_handshake) begin
                for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                    if (s_axil.awaddr[ADDR_MSB:ADDR_LSB] == reg_indx) begin
                        for (int i = 0; i < s_axil.STRB_WIDTH; i++) begin
                            if (s_axil.wstrb[i]) begin
                                wr_reg[reg_indx][i*8+:8] <= s_axil.wdata[i*8+:8];
                            end
                        end
                        wr_valid[reg_indx] <= 1'b1;
                    end else begin
                        wr_valid[reg_indx] <= 1'b0;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.awready <= 1'b0;
        end else begin
            if (write_valid & ~s_axil.awready) begin
                s_axil.awready <= 1'b1;
            end else begin
                s_axil.awready <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.wready <= 1'b0;
        end else begin
            if (write_valid & ~s_axil.wready) begin
                s_axil.wready <= 1'b1;
            end else begin
                s_axil.wready <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.bvalid <= '0;
            s_axil.bresp  <= '0;
        end else begin
            if (wr_handshake) begin
                s_axil.bvalid <= '1;
                s_axil.bresp  <= '0;
            end else if (s_axil.bvalid & s_axil.bready) begin
                s_axil.bvalid <= '0;
            end
        end
    end

    logic ar_handshake;

    assign ar_handshake = s_axil.arvalid & s_axil.arready;

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
        if (ar_handshake) begin
            for (int reg_indx = 0; reg_indx < REG_NUM; reg_indx++) begin
                if (s_axil.araddr[ADDR_MSB:ADDR_LSB] == reg_indx) begin
                    s_axil.rdata <= rd_reg[reg_indx];
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.arready <= 1'b0;
        end else begin
            if (s_axil.arvalid & ~s_axil.arready) begin
                s_axil.arready <= 1'b1;
            end else begin
                s_axil.arready <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_axil.rvalid <= 1'b0;
        end else begin
            if (ar_handshake) begin
                s_axil.rvalid <= 1'b1;
            end else if (s_axil.rvalid & s_axil.rready) begin
                s_axil.rvalid <= 1'b0;
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
