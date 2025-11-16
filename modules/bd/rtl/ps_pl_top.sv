/* verilator lint_off TIMESCALEMOD */
module ps_pl_top #(
    parameter int   FIFO_DEPTH   = 128,
    parameter int   SPI_CS_WIDTH = 1,
    parameter logic ILA_EN       = 1,
    parameter       RAM_STYLE    = "distributed"
) (
    input logic clk_i,

    input  logic uart_rx_i,
    output logic uart_tx_o,

    input  logic                    spi_miso_i,
    output logic                    spi_mosi_o,
    output logic                    spi_cs_o,
    output logic [SPI_CS_WIDTH-1:0] spi_clk_o,

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

    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

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

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) axil[2:0] (
        .clk_i (ps_clk),
        .rstn_i(ps_arstn)
    );

    ctrl_top #(
        .UART_EN        (1),
        .SPI_EN         (1),
        .I2C_EN         (1),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .SPI_CS_WIDTH   (SPI_CS_WIDTH),
        .ILA_EN         (ILA_EN),
        .RAM_STYLE      (RAM_STYLE)
    ) i_ctrl_top (
        .clk_i       (clk_i),
        .uart_rx_i   (uart_rx_i),
        .uart_tx_o   (uart_tx_o),
        .scl_pad_i   (scl_pad_i),
        .scl_pad_o   (scl_pad_o),
        .scl_padoen_o(scl_padoen_o),
        .sda_pad_i   (sda_pad_i),
        .sda_pad_o   (sda_pad_o),
        .sda_padoen_o(sda_padoen_o),
        .m_spi       (m_spi),
        .s_axil      (axil)
    );

    zynq_bd zynq_bd_i (
        .M00_AXI_0_araddr    (axil[0].araddr),
        .M00_AXI_0_arprot    (axil[0].arprot),
        .M00_AXI_0_arready   (axil[0].arready),
        .M00_AXI_0_arvalid   (axil[0].arvalid),
        .M00_AXI_0_awaddr    (axil[0].awaddr),
        .M00_AXI_0_awprot    (axil[0].awprot),
        .M00_AXI_0_awready   (axil[0].awready),
        .M00_AXI_0_awvalid   (axil[0].awvalid),
        .M00_AXI_0_bready    (axil[0].bready),
        .M00_AXI_0_bresp     (axil[0].bresp),
        .M00_AXI_0_bvalid    (axil[0].bvalid),
        .M00_AXI_0_rdata     (axil[0].rdata),
        .M00_AXI_0_rready    (axil[0].rready),
        .M00_AXI_0_rresp     (axil[0].rresp),
        .M00_AXI_0_rvalid    (axil[0].rvalid),
        .M00_AXI_0_wdata     (axil[0].wdata),
        .M00_AXI_0_wready    (axil[0].wready),
        .M00_AXI_0_wstrb     (axil[0].wstrb),
        .M00_AXI_0_wvalid    (axil[0].wvalid),
        .M01_AXI_0_araddr    (axil[1].araddr),
        .M01_AXI_0_arprot    (axil[1].arprot),
        .M01_AXI_0_arready   (axil[1].arready),
        .M01_AXI_0_arvalid   (axil[1].arvalid),
        .M01_AXI_0_awaddr    (axil[1].awaddr),
        .M01_AXI_0_awprot    (axil[1].awprot),
        .M01_AXI_0_awready   (axil[1].awready),
        .M01_AXI_0_awvalid   (axil[1].awvalid),
        .M01_AXI_0_bready    (axil[1].bready),
        .M01_AXI_0_bresp     (axil[1].bresp),
        .M01_AXI_0_bvalid    (axil[1].bvalid),
        .M01_AXI_0_rdata     (axil[1].rdata),
        .M01_AXI_0_rready    (axil[1].rready),
        .M01_AXI_0_rresp     (axil[1].rresp),
        .M01_AXI_0_rvalid    (axil[1].rvalid),
        .M01_AXI_0_wdata     (axil[1].wdata),
        .M01_AXI_0_wready    (axil[1].wready),
        .M01_AXI_0_wstrb     (axil[1].wstrb),
        .M01_AXI_0_wvalid    (axil[1].wvalid),
        .M02_AXI_0_araddr    (axil[2].araddr),
        .M02_AXI_0_arprot    (axil[2].arprot),
        .M02_AXI_0_arready   (axil[2].arready),
        .M02_AXI_0_arvalid   (axil[2].arvalid),
        .M02_AXI_0_awaddr    (axil[2].awaddr),
        .M02_AXI_0_awprot    (axil[2].awprot),
        .M02_AXI_0_awready   (axil[2].awready),
        .M02_AXI_0_awvalid   (axil[2].awvalid),
        .M02_AXI_0_bready    (axil[2].bready),
        .M02_AXI_0_bresp     (axil[2].bresp),
        .M02_AXI_0_bvalid    (axil[2].bvalid),
        .M02_AXI_0_rdata     (axil[2].rdata),
        .M02_AXI_0_rready    (axil[2].rready),
        .M02_AXI_0_rresp     (axil[2].rresp),
        .M02_AXI_0_rvalid    (axil[2].rvalid),
        .M02_AXI_0_wdata     (axil[2].wdata),
        .M02_AXI_0_wready    (axil[2].wready),
        .M02_AXI_0_wstrb     (axil[2].wstrb),
        .M02_AXI_0_wvalid    (axil[2].wvalid),
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
