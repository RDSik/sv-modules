/* verilator lint_off TIMESCALEMOD */
module ddc #(
    parameter int IQ_NUM        = 2,
    parameter int DATA_WIDTH    = 16,
    parameter int COEF_WIDTH    = 18,
    parameter int SIN_LUT_DEPTH = 8192,
    parameter int TAP_NUM       = 28,
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

    input logic round_type_i,

    input logic [DATA_WIDTH-1:0] decimation_i,

    input logic [$clog2(SIN_LUT_DEPTH)-1:0] phase_inc_i,
    input logic [$clog2(SIN_LUT_DEPTH)-1:0] phase_offset_i,

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                              tvalid_o,
    output logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    logic [IQ_NUM-1:0][DATA_WIDTH-1:0] mixed_tdata;
    logic                              mixed_tvalid;

    mixer #(
        .IQ_NUM       (IQ_NUM),
        .DATA_WIDTH   (DATA_WIDTH),
        .SIN_LUT_DEPTH(SIN_LUT_DEPTH)
    ) i_mixed_round (
        .clk_i         (clk_i),
        .rstn_i        (rstn_i),
        .en_i          (en_i),
        .round_type_i  (round_type_i),
        .phase_inc_i   (phase_inc_i),
        .phase_offset_i(phase_offset_i),
        .tvalid_i      (tvalid_i),
        .tdata_i       (tdata_i),
        .tvalid_o      (mixed_tvalid),
        .tdata_o       (mixed_tdata)
    );

    axis_if #(
        .DATA_WIDTH(IQ_NUM * DATA_WIDTH)
    ) s_axis (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    assign s_axis.tdata  = mixed_tdata;
    assign s_axis.tvalid = mixed_tvalid;

    resampler #(
        .INTERPOLATION_EN(0),
        .DECIMATION_EN   (1),
        .CH_NUM          (IQ_NUM),
        .DATA_WIDTH      (DATA_WIDTH),
        .COEF_WIDTH      (COEF_WIDTH),
        .TAP_NUM         (TAP_NUM),
        .COEF            (COEF)
    ) i_resampler (
        .s_axis         (s_axis),
        .interpolation_i('0),
        .decimation_i   (decimation_i),
        .round_type_i   (round_type_i),
        .en_i           (en_i),
        .tvalid_o       (tvalid_o),
        .tdata_o        (tdata_o)
    );

endmodule
