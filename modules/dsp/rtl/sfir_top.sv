/* verilator lint_off TIMESCALEMOD */
module sfir_top #(
    parameter int TAP_NUM    = 28,
    parameter int DATA_WIDTH = 16,
    parameter int COEF_WIDTH = 16,
    parameter int IQ_NUM     = 2,
    // verilog_format: off
    parameter int COEF         [0:TAP_NUM-1] = '{
        560, 608, -120, -354, -34, 538, 40, -560,
        -250, 692, 412, -710, -704, 740, 1014,  -662,
        -1436, 514, 1936, -198, -2608, -354, 3572, 1438,
        -5354, -4176, 11198, 27938}
    // verilog_format: on
) (
    input logic clk_i,
    input logic rstn_i,
    input logic en_i,
    input logic odd_even_i, // 1 - round to odd, 0 - round to even

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                              tvalid_o,
    output logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    localparam int DELAY = TAP_NUM;

    shift_reg #(
        .RESET_EN  (1),
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (DELAY)
    ) i_shift_reg (
        .clk_i (clk_i),
        .rstn_i(rstn_i),
        .en_i  (en_i),
        .data_i(tvalid_i),
        .data_o(tvalid_o)
    );

    for (genvar iq_indx = 0; iq_indx < IQ_NUM; iq_indx++) begin : g_fir
        localparam int PRODUCT_WIDTH = COEF_WIDTH + DATA_WIDTH;

        logic [PRODUCT_WIDTH-1:0] fir_out;

        sfir_even_symmetric_systolic_top #(
            .TAP_NUM      (TAP_NUM),
            .DATA_WIDTH   (DATA_WIDTH),
            .COEF_WIDTH   (COEF_WIDTH),
            .COEF         (COEF),
            .PRODUCT_WIDTH(PRODUCT_WIDTH)
        ) i_sfir_i (
            .clk_i (clk_i),
            .data_i(tdata_i[iq_indx]),
            .fir_o (fir_out)
        );

        round #(
            .DATA_WIDTH_IN (PRODUCT_WIDTH),
            .DATA_WIDTH_OUT(DATA_WIDTH)
        ) i_round_i (
            .clk_i       (clk_i),
            .odd_even_i  (odd_even_i),
            .data_i      (fir_out),
            .round_data_o(tdata_o[iq_indx])
        );
    end

endmodule
