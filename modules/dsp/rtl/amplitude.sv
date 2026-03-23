module amplitude #(
    parameter int CH_NUM     = 2,
    parameter int DATA_WIDTH = 16
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

    localparam int MULT_DELAY = 4;
    localparam int MULT_DATA_WIDTH = 2 * DATA_WIDTH + 1;

    logic [CH_NUM-1:0][MULT_DATA_WIDTH-1:0] mult_tdata;
    logic                                   mult_tvalid;

    for (genvar i = 0; i < CH_NUM; i++) begin : g_ch
        mult_signed #(
            .AWIDTH(DATA_WIDTH),
            .BWIDTH(DATA_WIDTH)
        ) i_mult_signed (
            .clk(clk_i),
            .a  (ampl_i),
            .b  (tdata_i[i]),
            .p  (mult_tdata[i])
        );
    end

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (MULT_DELAY),
        .RESET_EN  (1),
        .SRL_STYLE ("register")
    ) i_shift_reg (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .en_i  (1'b1),
        .data_i(tvalid_i),
        .data_o(mult_tvalid)
    );

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
        .tvalid_i(mult_tvalid),
        .tdata_o (sat_tdata),
        .tvalid_o(sat_tvalid),
        .ovf_o   (ovf_o)
    );

    round #(
        .CH_NUM        (CH_NUM),
        .DATA_WIDTH_IN (SAT_DATA_WIDTH),
        .DATA_WIDTH_OUT(DATA_WIDTH)
    ) i_round (
        .clk_i       (clk_i),
        .rst_i       (rst_i),
        .round_type_i(round_type_i),
        .tvalid_i    (sat_tvalid),
        .tdata_i     (sat_tdata),
        .tvalid_o    (tvalid_o),
        .tdata_o     (tdata_o)
    );

endmodule
