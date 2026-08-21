module amplitude #(
    parameter logic ROUND_TYPE = 1
    parameter int CH_NUM       = 2,
    parameter int DATA_WIDTH   = 16
) (
    input logic clk_i,
    input logic rst_i,

    input logic round_type_i,

    input logic [DATA_WIDTH-1:0] ampl_i,

    input logic [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_i,
    input logic                              tvalid_i,

    output logic [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_o,
    output logic                              tvalid_o,

    output logic ovf_o
);

    localparam int MULT_DATA_WIDTH = 2 * DATA_WIDTH + 1;

    logic [CH_NUM-1:0][MULT_DATA_WIDTH-1:0] mult_tdata;
    logic [CH_NUM-1:0]                      mult_tvalid;

    for (genvar i = 0; i < CH_NUM; i++) begin : g_ch
        mult_signed #(
            .A_DATA_WIDTH(DATA_WIDTH),
            .B_DATA_WIDTH(DATA_WIDTH)
        ) i_mult_signed (
            .clk_i    (clk_i),
            .rst_i    (rst_i),
            .tvalid_o (mult_tvalid[i]),
            .tdata_o  (mult_tdata[i]),
            .tvalid_i (tvalid_i),
            .a_tdata_i(tdata_i[i]),
            .b_tdata_i(ampl_i)
        );
    end

    localparam int RADIX = DATA_WIDTH - 2;
    localparam int SAT_DATA_WIDTH = DATA_WIDTH + RADIX;

    logic [CH_NUM-1:0][SAT_DATA_WIDTH-1:0] sat_tdata;
    logic                                  sat_tvalid;

    saturate #(
        .CH_NUM        (CH_NUM),
        .DATA_WIDTH_IN (MULT_DATA_WIDTH),
        .DATA_WIDTH_OUT(SAT_DATA_WIDTH)
    ) i_saturate (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .tdata_i (mult_tdata),
        .tvalid_i(mult_tvalid[0]),
        .tdata_o (sat_tdata),
        .tvalid_o(sat_tvalid),
        .ovf_o   (ovf_o)
    );

    round #(
        .CH_NUM        (CH_NUM),
        .IN_DATA_WIDTH (SAT_DATA_WIDTH),
        .OUT_DATA_WIDTH(DATA_WIDTH),
        .ROUND_TYPE    (ROUND_TYPE),
        .USE_DSP       ("no")
    ) i_round (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .tvalid_i(sat_tvalid),
        .tdata_i (sat_tdata),
        .tvalid_o(tvalid_o),
        .tdata_o (tdata_o)
    );

endmodule
