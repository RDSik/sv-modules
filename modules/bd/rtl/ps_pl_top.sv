/* verilator lint_off TIMESCALEMOD */
module ps_pl_top #(
    parameter int   FIFO_DEPTH      = 128,
    parameter int   APB_ADDR_WIDTH  = 32,
    parameter int   APB_DATA_WIDTH  = 32,
    parameter int   AXIS_DATA_WIDTH = 8,
    parameter logic ILA_EN          = 1
) (
    input  logic uart_rx_i,
    output logic uart_tx_o
);

    logic clk_i;
    logic rstn_i;

    apb_if #(
        .ADDR_WIDTH(APB_ADDR_WIDTH),
        .DATA_WIDTH(APB_DATA_WIDTH)
    ) apb (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
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

    zynq_bd_wrapper(
        .APB_M_0_paddr(apb.paddr),
        .APB_M_0_penable(apb.penable),
        .APB_M_0_prdata(apb.prdata),
        .APB_M_0_pready(apb.pready),
        .APB_M_0_psel(apb.psel),
        .APB_M_0_pslverr(apb.pslverr),
        .APB_M_0_pwdata(apb.pwdata),
        .APB_M_0_pwrite(apb.pwrite),
        .FCLK_CLK0_0(clk_i),
        .peripheral_aresetn_0(rstn_i)
    );

endmodule
