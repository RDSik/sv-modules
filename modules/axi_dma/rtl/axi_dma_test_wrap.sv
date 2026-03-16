module axi_dma_test_wrap (
    axil_if.slave s_axil,

    output logic s2mm_introut_o,
    output logic mm2s_introut_o
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

    axi_dma_test i_axi_dma_test (
        .BRAM_PORTA_0_addr   (bram_addr_a),
        .BRAM_PORTA_0_clk    (bram_clk_a),
        .BRAM_PORTA_0_din    (bram_wrdata_a),
        .BRAM_PORTA_0_dout   (bram_rddata_a),
        .BRAM_PORTA_0_en     (bram_en_a),
        .BRAM_PORTA_0_rst    (bram_rst_a),
        .BRAM_PORTA_0_we     (bram_we_a),
        .BRAM_PORTB_0_addr   (bram_addr_b),
        .BRAM_PORTB_0_clk    (bram_clk_b),
        .BRAM_PORTB_0_din    (bram_wrdata_b),
        .BRAM_PORTB_0_dout   (bram_rddata_b),
        .BRAM_PORTB_0_en     (bram_en_b),
        .BRAM_PORTB_0_rst    (bram_rst_b),
        .BRAM_PORTB_0_we     (bram_we_b),
        .S_AXI_LITE_0_araddr (s_axil.araddr),
        .S_AXI_LITE_0_arready(s_axil.arready),
        .S_AXI_LITE_0_arvalid(s_axil.arvalid),
        .S_AXI_LITE_0_awaddr (s_axil.awaddr),
        .S_AXI_LITE_0_awready(s_axil.awready),
        .S_AXI_LITE_0_awvalid(s_axil.awvalid),
        .S_AXI_LITE_0_bready (s_axil.bready),
        .S_AXI_LITE_0_bresp  (s_axil.bresp),
        .S_AXI_LITE_0_bvalid (s_axil.bvalid),
        .S_AXI_LITE_0_rdata  (s_axil.rdata),
        .S_AXI_LITE_0_rready (s_axil.rready),
        .S_AXI_LITE_0_rresp  (s_axil.rresp),
        .S_AXI_LITE_0_rvalid (s_axil.rvalid),
        .S_AXI_LITE_0_wdata  (s_axil.wdata),
        .S_AXI_LITE_0_wready (s_axil.wready),
        .S_AXI_LITE_0_wvalid (s_axil.wvalid),
        .clk                 (s_axil.clk_i),
        .resetn              (s_axil.arstn_i),
        .mm2s_introut_0      (mm2s_introut_o),
        .s2mm_introut_0      (s2mm_introut_o)
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
