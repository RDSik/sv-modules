module axi_mem (
    axi_if.slave s_axi
);

    localparam int MEM_WIDTH = s_axi.DATA_WIDTH;
    localparam int MEM_DEPTH = 8192;
    localparam MEM_MODE = "write_first";
    localparam RAM_STYLE = "block";

    logic                         bram_rst_a;
    logic                         bram_clk_a;
    logic                         bram_en_a;
    logic [      MEM_WIDTH/8-1:0] bram_we_a;
    logic [$clog2(MEM_DEPTH)-1:0] bram_addr_a;
    logic [        MEM_WIDTH-1:0] bram_wrdata_a;
    logic [        MEM_WIDTH-1:0] bram_rddata_a;

    logic                         bram_rst_b;
    logic                         bram_clk_b;
    logic                         bram_en_b;
    logic [      MEM_WIDTH/8-1:0] bram_we_b;
    logic [$clog2(MEM_DEPTH)-1:0] bram_addr_b;
    logic [        MEM_WIDTH-1:0] bram_wrdata_b;
    logic [        MEM_WIDTH-1:0] bram_rddata_b;

    axi_bram_ctrl_0 i_axi_bram_ctrl_0 (
        .s_axi_aclk   (s_axi.clk_i),
        .s_axi_aresetn(s_axi.arstn_i),

        .s_axi_awaddr (s_axi.awaddr),
        .s_axi_awlen  (s_axi.awlen),
        .s_axi_awsize (s_axi.awsize),
        .s_axi_awburst(s_axi.awburst),
        .s_axi_awlock (s_axi.awlock),
        .s_axi_awcache(s_axi.awcache),
        .s_axi_awprot (s_axi.awprot),
        .s_axi_awvalid(s_axi.awvalid),
        .s_axi_awready(s_axi.awready),

        .s_axi_wdata (s_axi.wdata),
        .s_axi_wstrb (s_axi.wstrb),
        .s_axi_wlast (s_axi.wlast),
        .s_axi_wvalid(s_axi.wvalid),
        .s_axi_wready(s_axi.wready),
        .s_axi_bresp (s_axi.bresp),
        .s_axi_bvalid(s_axi.bvalid),
        .s_axi_bready(s_axi.bready),

        .s_axi_araddr (s_axi.araddr),
        .s_axi_arlen  (s_axi.arlen),
        .s_axi_arsize (s_axi.arsize),
        .s_axi_arburst(s_axi.arburst),
        .s_axi_arlock (s_axi.arlock),
        .s_axi_arcache(s_axi.arcache),
        .s_axi_arprot (s_axi.arprot),
        .s_axi_arvalid(s_axi.arvalid),
        .s_axi_arready(s_axi.arready),

        .s_axi_rdata (s_axi.rdata),
        .s_axi_rresp (s_axi.rresp),
        .s_axi_rlast (s_axi.rlast),
        .s_axi_rvalid(s_axi.rvalid),
        .s_axi_rready(s_axi.rready),

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
        .MEM_DEPTH (MEM_DEPTH),
        .BYTE_WIDTH(8),
        .BYTE_NUM  (MEM_WIDTH / 8),
        .RAM_STYLE (RAM_STYLE),
        .MEM_MODE  (MEM_MODE)
    ) i_ram_tdp (
        .a_clk_i  (bram_clk_a),
        .a_rst_i  (bram_rst_a),
        .a_en_i   (bram_en_a),
        .a_wr_en_i(bram_we_a),
        .a_addr_i (bram_addr_a),
        .a_data_i (bram_wrdata_a),
        .a_data_o (bram_rddata_a),

        .b_clk_i  (bram_clk_b),
        .b_rst_i  (bram_rst_b),
        .b_en_i   (bram_en_b),
        .b_wr_en_i(bram_we_b),
        .b_addr_i (bram_addr_b),
        .b_data_i (bram_wrdata_b),
        .b_data_o (bram_rddata_b)
    );

endmodule
