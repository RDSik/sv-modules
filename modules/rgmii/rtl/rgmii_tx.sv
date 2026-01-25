module rgmii_tx #(
    parameter int GMII_WIDTH  = 8,
    parameter int RGMII_WIDTH = 4,
    parameter     VENDOR      = "xilinx"
) (
    input logic clk_i,

    input logic                  gmii_tx_en_i,
    input logic [GMII_WIDTH-1:0] gmii_txd_i,

    output logic                   rgmii_tx_ctl_o,
    output logic [RGMII_WIDTH-1:0] rgmii_txd_o
);

    oddr #(
        .VENDOR(VENDOR)
    ) i_oddr (
        .q_o  (rgmii_tx_ctl_o),
        .clk_i(clk_i),
        .d1_i (gmii_tx_en_i),
        .d2_i (gmii_tx_en_i)
    );

    for (genvar i = 0; i < RGMII_WIDTH; i++) begin : g_txdata
        oddr #(
            .VENDOR(VENDOR)
        ) i_oddr (
            .q_o  (rgmii_txd_o[i]),
            .clk_i(clk_i),
            .d1_i (gmii_txd_i[i]),
            .d2_i (gmii_txd_i[RGMII_WIDTH+i])
        );
    end

endmodule
