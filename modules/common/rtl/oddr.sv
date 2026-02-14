module oddr #(
    parameter VENDOR = "xilinx"
) (
    input logic clk_i,

    input logic d1_i,
    input logic d2_i,

    output logic q_o
);

    if (VENDOR == "xilinx") begin : g_xilinx
        ODDR #(
            .DDR_CLK_EDGE("SAME_EDGE"),  // "OPPOSITE_EDGE" or "SAME_EDGE"
            //    or "SAME_EDGE_PIPELINED"
            .INIT        (1'b0),         // Initial value of Q: 1'b0 or 1'b1
            .SRTYPE      ("SYNC")        // Set/Reset type: "SYNC" or "ASYNC"
        ) i_oddr (
            .Q (q_o),    // 1-bit DDR output
            .C (clk_i),  // 1-bit clock input
            .CE(1'b1),   // 1-bit clock enable input
            .D1(d1_i),   // 1-bit data input (positive edge)
            .D2(d2_i),   // 1-bit data input (negative edge)
            .R (1'b0),   // 1-bit reset
            .S (1'b0)    // 1-bit set
        );
    end else if (VENDOR == "altera") begin : g_altera
        altddio_out #(
            .WIDTH        (1),
            .POWER_UP_HIGH("OFF"),
            .OE_logic     ("UNUSED")
        ) i_altddio_out (
            .aset      (1'b0),
            .datain_h  (d1_i),
            .datain_l  (d2_i),
            .outclocken(1'b1),
            .outclock  (clk_i),
            .aclr      (1'b0),
            .dataout   (q_o)
        );
    end else if (VENDOR == "gowin") begin : g_gowin
        ODDR #(
            .INIT(1'b0)
        ) i_oddr (
            .Q0 (q_o),
            .Q1 (),
            .D0 (d1_i),
            .D1 (d2_i),
            .TX (1'b0),
            .CLK(clk_i)
        );
    end else begin : g_otehr
        logic d_reg_1 = 1'b0;
        logic d_reg_2 = 1'b0;
        logic q_reg = 1'b0;

        always @(posedge clk_i) begin
            d_reg_1 <= d1_i;
            d_reg_2 <= d2_i;
        end

        always @(negedge clk_i) begin
            q_reg <= d_reg_2;
        end

        assign q_o = clk_i ? d_reg_1 : q_reg;
    end

endmodule
