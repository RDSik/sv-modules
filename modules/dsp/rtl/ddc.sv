/* verilator lint_off TIMESCALEMOD */
module ddc #(
    parameter     COE_FILE    = "fir.mem",
    parameter int IQ_NUM      = 2,
    parameter int DATA_WIDTH  = 16,
    parameter int COEF_WIDTH  = 18,
    parameter int PHASE_WIDTH = 14,
    parameter int TAP_NUM     = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic round_type_i,

    input logic [DATA_WIDTH-1:0] decimation_i,

    input logic [PHASE_WIDTH-1:0] phase_inc_i,
    input logic [PHASE_WIDTH-1:0] phase_offset_i,

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                              tvalid_o,
    output logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    logic [IQ_NUM-1:0][DATA_WIDTH-1:0] mixed_tdata;
    logic                              mixed_tvalid;

    mixer #(
        .IQ_NUM     (IQ_NUM),
        .DATA_WIDTH (DATA_WIDTH),
        .PHASE_WIDTH(PHASE_WIDTH),
        .DDS_IP_EN  (0)
    ) i_mixed_round (
        .clk_i         (clk_i),
        .rst_i         (rst_i),
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
        .clk_i(clk_i),
        .rst_i(rst_i)
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
        .COE_FILE        (COE_FILE)
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
