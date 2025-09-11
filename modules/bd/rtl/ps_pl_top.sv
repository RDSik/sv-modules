/* verilator lint_off TIMESCALEMOD */
module ps_pl_top #(
    parameter int   FIFO_DEPTH      = 128,
    parameter int   APB_ADDR_WIDTH  = 32,
    parameter int   APB_DATA_WIDTH  = 32,
    parameter int   AXIS_DATA_WIDTH = 8,
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

    apb_if #(
        .ADDR_WIDTH(APB_ADDR_WIDTH),
        .DATA_WIDTH(APB_DATA_WIDTH)
    ) apb (
        .clk_i (ps_clk),
        .rstn_i(ps_arstn)
    );

    apb_uart #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
        .APB_DATA_WIDTH (APB_DATA_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH),
        .ILA_EN         (ILA_EN)
    ) i_apb_uart (
        .uart_rx_i(uart_rx_i),
        .uart_tx_o(uart_tx_o),
        .s_apb    (apb)
    );

    zynq_bd zynq_bd_i (
        .APB_M_0_paddr       (apb.paddr),
        .APB_M_0_penable     (apb.penable),
        .APB_M_0_prdata      (apb.prdata),
        .APB_M_0_pready      (apb.pready),
        .APB_M_0_psel        (apb.psel),
        .APB_M_0_pslverr     (apb.pslverr),
        .APB_M_0_pwdata      (apb.pwdata),
        .APB_M_0_pwrite      (apb.pwrite),
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
