module iddr #(
    parameter VENDOR = "xilinx"
) (
    input logic clk_i,

    input logic d_i,

    output logic q1_o,
    output logic q2_o
);

    if (VENDOR == "xilinx") begin : g_xilinx
        IDDR #(
            .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"),  // "OPPOSITE_EDGE", "SAME_EDGE"
            //    or "SAME_EDGE_PIPELINED"
            .INIT_Q1     (1'b0),                   // Initial value of Q1: 1'b0 or 1'b1
            .INIT_Q2     (1'b0),                   // Initial value of Q2: 1'b0 or 1'b1
            .SRTYPE      ("SYNC")                  // Set/Reset type: "SYNC" or "ASYNC"
        ) i_iddr (
            .Q1(q1_o),   // 1-bit output for positive edge of clock
            .Q2(q2_o),   // 1-bit output for negative edge of clock
            .C (clk_i),  // 1-bit clock input
            .CE(1'b1),   // 1-bit clock enable input
            .D (d_i),    // 1-bit DDR data input
            .R (1'b0),   // 1-bit reset
            .S (1'b0)    // 1-bit set
        );
    end else if (VENDOR == "altera") begin : g_altera
        logic q1_int;
        logic q2_int;
        logic q1_delay;
        logic q2_delay;

        altddio_in #(
            .WIDTH        (1),
            .POWER_UP_HIGH("OFF")
        ) i_altddio_in (
            .aset     (1'b0),
            .datain   (d_i),
            .inclocken(1'b1),
            .inclock  (clk_i),
            .aclr     (1'b0),
            .dataout_h(q1_int),
            .dataout_l(q2_int)
        );

        always_ff @(posedge clk_i) begin
            q1_delay <= q1_int;
            q2_delay <= q2_int;
        end

        assign q1_o = q1_delay;
        assign q2_o = q2_delay;
    end else if (VENDOR == "gowin") begin : g_gowin
        logic q1_int;
        logic q2_int;
        logic q1_delay;
        logic q2_delay;

        IDDR i_iddr (
            .Q0 (q1_int),
            .Q1 (q2_int),
            .D  (d_i),
            .CLK(clk_i)
        );
        defparam i_iddr.Q0_INIT = 1'b0; defparam i_iddr.Q1_INIT = 1'b0;

        always_ff @(posedge clk_i) begin
            q1_delay <= q1_int;
            q2_delay <= q2_int;
        end

        assign q1_o = q1_delay;
        assign q2_o = q2_delay;
    end else begin : g_other
        logic d_reg_1 = 1'b0;
        logic d_reg_2 = 1'b0;
        logic q_reg_1 = 1'b0;
        logic q_reg_2 = 1'b0;

        always @(posedge clk_i) begin
            d_reg_1 <= d_i;
        end

        always @(negedge clk_i) begin
            d_reg_2 <= d_i;
        end

        always @(posedge clk_i) begin
            q_reg_1 <= d_reg_1;
            q_reg_2 <= d_reg_2;
        end

        assign q1_o = q_reg_1;
        assign q2_o = q_reg_2;
    end

endmodule
