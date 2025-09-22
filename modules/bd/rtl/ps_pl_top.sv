/* verilator lint_off TIMESCALEMOD */
module ps_pl_top #(
    parameter int   FIFO_DEPTH      = 128,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   AXIS_DATA_WIDTH = 8,
    parameter int   MODULES_NUM     = 2,
    parameter logic ILA_EN          = 1
) (
    input  logic clk_i,
    input  logic uart_rx_i,
    output logic uart_tx_o,

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

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) axil[MODULES_NUM-1:0] (
        .clk_i (ps_clk),
        .rstn_i(ps_arstn)
    );

    axil_uart #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
        .ILA_EN         (ILA_EN)
    ) i_axil_uart (
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o),
        .s_axil   (axil[0])
    );

    zynq_bd zynq_bd_i (
        .M00_AXI_0_araddr    (axil[0].araddr),
        .M00_AXI_0_arprot    (),
        .M00_AXI_0_arready   (axil[0].arready),
        .M00_AXI_0_arvalid   (axil[0].arvalid),
        .M00_AXI_0_awaddr    (axil[0].awaddr),
        .M00_AXI_0_awprot    (),
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
        .M01_AXI_0_arprot    (),
        .M01_AXI_0_arready   (axil[1].arready),
        .M01_AXI_0_arvalid   (axil[1].arvalid),
        .M01_AXI_0_awaddr    (axil[1].awaddr),
        .M01_AXI_0_awprot    (),
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
