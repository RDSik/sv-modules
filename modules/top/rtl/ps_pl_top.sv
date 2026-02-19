/* verilator lint_off TIMESCALEMOD */
`include "top_pkg.svh"

module ps_pl_top
    import top_pkg::*;
(
    input logic clk_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    inout        eth_mdio_io,
    output logic eth_mdc_o,

    input logic                   eth_rx_clk_i,
    input logic [RGMII_WIDTH-1:0] eth_rxd_i,
    input logic                   eth_rx_ctl_i,

    output logic                   eth_tx_clk_o,
    output logic [RGMII_WIDTH-1:0] eth_txd_o,
    output logic                   eth_tx_ctl_o,

    input  logic                    spi_miso_i,
    output logic                    spi_mosi_o,
    output logic                    spi_clk_o,
    output logic [SPI_CS_WIDTH-1:0] spi_cs_o,

    inout i2c_scl_io,
    inout i2c_sda_io,

    inout [14:0] DDR_0_addr,
    inout [ 2:0] DDR_0_ba,
    inout        DDR_0_cas_n,
    inout        DDR_0_ck_n,
    inout        DDR_0_ck_p,
    inout        DDR_0_cke,
    inout        DDR_0_cs_n,
    inout [ 3:0] DDR_0_dm,
    inout [31:0] DDR_0_dq,
    inout [ 3:0] DDR_0_dqs_n,
    inout [ 3:0] DDR_0_dqs_p,
    inout        DDR_0_odt,
    inout        DDR_0_ras_n,
    inout        DDR_0_reset_n,
    inout        DDR_0_we_n,
    inout        FIXED_IO_0_ddr_vrn,
    inout        FIXED_IO_0_ddr_vrp,
    inout [53:0] FIXED_IO_0_mio,
    inout        FIXED_IO_0_ps_clk,
    inout        FIXED_IO_0_ps_porb,
    inout        FIXED_IO_0_ps_srstb
);

    logic ps_clk;
    logic ps_arstn;

    logic scl_pad_i;
    logic scl_pad_o;
    logic scl_padoen_o;

    logic sda_pad_i;
    logic sda_pad_o;
    logic sda_padoen_o;

    IOBUF i_scl_IOBUF (
        .O (scl_pad_i),
        .IO(i2c_scl_io),
        .I (scl_pad_o),
        .T (scl_padoen_o)
    );

    IOBUF i_sda_IOBUF (
        .O (sda_pad_i),
        .IO(i2c_sda_io),
        .I (sda_pad_o),
        .T (sda_padoen_o)
    );

    spi_if #(.CS_WIDTH(SPI_CS_WIDTH)) m_spi ();

    assign spi_cs_o   = m_spi.cs;
    assign spi_clk_o  = m_spi.clk;
    assign spi_mosi_o = m_spi.mosi;
    assign m_spi.miso = spi_miso_i;

    eth_if #(.DATA_WIDTH(RGMII_WIDTH)) m_eth ();

    IOBUF i_mdio_IOBUF (
        .O (m_eth.mdio_i),
        .IO(eth_mdio_io),
        .I (m_eth.mdio_o),
        .T (m_eth.mdio_oen)
    );

    assign m_eth.rx_clk = eth_rx_clk_i;
    assign m_eth.rxd    = eth_rxd_i;
    assign m_eth.rx_ctl = eth_rx_ctl_i;
    assign eth_txd_o    = m_eth.txd;
    assign eth_tx_ctl_o = m_eth.tx_ctl;
    assign eth_tx_clk_o = m_eth.tx_clk;
    assign eth_mdc_o    = m_eth.mdc;

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) m_axis_mm2s (
        .clk_i(ps_clk),
        .rst_i(~ps_arstn)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) s_axis_s2mm (
        .clk_i(ps_clk),
        .rst_i(~ps_arstn)
    );

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) axil[MASTER_NUM-1:0] (
        .clk_i  (ps_clk),
        .arstn_i(ps_arstn)
    );

    axil_top #(
        .CLK_FREQ       (CLK_FREQ),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SLAVE_LOW_ADDR (SLAVE_LOW_ADDR),
        .SLAVE_HIGH_ADDR(SLAVE_HIGH_ADDR),
        .SLAVE_NUM      (SLAVE_NUM),
        .SPI_CS_WIDTH   (SPI_CS_WIDTH),
        .RGMII_WIDTH    (RGMII_WIDTH),
        .ILA_EN         (ILA_EN),
        .MASTER_NUM     (MASTER_NUM),
        .MODE           ("async"),
        .VENDOR         ("xilinx")
    ) i_axil_top (
        .clk_i       (clk_i),
        .uart_rx_i   (uart_rx_i),
        .uart_tx_o   (uart_tx_o),
        .scl_pad_i   (scl_pad_i),
        .scl_pad_o   (scl_pad_o),
        .scl_padoen_o(scl_padoen_o),
        .sda_pad_i   (sda_pad_i),
        .sda_pad_o   (sda_pad_o),
        .sda_padoen_o(sda_padoen_o),
        .m_eth       (m_eth),
        .m_spi       (m_spi),
        .m_axis      (s_axis_s2mm),
        .s_axis      (m_axis_mm2s),
        .s_axil      (axil)
    );

    zynq_bd zynq_bd_i (
        .M01_AXI_0_araddr    (axil[0].araddr),
        .M01_AXI_0_arprot    (axil[0].arprot),
        .M01_AXI_0_arready   (axil[0].arready),
        .M01_AXI_0_arvalid   (axil[0].arvalid),
        .M01_AXI_0_awaddr    (axil[0].awaddr),
        .M01_AXI_0_awprot    (axil[0].awprot),
        .M01_AXI_0_awready   (axil[0].awready),
        .M01_AXI_0_awvalid   (axil[0].awvalid),
        .M01_AXI_0_bready    (axil[0].bready),
        .M01_AXI_0_bresp     (axil[0].bresp),
        .M01_AXI_0_bvalid    (axil[0].bvalid),
        .M01_AXI_0_rdata     (axil[0].rdata),
        .M01_AXI_0_rready    (axil[0].rready),
        .M01_AXI_0_rresp     (axil[0].rresp),
        .M01_AXI_0_rvalid    (axil[0].rvalid),
        .M01_AXI_0_wdata     (axil[0].wdata),
        .M01_AXI_0_wready    (axil[0].wready),
        .M01_AXI_0_wstrb     (axil[0].wstrb),
        .M01_AXI_0_wvalid    (axil[0].wvalid),
        .M_AXIS_0_tdata      (m_axis_mm2s.tdata),
        .M_AXIS_0_tkeep      (),
        .M_AXIS_0_tlast      (m_axis_mm2s.tlast),
        .M_AXIS_0_tready     (m_axis_mm2s.tready),
        .M_AXIS_0_tvalid     (m_axis_mm2s.tvalid),
        .S_AXIS_0_tdata      (s_axis_s2mm.tdata),
        .S_AXIS_0_tkeep      ('1),
        .S_AXIS_0_tlast      (s_axis_s2mm.tlast),
        .S_AXIS_0_tready     (s_axis_s2mm.tready),
        .S_AXIS_0_tvalid     (s_axis_s2mm.tvalid),
        .DDR_0_addr          (DDR_0_addr),
        .DDR_0_ba            (DDR_0_ba),
        .DDR_0_cas_n         (DDR_0_cas_n),
        .DDR_0_ck_n          (DDR_0_ck_n),
        .DDR_0_ck_p          (DDR_0_ck_p),
        .DDR_0_cke           (DDR_0_cke),
        .DDR_0_cs_n          (DDR_0_cs_n),
        .DDR_0_dm            (DDR_0_dm),
        .DDR_0_dq            (DDR_0_dq),
        .DDR_0_dqs_n         (DDR_0_dqs_n),
        .DDR_0_dqs_p         (DDR_0_dqs_p),
        .DDR_0_odt           (DDR_0_odt),
        .DDR_0_ras_n         (DDR_0_ras_n),
        .DDR_0_reset_n       (DDR_0_reset_n),
        .DDR_0_we_n          (DDR_0_we_n),
        .FCLK_CLK0_0         (ps_clk),
        .FIXED_IO_0_ddr_vrn  (FIXED_IO_0_ddr_vrn),
        .FIXED_IO_0_ddr_vrp  (FIXED_IO_0_ddr_vrp),
        .FIXED_IO_0_mio      (FIXED_IO_0_mio),
        .FIXED_IO_0_ps_clk   (FIXED_IO_0_ps_clk),
        .FIXED_IO_0_ps_porb  (FIXED_IO_0_ps_porb),
        .FIXED_IO_0_ps_srstb (FIXED_IO_0_ps_srstb),
        .peripheral_aresetn_0(ps_arstn)
    );

endmodule
