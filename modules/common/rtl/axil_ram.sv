/* verilator lint_off TIMESCALEMOD */
module axil_ram #(
    parameter int MEM_DEPTH  = 64,
    parameter int BYTE_WIDTH = 8,
    parameter int BYTE_NUM   = 4,
    parameter     MEM_MODE   = "no_change",
    parameter     MEM_FILE   = ""
) (
    axil_if.slave s_axil
);

    localparam int ADDR_LSB = (BYTE_WIDTH * BYTE_NUM) / 32 + 1;
    localparam int ADDR_MSB = ADDR_LSB + $clog2(MEM_DEPTH);

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_axil.clk_i;
    assign rstn_i = s_axil.rstn_i;

    logic wr_handshake;
    logic write_valid;

    assign wr_handshake = write_valid & s_axil.awready & s_axil.wready;
    assign write_valid  = s_axil.awvalid & s_axil.wvalid;

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
            s_axil.rvalid <= '0;
            s_axil.rresp  <= '0;
        end else begin
            if (ar_handshake) begin
                s_axil.rvalid <= '1;
                s_axil.rresp  <= '0;
            end else if (s_axil.rvalid & s_axil.rready) begin
                s_axil.rvalid <= '0;
            end
        end
    end

    ram_sdp #(
        .MEM_DEPTH   (MEM_DEPTH),
        .BYTE_WIDTH  (BYTE_WIDTH),
        .BYTE_NUM    (BYTE_NUM),
        .READ_LATENCY(0),
        .MEM_MODE    (MEM_MODE),
    ) i_ram_sdp (
        .a_clk_i  (clk_i),
        .a_en_i   (wr_handshake),
        .a_wr_en_i(s_axil.wstrb),
        .a_addr_i (s_axil.awaddr[ADDR_MSB:ADDR_LSB]),
        .a_data_i (s_axil.wdata),
        .b_clk_i  (clk_i),
        .b_en_i   (ar_handshake),
        .b_addr_i (s_axil.araddr[ADDR_MSB:ADDR_LSB]),
        .b_data_o (s_axil.rdata)
    );

endmodule
