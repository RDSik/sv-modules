`timescale 1ns / 1ps

module axis_join_rr_arb_tb ();

    localparam int MASTER_NUM = 4;
    localparam int DATA_WIDTH = 16;
    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                                  clk_i;
    logic                                  rstn_i;
    logic [MASTER_NUM-1:0]                 en_i;
    logic [MASTER_NUM-1:0][DATA_WIDTH-1:0] seed_i;
    logic [MASTER_NUM-1:0][DATA_WIDTH-1:0] poly_i;
    int                                    delay;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) arb_s_axis (
        .clk_i (clk_i),
        .rstn_i(s_rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) lfsr_s_axis[MASTER_NUM-1:0] (
        .clk_i (clk_i),
        .rstn_i(s_rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH)
    ) lfsr_m_axis[MASTER_NUM-1:0] (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    initial begin
        rstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        rstn_i = 1'b1;
        $display("Reset done in: %0t ns\n.", $time());
    end

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER_NS / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        en_i = '0;
        for (int i = 0; i < MASTER_NUM; i++) begin
            seed_i[i] = $urandom_range(1, (2 ** DATA_WIDTH) - 1);
            poly_i[i] = $urandom_range(1, (2 ** DATA_WIDTH) - 1);
            en_i[i]   = 1'b1;
            #100;
        end
        #1000;
    end

    initial begin
        $dumpfile("axis_join_rr_arb_tb.vcd");
        $dumpvars(0, axis_join_rr_arb_tb);
    end

    axis_join_rr_arb #(
        .MASTER_NUM(MASTER_NUM)
    ) i_axis_join_rr_arb (
        .s_axis(lfsr_m_axis),
        .m_axis(arb_s_axis)
    );

    for (genvar i = 0; i < MASTER_NUM; i++) begin : g_lfsr
        axis_lfsr #(
            .CRC_MODE_EN(0),
            .DATA_WIDTH (DATA_WIDTH)
        ) i_axis_lfsr (
            .en    (en_i[i]),
            .seed_i(seed_i[i]),
            .poly_i(poly_i[i]),
            .m_axis(lfsr_m_axis[i]),
            .s_axis(lfsr_s_axis[i])
        );
    end

endmodule
