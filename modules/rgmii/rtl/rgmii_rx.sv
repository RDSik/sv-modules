module rgmii_rx #(
    parameter int GMII_WIDTH  = 8,
    parameter int RGMII_WIDTH = 4
) (
    input logic clk_i,

    input logic                   rgmii_rx_ctl_i,
    input logic [RGMII_WIDTH-1:0] rgmii_rxd_i,

    output logic                  gmii_rx_en_o,
    output logic [GMII_WIDTH-1:0] gmii_rxd_o
);

    logic [1:0] gmii_rxdv_w;

    assign gmii_rx_en_o = gmii_rxdv_w[1] & gmii_rxdv_w[0];

    IDDR #(
        .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),  // "OPPOSITE_EDGE", "SAME_EDGE"
                                               //    or "SAME_EDGE_PIPELINED"
        .INIT_Q1     (1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
        .INIT_Q2     (1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
        .SRTYPE      ("SYNC")                  // Set/Reset type: "SYNC" or "ASYNC"
    ) u_iddr_rx_ctl (
        .Q1(gmii_rxdv_w[0]),  // 1-bit output for positive edge of clock
        .Q2(gmii_rxdv_w[1]),  // 1-bit output for negative edge of clock
        .C (clk_i),           // 1-bit clock input
        .CE(1'b1),            // 1-bit clock enable input
        .D (rgmii_rx_ctl_i),  // 1-bit DDR data input
        .R (1'b0),            // 1-bit reset
        .S (1'b0)             // 1-bit set
    );

    for (genvar i = 0; i < RGMII_WIDTH; i++) begin : g_rxdata
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),  // "OPPOSITE_EDGE", "SAME_EDGE"
                                                   //    or "SAME_EDGE_PIPELINED"
            .INIT_Q1     (1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
            .INIT_Q2     (1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
            .SRTYPE      ("SYNC")                  // Set/Reset type: "SYNC" or "ASYNC"
        ) u_iddr_rxd (
            .Q1(gmii_rxd_o[i]),              // 1-bit output for positive edge of clock
            .Q2(gmii_rxd_o[RGMII_WIDTH+i]),  // 1-bit output for negative edge of clock
            .C (clk_i),                      // 1-bit clock input clk_i_bufio
            .CE(1'b1),                       // 1-bit clock enable input
            .D (rgmii_rxd_i[i]),             // 1-bit DDR data input
            .R (1'b0),                       // 1-bit reset
            .S (1'b0)                        // 1-bit set
        );
    end

endmodule
