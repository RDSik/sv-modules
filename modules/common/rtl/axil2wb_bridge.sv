/* verilator lint_off TIMESCALEMOD */
module axil2wb_bridge (
    axil_if.slave s_axil,
    wb_if.master  m_wb
);

    localparam logic [1:0] AXIL_OKAY = 2'b00;
    localparam logic [1:0] AXIL_SLVERR = 2'b10;

    logic clk_i;
    logic rstn_i;
    logic ar_handshake;
    logic wr_handshake;
    logic write_valid;
    logic write;
    logic read;

    assign clk_i        = s_axil.clk_i;
    assign rstn_i       = s_axil.rstn_i;
    assign write_valid  = s_axil.awvalid & s_axil.wvalid;
    assign wr_handshake = write_valid & s_axil.awready & s_axil.wready;
    assign ar_handshake = s_axil.arvalid & s_axil.arready;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            write <= 1'b0;
        end else begin
            if (write_valid) begin
                write <= 1'b1;
            end else if (s_axil.bvalid & s_axil.bready) begin
                write <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            read <= 1'b0;
        end else begin
            if (s_axil.arvalid) begin
                read <= 1'b1;
            end else if (s_axil.rvalid & s_axil.rready) begin
                read <= 1'b0;
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
            s_axil.bvalid <= 1'b0;
            s_axil.bresp  <= AXIL_OKAY;
        end else begin
            if (write) begin
                s_axil.bvalid <= m_wb.ack;
                if (m_wb.err) begin
                    s_axil.bresp <= AXIL_SLVERR;
                end else begin
                    s_axil.bresp <= AXIL_OKAY;
                end
            end else if (s_axil.bvalid & s_axil.bready) begin
                s_axil.bvalid <= 1'b0;
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
            s_axil.rresp  <= AXIL_OKAY;
        end else begin
            if (read) begin
                s_axil.rvalid <= m_wb.ack;
                s_axil.rdata  <= m_wb.rdat;
                if (m_wb.err) begin
                    s_axil.rresp <= AXIL_SLVERR;
                end else begin
                    s_axil.rresp <= AXIL_OKAY;
                end
            end else if (s_axil.rvalid & s_axil.rready) begin
                s_axil.rvalid <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_wb.adr  <= '0;
            m_wb.wdat <= '0;
            m_wb.sel  <= '0;
            m_wb.we   <= '0;
            m_wb.stb  <= '0;
            m_wb.cyc  <= '0;
        end else if (m_wb.ack & m_wb.stb & m_wb.cyc) begin
            m_wb.stb <= 1'b0;
            m_wb.cyc <= 1'b0;
        end else if (write_valid) begin
            m_wb.adr  <= s_axil.awaddr;
            m_wb.wdat <= s_axil.wdata;
            m_wb.sel  <= s_axil.wstrb;
            m_wb.we   <= 1'b1;
            m_wb.stb  <= 1'b1;
            m_wb.cyc  <= 1'b1;
        end else if (s_axil.arvalid) begin
            m_wb.adr <= s_axil.araddr;
            m_wb.we  <= 1'b0;
            m_wb.stb <= 1'b1;
            m_wb.cyc <= 1'b1;
        end
    end

endmodule
