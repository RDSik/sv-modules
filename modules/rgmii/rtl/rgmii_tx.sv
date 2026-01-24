module rgmii_tx #(
    parameter int GMII_WIDTH  = 8,
    parameter int RGMII_WIDTH = 4
) (
    input logic clk_i,

    input logic                  gmii_tx_en_i,
    input logic [GMII_WIDTH-1:0] gmii_txd_i,

    output logic                   rgmii_tx_ctl_o,
    output logic [RGMII_WIDTH-1:0] rgmii_txd_o
);

    ODDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),  // "OPPOSITE_EDGE" or "SAME_EDGE"
                                               //    or "SAME_EDGE_PIPELINED"
        .INIT        (1'b0),                   // Initial value of Q: 1'b0 or 1'b1
        .SRTYPE      ("SYNC")                  // Set/Reset type: "SYNC" or "ASYNC"
    ) i_ODDR (
        .Q (rgmii_tx_ctl_o),  // 1-bit DDR output
        .C (clk_i),           // 1-bit clock input
        .CE(1'b1),            // 1-bit clock enable input
        .D1(gmii_tx_en_i),    // 1-bit data input (positive edge)
        .D2(gmii_tx_en_i),    // 1-bit data input (negative edge)
        .R (1'b0),            // 1-bit reset
        .S (1'b0)             // 1-bit set
    );

    for (genvar i = 0; i < RGMII_WIDTH; i++) begin : g_txdata
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),  // "OPPOSITE_EDGE" or "SAME_EDGE"
                                                   //    or "SAME_EDGE_PIPELINED"
            .INIT        (1'b0),                   // Initial value of Q: 1'b0 or 1'b1
            .SRTYPE      ("SYNC")                  // Set/Reset type: "SYNC" or "ASYNC"
        ) i_ODDR (
            .Q (rgmii_txd_o[i]),             // 1-bit DDR output
            .C (clk_i),                      // 1-bit clock input
            .CE(1'b1),                       // 1-bit clock enable input
            .D1(gmii_txd_i[i]),              // 1-bit data input (positive edge)
            .D2(gmii_txd_i[RGMII_WIDTH+i]),  // 1-bit data input (negative edge)
            .R (1'b0),                       // 1-bit reset
            .S (1'b0)                        // 1-bit set
        );
    end

endmodule
