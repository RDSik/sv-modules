/* verilator lint_off TIMESCALEMOD */
module axil_ram #(
    parameter int MEM_DEPTH = 128,
    parameter     RAM_STYLE = "block",
    parameter     MEM_MODE  = "no_change",
    parameter     MEM_FILE  = ""
) (
    axil_if.slave s_axil
);

    localparam int BYTE_WIDTH = 8;
    localparam int BYTE_NUM = s_axil.STRB_WIDTH;
    localparam int ADDR_WIDTH = s_axil.ADDR_WIDTH;
    localparam int ADDR_LSB = (BYTE_WIDTH * BYTE_NUM) / 32 + 1;
    localparam int ADDR_MSB = ADDR_LSB + $clog2(MEM_DEPTH);

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_axil.clk_i;
    assign rstn_i = s_axil.arstn_i;

    logic [ADDR_WIDTH-1:0] awaddr;
    logic [ADDR_WIDTH-1:0] araddr;
    logic                  slv_reg_wren;
    logic                  slv_reg_rden;

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

    ram_sdp #(
        .MEM_DEPTH   (MEM_DEPTH),
        .BYTE_WIDTH  (BYTE_WIDTH),
        .BYTE_NUM    (BYTE_NUM),
        .READ_LATENCY(1),
        .MEM_MODE    (MEM_MODE),
        .RAM_STYLE   (RAM_STYLE)
    ) i_ram_sdp (
        .a_clk_i  (clk_i),
        .a_en_i   (slv_reg_wren),
        .a_wr_en_i(s_axil.wstrb),
        .a_addr_i (awaddr[ADDR_MSB:ADDR_LSB]),
        .a_data_i (s_axil.wdata),
        .b_clk_i  (clk_i),
        .b_en_i   (slv_reg_rden),
        .b_addr_i (araddr[ADDR_MSB:ADDR_LSB]),
        .b_data_o (s_axil.rdata)
    );

endmodule
