module mixer #(
    parameter int CH_NUM      = 2,
    parameter int PHASE_WIDTH = 32,
    parameter int DATA_WIDTH  = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic round_type_i,

    input logic [PHASE_WIDTH-1:0] pinc_i,
    input logic [PHASE_WIDTH-1:0] poff_i,

    input logic                              tvalid_i,
    input logic [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                              tvalid_o,
    output logic [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    logic                              dds_tvalid;
    logic [CH_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;

    dds #(
        .IQ_NUM     (CH_NUM),
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

    localparam int CMULT_DELAY = 6;
    localparam int CMULT_DATA_WIDTH = 2 * DATA_WIDTH + 1;

    logic [CH_NUM-1:0][CMULT_DATA_WIDTH-1:0] mixed_tdata;
    logic                                    mixed_tvalid;

    cmult #(
        .AWIDTH(DATA_WIDTH),
        .BWIDTH(DATA_WIDTH)
    ) i_cmult (
        .clk(clk_i),
        .ar (tdata_i[0]),
        .ai (tdata_i[1]),
        .br (dds_tdata[0]),
        .bi (dds_tdata[1]),
        .pr (mixed_tdata[0]),
        .pi (mixed_tdata[1])
    );

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (CMULT_DELAY),
        .RESET_EN  (1),
        .SRL_STYLE ("register")
    ) i_shift_reg (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .en_i  (en_i),
        .data_i(tvalid_i),
        .data_o(mixed_tvalid)
    );

    round #(
        .CH_NUM        (CH_NUM),
        .DATA_WIDTH_IN (CMULT_DATA_WIDTH),
        .DATA_WIDTH_OUT(DATA_WIDTH)
    ) i_round (
        .clk_i       (clk_i),
        .rst_i       (rst_i),
        .round_type_i(round_type_i),
        .tvalid_i    (mixed_tvalid & dds_tvalid),
        .tdata_i     (mixed_tdata),
        .tvalid_o    (tvalid_o),
        .tdata_o     (tdata_o)
    );

endmodule
