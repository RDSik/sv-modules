module mixer #(
    parameter logic ROUND_TYPE = 1,
    parameter int  PHASE_WIDTH = 32,
    parameter int  DATA_WIDTH  = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic [PHASE_WIDTH-1:0] pinc_i,
    input logic [PHASE_WIDTH-1:0] poff_i,

    input logic                       tvalid_i,
    input logic [1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                       tvalid_o,
    output logic [1:0][DATA_WIDTH-1:0] tdata_o
);

    logic                       dds_tvalid;
    logic [1:0][DATA_WIDTH-1:0] dds_tdata;

    dds #(
        .PHASE_WIDTH(PHASE_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) i_dds (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .en_i    (en_i),
        .pinc_i  (pinc_i),
        .poff_i  (poff_i),
        .tdata_o (dds_tdata),
        .tvalid_o(dds_tvalid)
    );

    localparam int CMULT_DATA_WIDTH = 2 * DATA_WIDTH + 1;

    logic [1:0][CMULT_DATA_WIDTH-1:0] mixed_tdata;
    logic                             mixed_tvalid;

    cmult #(
        .A_DATA_WIDTH(DATA_WIDTH),
        .B_DATA_WIDTH(DATA_WIDTH)
    ) i_cmult (
        .clk_i    (clk_i),
        .rst_i    (rst_i),
        .tvalid_o (mixed_tvalid),
        .tdata_o  (mixed_tdata),
        .tvalid_i (tvalid_i),
        .a_tdata_i(tdata_i),
        .b_tdata_i(dds_tdata)
    );

    round #(
        .CH_NUM        (2),
        .IN_DATA_WIDTH (CMULT_DATA_WIDTH),
        .OUT_DATA_WIDTH(DATA_WIDTH),
        .ROUND_TYPE    (ROUND_TYPE),
        .USE_DSP       ("no")
    ) i_round (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .tvalid_i(mixed_tvalid & dds_tvalid),
        .tdata_i (mixed_tdata),
        .tvalid_o(tvalid_o),
        .tdata_o (tdata_o)
    );

endmodule
