module rgmii_rx #(
    parameter int GMII_WIDTH  = 8,
    parameter int RGMII_WIDTH = 4,
    parameter     VENDOR      = "xilinx"
) (
    input logic clk_i,

    input logic                   rgmii_rx_ctl_i,
    input logic [RGMII_WIDTH-1:0] rgmii_rxd_i,

    output logic                  gmii_rx_en_o,
    output logic [GMII_WIDTH-1:0] gmii_rxd_o
);

    logic [1:0] gmii_rxdv_w;

    assign gmii_rx_en_o = gmii_rxdv_w[1] & gmii_rxdv_w[0];

    iddr #(
        .VENDOR(VENDOR)
    ) i_iddr (
        .q1_o (gmii_rxdv_w[0]),
        .q2_o (gmii_rxdv_w[1]),
        .clk_i(clk_i),
        .d_i  (rgmii_rx_ctl_i)
    );

    for (genvar i = 0; i < RGMII_WIDTH; i++) begin : g_rxdata
        iddr #(
            .VENDOR(VENDOR)
        ) u_iddr (
            .q1_o (gmii_rxd_o[i]),
            .q2_o (gmii_rxd_o[RGMII_WIDTH+i]),
            .clk_i(clk_i),
            .d_i  (rgmii_rxd_i[i])
        );
    end

endmodule
