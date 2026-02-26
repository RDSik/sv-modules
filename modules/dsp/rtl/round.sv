// Based on https://github.com/EttusResearch/fpga/blob/UHD-3.15.LTS/usrp2/sdr_lib/round.v

/* verilator lint_off TIMESCALEMOD */
module round #(
    parameter int CH_NUM   = 2,
    parameter int BITS_IN  = 0,
    parameter int BITS_OUT = 0
) (
    input logic clk_i,
    input logic rst_i,

    input logic round_to_zero,     // original behavior
    input logic round_to_nearest,  // lowest noise
    input logic trunc,             // round to negative infinity

    input logic [CH_NUM-1:0][BITS_IN-1:0] tdata_i,
    input logic                           tvalid_i,

    output logic [CH_NUM-1:0][BITS_OUT-1:0] tdata_o,
    output logic                            tvalid_o,

    output logic [CH_NUM-1:0][BITS_IN-BITS_OUT:0] err_o
);

    logic [CH_NUM-1:0][BITS_IN-BITS_OUT:0] err;
    logic [CH_NUM-1:0][      BITS_OUT-1:0] out;

    for (genvar i = 0; i < CH_NUM; i++) begin : g_ch
        logic [BITS-1:0] in;
        assign in = tdata_i[i];

        logic round_corr;
        logic round_corr_trunc;
        logic round_corr_rtz;
        logic round_corr_nearest;
        logic round_corr_nearest_safe;

        assign round_corr_trunc   = 0;
        assign round_corr_rtz     = (in[BITS_IN-1] & |in[BITS_IN-BITS_OUT-1:0]);
        assign round_corr_nearest = in[BITS_IN-BITS_OUT-1];

        if (BITS_IN - BITS_OUT > 1) begin : g_round
            assign  round_corr_nearest_safe = (~in[BITS_IN-1] & (&in[BITS_IN-2:BITS_OUT])) ? 0 :
                 round_corr_nearest;
        end else begin : g_equal
            assign round_corr_nearest_safe = round_corr_nearest;
        end

        assign round_corr = round_to_nearest ? round_corr_nearest_safe :
               trunc ? round_corr_trunc :
               round_to_zero ? round_corr_rtz :
               0;  // default to trunc

        assign out[i] = in[BITS_IN-1:BITS_IN-BITS_OUT] + round_corr;
        assign err[i] = in - {out[i], {(BITS_IN - BITS_OUT) {1'b0}}};
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            tvalid_o <= 1'b0;
        end else begin
            tvalid_o <= tvalid_i;
        end
        tdata_o <= out;
        err_o   <= err;
    end

endmodule
