/* verilator lint_off TIMESCALEMOD */
module axil_reg_file_wrap #(
    parameter int   REG_DATA_WIDTH = 32,
    parameter int   REG_ADDR_WIDTH = 32,
    parameter int   REG_NUM        = 5,
    parameter type  reg_t          = logic          [REG_NUM-1:0][REG_DATA_WIDTH-1:0],
    parameter reg_t REG_INIT       = '{default: '0},
    parameter logic ILA_EN         = 0,
    parameter       MODE           = "sync"
) (
    input logic clk_i,

    input reg_t               rd_regs_i,
    input logic [REG_NUM-1:0] rd_valid_i,

    output logic [REG_NUM-1:0] rd_request_o,

    output reg_t               wr_regs_o,
    output logic [REG_NUM-1:0] wr_valid_o,

    axil_if.slave s_axil
);

    if (MODE == "async") begin : g_async_mode
        logic rstn_i;

        xpm_cdc_async_rst #(
            .DEST_SYNC_FF   (3),
            .INIT_SYNC_FF   (0),
            .RST_ACTIVE_HIGH(0)
        ) i_xpm_cdc_async_rst (
            .src_arst (s_axil.rstn_i),
            .dest_clk (clk_i),
            .dest_arst(rstn_i)
        );

        axil_if #(
            .ADDR_WIDTH(REG_ADDR_WIDTH),
            .DATA_WIDTH(REG_DATA_WIDTH)
        ) reg_axil (
            .clk_i (clk_i),
            .rstn_i(rstn_i)
        );

        axi_clock_converter i_axi_clock_converter (
            .s_axi_aclk   (s_axil.clk_i),
            .s_axi_aresetn(s_axil.rstn_i),
            .s_axi_awaddr (s_axil.awaddr),
            .s_axi_awprot (s_axil.awprot),
            .s_axi_awvalid(s_axil.awvalid),
            .s_axi_awready(s_axil.awready),
            .s_axi_wdata  (s_axil.wdata),
            .s_axi_wstrb  (s_axil.wstrb),
            .s_axi_wvalid (s_axil.wvalid),
            .s_axi_wready (s_axil.wready),
            .s_axi_bresp  (s_axil.bresp),
            .s_axi_bvalid (s_axil.bvalid),
            .s_axi_bready (s_axil.bready),
            .s_axi_araddr (s_axil.araddr),
            .s_axi_arprot (s_axil.arprot),
            .s_axi_arvalid(s_axil.arvalid),
            .s_axi_arready(s_axil.arready),
            .s_axi_rdata  (s_axil.rdata),
            .s_axi_rresp  (s_axil.rresp),
            .s_axi_rvalid (s_axil.rvalid),
            .s_axi_rready (s_axil.rready),
            .m_axi_aclk   (reg_axil.clk_i),
            .m_axi_aresetn(reg_axil.rstn_i),
            .m_axi_awaddr (reg_axil.awaddr),
            .m_axi_awprot (reg_axil.awprot),
            .m_axi_awvalid(reg_axil.awvalid),
            .m_axi_awready(reg_axil.awready),
            .m_axi_wdata  (reg_axil.wdata),
            .m_axi_wstrb  (reg_axil.wstrb),
            .m_axi_wvalid (reg_axil.wvalid),
            .m_axi_wready (reg_axil.wready),
            .m_axi_bresp  (reg_axil.bresp),
            .m_axi_bvalid (reg_axil.bvalid),
            .m_axi_bready (reg_axil.bready),
            .m_axi_araddr (reg_axil.araddr),
            .m_axi_arprot (reg_axil.arprot),
            .m_axi_arvalid(reg_axil.arvalid),
            .m_axi_arready(reg_axil.arready),
            .m_axi_rdata  (reg_axil.rdata),
            .m_axi_rresp  (reg_axil.rresp),
            .m_axi_rvalid (reg_axil.rvalid),
            .m_axi_rready (reg_axil.rready)
        );

        axil_reg_file #(
            .REG_DATA_WIDTH(REG_DATA_WIDTH),
            .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
            .REG_NUM       (REG_NUM),
            .reg_t         (reg_t),
            .REG_INIT      (REG_INIT),
            .ILA_EN        (ILA_EN)
        ) i_axil_reg_file (
            .s_axil      (reg_axil),
            .rd_regs_i   (rd_regs_i),
            .rd_valid_i  (rd_valid_i),
            .wr_regs_o   (wr_regs_o),
            .rd_request_o(rd_request_o),
            .wr_valid_o  (wr_valid_o)
        );
    end else if (MODE == "sync") begin : g_sync_mode
        axil_reg_file #(
            .REG_DATA_WIDTH(REG_DATA_WIDTH),
            .REG_ADDR_WIDTH(REG_ADDR_WIDTH),
            .REG_NUM       (REG_NUM),
            .reg_t         (reg_t),
            .REG_INIT      (REG_INIT),
            .ILA_EN        (ILA_EN)
        ) i_axil_reg_file (
            .s_axil      (s_axil),
            .rd_regs_i   (rd_regs_i),
            .rd_valid_i  (rd_valid_i),
            .wr_regs_o   (wr_regs_o),
            .rd_request_o(rd_request_o),
            .wr_valid_o  (wr_valid_o)
        );
    end else begin : g_mode_err
        $error("Only sync or async MODE is available!");
    end

endmodule
