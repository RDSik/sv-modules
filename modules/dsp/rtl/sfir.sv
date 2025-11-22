/* verilator lint_off TIMESCALEMOD */
module sfir #(
    parameter int CH_NUM     = 2,
    parameter int DATA_WIDTH = 16,
    parameter int COEF_WIDTH = 18,
    parameter int TAP_NUM    = 16,
    parameter     COE_FILE   = "fir.mem"
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic                                     tvalid_i,
    input logic signed [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                                                tvalid_o,
    output logic signed [CH_NUM-1:0][DATA_WIDTH+COEF_WIDTH-1:0] tdata_o
);

    localparam int DELAY = 3 * TAP_NUM + 3;

    logic tvalid_d;

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (DELAY - 1),
        .RESET_EN  (1),
        .SRL_STYLE ("srl")
    ) i_shift_reg (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .en_i  (en_i),
        .data_i(tvalid_i),
        .data_o(tvalid_d)
    );

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            tvalid_o <= 1'b0;
        end else begin
            if (en_i) begin
                tvalid_o <= tvalid_d;
            end else begin
                tvalid_o <= 1'b0;
            end
        end
    end

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        sfir_even_symmetric_systolic_top #(
            .DSIZE   (DATA_WIDTH),
            .CSIZE   (COEF_WIDTH),
            .NBTAP   (TAP_NUM),
            .COE_FILE(COE_FILE)
        ) i_sfir_even_symmetric_systolic_top (
            .clk   (clk_i),
            .datain(tdata_i[ch_indx]),
            .firout(tdata_o[ch_indx])
        );
    end

endmodule
