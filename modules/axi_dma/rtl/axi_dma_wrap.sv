module axi_dma_wrap (
    axil_if.slave s_axil,

    axis_if.slave  s_axis_s2mm,
    axis_if.master m_axis_mm2s,

    output logic s2mm_introut_o,
    output logic mm2s_introut_o
);

    axi_if #(
        .ADDR_WIDTH(s_axil.ADDR_WIDTH),
        .DATA_WIDTH(s_axil.DATA_WIDTH)
    ) axi (
        .clk_i  (s_axil.clk_i),
        .arstn_i(s_axil.arstn_i)
    );

    axi_dma_sim i_axi_dma_sim (
        .s_axi_lite_aclk       (s_axil.clk_i),
        .m_axi_mm2s_aclk       (s_axil.clk_i),
        .m_axi_s2mm_aclk       (s_axil.clk_i),
        .axi_resetn            (s_axil.arstn_i),
        .s_axi_lite_awvalid    (s_axil.awvalid),
        .s_axi_lite_awready    (s_axil.awready),
        .s_axi_lite_awaddr     (s_axil.awaddr),
        .s_axi_lite_wvalid     (s_axil.wvalid),
        .s_axi_lite_wready     (s_axil.wready),
        .s_axi_lite_wdata      (s_axil.wdata),
        .s_axi_lite_bresp      (s_axil.bresp),
        .s_axi_lite_bvalid     (s_axil.bvalid),
        .s_axi_lite_bready     (s_axil.bready),
        .s_axi_lite_arvalid    (s_axil.arvalid),
        .s_axi_lite_arready    (s_axil.arready),
        .s_axi_lite_araddr     (s_axil.araddr),
        .s_axi_lite_rvalid     (s_axil.rvalid),
        .s_axi_lite_rready     (s_axil.rready),
        .s_axi_lite_rdata      (s_axil.rdata),
        .s_axi_lite_rresp      (s_axil.rresp),
        .m_axi_mm2s_araddr     (axi.araddr),
        .m_axi_mm2s_arlen      (axi.arlen),
        .m_axi_mm2s_arsize     (axi.arsize),
        .m_axi_mm2s_arburst    (axi.arburst),
        .m_axi_mm2s_arprot     (axi.arprot),
        .m_axi_mm2s_arcache    (axi.arcache),
        .m_axi_mm2s_arvalid    (axi.arvalid),
        .m_axi_mm2s_arready    (axi.arready),
        .m_axi_mm2s_rdata      (axi.rdata),
        .m_axi_mm2s_rresp      (axi.rresp),
        .m_axi_mm2s_rlast      (axi.rlast),
        .m_axi_mm2s_rvalid     (axi.rvalid),
        .m_axi_mm2s_rready     (axi.rready),
        .mm2s_prmry_reset_out_n(),
        .m_axis_mm2s_tdata     (m_axis_mm2s.tdata),
        .m_axis_mm2s_tkeep     (m_axis_mm2s.tkeep),
        .m_axis_mm2s_tvalid    (m_axis_mm2s.tvalid),
        .m_axis_mm2s_tready    (m_axis_mm2s.tready),
        .m_axis_mm2s_tlast     (m_axis_mm2s.tlast),
        .m_axi_s2mm_awaddr     (axi.awaddr),
        .m_axi_s2mm_awlen      (axi.awlen),
        .m_axi_s2mm_awsize     (axi.awsize),
        .m_axi_s2mm_awburst    (axi.awburst),
        .m_axi_s2mm_awprot     (axi.awprot),
        .m_axi_s2mm_awcache    (axi.awcache),
        .m_axi_s2mm_awvalid    (axi.awvalid),
        .m_axi_s2mm_awready    (axi.awready),
        .m_axi_s2mm_wdata      (axi.wdata),
        .m_axi_s2mm_wstrb      (axi.wstrb),
        .m_axi_s2mm_wlast      (axi.wlast),
        .m_axi_s2mm_wvalid     (axi.wvalid),
        .m_axi_s2mm_wready     (axi.wready),
        .m_axi_s2mm_bresp      (axi.bresp),
        .m_axi_s2mm_bvalid     (axi.bvalid),
        .m_axi_s2mm_bready     (axi.bready),
        .s2mm_prmry_reset_out_n(),
        .s_axis_s2mm_tdata     (s_axis_s2mm.tdata),
        .s_axis_s2mm_tkeep     (s_axis_s2mm.tkeep),
        .s_axis_s2mm_tvalid    (s_axis_s2mm.tvalid),
        .s_axis_s2mm_tready    (s_axis_s2mm.tready),
        .s_axis_s2mm_tlast     (s_axis_s2mm.tlast),
        .mm2s_introut          (mm2s_introut_o),
        .s2mm_introut          (s2mm_introut_o),
        .axi_dma_tstvec        ()
    );

    localparam READ_LATENCY = 1;
    localparam MEM_DEPTH = 8192;
    localparam MEM_WIDTH = s_axil.DATA_WIDTH;
    localparam BYTE_NUM = s_axil.STRB_WIDTH;

    logic                         bram_rst_a;
    logic                         bram_clk_a;
    logic                         bram_en_a;
    logic [         BYTE_NUM-1:0] bram_we_a;
    logic [$clog2(MEM_DEPTH)-1:0] bram_addr_a;
    logic [        MEM_WIDTH-1:0] bram_wrdata_a;
    logic [        MEM_WIDTH-1:0] bram_rddata_a;

    logic                         bram_rst_b;
    logic                         bram_clk_b;
    logic                         bram_en_b;
    logic [         BYTE_NUM-1:0] bram_we_b;
    logic [$clog2(MEM_DEPTH)-1:0] bram_addr_b;
    logic [        MEM_WIDTH-1:0] bram_wrdata_b;
    logic [        MEM_WIDTH-1:0] bram_rddata_b;

    axi_bram_ctrl_sim i_axi_bram_ctrl_sim (
        .s_axi_aclk   (axi.clk_i),
        .s_axi_aresetn(axi.arstn_i),
        .s_axi_awaddr (axi.awaddr),
        .s_axi_awlen  (axi.awlen),
        .s_axi_awsize (axi.awsize),
        .s_axi_awburst(axi.awburst),
        .s_axi_awlock (axi.awlock),
        .s_axi_awcache(axi.awcache),
        .s_axi_awprot (axi.awprot),
        .s_axi_awvalid(axi.awvalid),
        .s_axi_awready(axi.awready),
        .s_axi_wdata  (axi.wdata),
        .s_axi_wstrb  (axi.wstrb),
        .s_axi_wlast  (axi.wlast),
        .s_axi_wvalid (axi.wvalid),
        .s_axi_wready (axi.wready),
        .s_axi_bresp  (axi.bresp),
        .s_axi_bvalid (axi.bvalid),
        .s_axi_bready (axi.bready),
        .s_axi_araddr (axi.araddr),
        .s_axi_arlen  (axi.arlen),
        .s_axi_arsize (axi.arsize),
        .s_axi_arburst(axi.arburst),
        .s_axi_arlock (axi.arlock),
        .s_axi_arcache(axi.arcache),
        .s_axi_arprot (axi.arprot),
        .s_axi_arvalid(axi.arvalid),
        .s_axi_arready(axi.arready),
        .s_axi_rdata  (axi.rdata),
        .s_axi_rresp  (axi.rresp),
        .s_axi_rlast  (axi.rlast),
        .s_axi_rvalid (axi.rvalid),
        .s_axi_rready (axi.rready),
        .bram_rst_a   (bram_rst_a),
        .bram_clk_a   (bram_clk_a),
        .bram_en_a    (bram_en_a),
        .bram_we_a    (bram_we_a),
        .bram_addr_a  (bram_addr_a),
        .bram_wrdata_a(bram_wrdata_a),
        .bram_rddata_a(bram_rddata_a),
        .bram_rst_b   (bram_rst_b),
        .bram_clk_b   (bram_clk_b),
        .bram_en_b    (bram_en_b),
        .bram_we_b    (bram_we_b),
        .bram_addr_b  (bram_addr_b),
        .bram_wrdata_b(bram_wrdata_b),
        .bram_rddata_b(bram_rddata_b)
    );

    ram_tdp #(
        .READ_LATENCY(READ_LATENCY),
        .BYTE_NUM    (BYTE_NUM),
        .MEM_DEPTH   (MEM_DEPTH),
        .MEM_WIDTH   (MEM_WIDTH),
        .MEM_MODE    ("no_change"),
        .RAM_STYLE   ("block"),
        .BYTE_WIDTH  (8)
    ) i_ram_tdp (
        .a_clk_i  (bram_clk_a),
        .a_en_i   (bram_en_a),
        .a_wr_en_i(bram_we_a),
        .a_addr_i (bram_addr_a),
        .a_data_i (bram_wrdata_a),
        .a_data_o (bram_rddata_a),
        .b_clk_i  (bram_clk_b),
        .b_en_i   (bram_en_b),
        .b_wr_en_i(bram_we_b),
        .b_addr_i (bram_addr_b),
        .b_data_i (bram_wrdata_b),
        .b_data_o (bram_rddata_b)
    );

endmodule
