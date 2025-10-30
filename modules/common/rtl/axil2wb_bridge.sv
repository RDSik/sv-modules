/* verilator lint_off TIMESCALEMOD */
module axil2wb_bridge #(
    parameter int MODULE_NUM = 1
) (
    axil_if.slave s_axil[MODULE_NUM-1:0],
    wb_if.master  m_wb  [MODULE_NUM-1:0]
);

    localparam logic [1:0] AXIL_OKAY = 2'b00;
    localparam logic [1:0] AXIL_SLVERR = 2'b10;

    for (genvar mod_indx = 0; mod_indx < MODULE_NUM; mod_indx++) begin : g_axil2wb
        logic clk_i;
        logic rstn_i;
        logic ar_handshake;
        logic wr_handshake;
        logic write_valid;
        logic write;
        logic read;

        assign clk_i        = s_axil[mod_indx].clk_i;
        assign rstn_i       = s_axil[mod_indx].rstn_i;
        assign write_valid  = s_axil[mod_indx].awvalid & s_axil[mod_indx].wvalid;
        assign wr_handshake = write_valid & s_axil[mod_indx].awready & s_axil[mod_indx].wready;
        assign ar_handshake = s_axil[mod_indx].arvalid & s_axil[mod_indx].arready;

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                write <= 1'b0;
            end else begin
                if (write_valid) begin
                    write <= 1'b1;
                end else if (s_axil[mod_indx].bvalid & s_axil[mod_indx].bready) begin
                    write <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                read <= 1'b0;
            end else begin
                if (s_axil[mod_indx].arvalid) begin
                    read <= 1'b1;
                end else if (s_axil[mod_indx].rvalid & s_axil[mod_indx].rready) begin
                    read <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                s_axil[mod_indx].awready <= 1'b0;
            end else begin
                if (write_valid & ~s_axil[mod_indx].awready) begin
                    s_axil[mod_indx].awready <= 1'b1;
                end else begin
                    s_axil[mod_indx].awready <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                s_axil[mod_indx].wready <= 1'b0;
            end else begin
                if (write_valid & ~s_axil[mod_indx].wready) begin
                    s_axil[mod_indx].wready <= 1'b1;
                end else begin
                    s_axil[mod_indx].wready <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                s_axil[mod_indx].bvalid <= 1'b0;
                s_axil[mod_indx].bresp  <= AXIL_OKAY;
            end else begin
                if (write) begin
                    s_axil[mod_indx].bvalid <= m_wb[mod_indx].ack;
                    if (m_wb[mod_indx].err) begin
                        s_axil[mod_indx].bresp <= AXIL_SLVERR;
                    end else begin
                        s_axil[mod_indx].bresp <= AXIL_OKAY;
                    end
                end else if (s_axil[mod_indx].bvalid & s_axil[mod_indx].bready) begin
                    s_axil[mod_indx].bvalid <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                s_axil[mod_indx].arready <= 1'b0;
            end else begin
                if (s_axil[mod_indx].arvalid & ~s_axil[mod_indx].arready) begin
                    s_axil[mod_indx].arready <= 1'b1;
                end else begin
                    s_axil[mod_indx].arready <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                s_axil[mod_indx].rvalid <= 1'b0;
                s_axil[mod_indx].rresp  <= AXIL_OKAY;
            end else begin
                if (read) begin
                    s_axil[mod_indx].rvalid <= m_wb[mod_indx].ack;
                    s_axil[mod_indx].rdata  <= m_wb[mod_indx].rdat;
                    if (m_wb[mod_indx].err) begin
                        s_axil[mod_indx].rresp <= AXIL_SLVERR;
                    end else begin
                        s_axil[mod_indx].rresp <= AXIL_OKAY;
                    end
                end else if (s_axil[mod_indx].rvalid & s_axil[mod_indx].rready) begin
                    s_axil[mod_indx].rvalid <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                m_wb[mod_indx].adr  <= '0;
                m_wb[mod_indx].wdat <= '0;
                m_wb[mod_indx].sel  <= '0;
                m_wb[mod_indx].we   <= '0;
                m_wb[mod_indx].stb  <= '0;
                m_wb[mod_indx].cyc  <= '0;
            end else if (m_wb[mod_indx].ack & m_wb[mod_indx].stb & m_wb[mod_indx].cyc) begin
                m_wb[mod_indx].stb <= 1'b0;
                m_wb[mod_indx].cyc <= 1'b0;
            end else if (write_valid) begin
                m_wb[mod_indx].adr  <= s_axil[mod_indx].awaddr;
                m_wb[mod_indx].wdat <= s_axil[mod_indx].wdata;
                m_wb[mod_indx].sel  <= s_axil[mod_indx].wstrb;
                m_wb[mod_indx].we   <= 1'b1;
                m_wb[mod_indx].stb  <= 1'b1;
                m_wb[mod_indx].cyc  <= 1'b1;
            end else if (s_axil[mod_indx].arvalid) begin
                m_wb[mod_indx].adr <= s_axil[mod_indx].araddr;
                m_wb[mod_indx].we  <= 1'b0;
                m_wb[mod_indx].stb <= 1'b1;
                m_wb[mod_indx].cyc <= 1'b1;
            end
        end
    end

endmodule
