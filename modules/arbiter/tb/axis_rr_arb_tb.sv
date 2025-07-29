`timescale 1ns / 1ps

module axis_rr_arb_tb ();

    localparam int MASTER_NUM = 4;
    localparam int DATA_WIDTH = 16;
    localparam int USER_WIDTH = $clog2(MASTER_NUM);
    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                                  clk_i;
    logic                                  rstn_i;
    logic [MASTER_NUM-1:0]                 en_i;
    logic [MASTER_NUM-1:0][DATA_WIDTH-1:0] seed_i;
    logic [MASTER_NUM-1:0][DATA_WIDTH-1:0] poly_i;

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    ) arb_s_axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    ) lfsr_s_axis[MASTER_NUM-1:0] (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    axis_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH)
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
        arb_s_axis.tready = '1;
        for (int i = 0; i < MASTER_NUM; i++) begin
            /* verilator lint_off WIDTHTRUNC */
            seed_i[i] = $urandom_range(1, (2 ** DATA_WIDTH) - 1);
            poly_i[i] = $urandom_range(1, (2 ** DATA_WIDTH) - 1);
            /* verilator lint_on WIDTHTRUNC */
        end
        for (int i = 0; i < MASTER_NUM; i++) begin
            #200;
            en_i[i] = 1'b1;
        end
        #200;
`ifdef VERILATOR
        $finish();
`else
        $stop();
`endif
    end

    initial begin
        $dumpfile("axis_rr_arb_tb.vcd");
        $dumpvars(0, axis_rr_arb_tb);
    end

    axis_rr_arb_wrap #(
        .MASTER_NUM(MASTER_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .USER_WIDTH(USER_WIDTH)
    ) dut (
        .s_axis(lfsr_m_axis),
        .m_axis(arb_s_axis)
    );

    for (genvar i = 0; i < MASTER_NUM; i++) begin : g_lfsr
        assign lfsr_s_axis[i].tvalid = 1'b1;

        axis_lfsr_wrap #(
            .DATA_WIDTH(DATA_WIDTH)
        ) i_axis_lfsr_wrap (
            .en_i  (en_i[i]),
            .poly_i(poly_i[i]),
            .seed_i(seed_i[i]),
            .s_axis(lfsr_s_axis[i]),
            .m_axis(lfsr_m_axis[i])
        );
    end

endmodule
