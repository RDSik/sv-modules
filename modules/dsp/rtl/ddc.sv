/* verilator lint_off TIMESCALEMOD */
module ddc #(
    parameter int IQ_NUM      = 2,
    parameter int DATA_WIDTH  = 16,
    parameter int COEF_WIDTH  = 16,
    parameter int PHASE_WIDTH = 16,
    parameter int TAP_NUM     = 28,
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
        .PHASE_WIDTH(PHASE_WIDTH)
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

    logic [IQ_NUM-1:0][DATA_WIDTH+COEF_WIDTH-1:0] fir_tdata;
    logic                                         fir_tvalid;

    fir_filter #(
        .CH_NUM    (IQ_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH),
        .TAP_NUM   (TAP_NUM),
        .COEF      (COEF)
    ) i_fir_filter (
        .clk_i   (clk_i),
        .rstn_i  (rstn_i),
        .en_i    (en_i),
        .tvalid_i(mixed_tvalid),
        .tdata_i (mixed_tdata),
        .tvalid_o(fir_tvalid),
        .tdata_o (fir_tdata)
    );

    logic [$clog2(DATA_WIDTH)-1:0] dec_cnt;
    logic                          dec_cnt_done;
    logic                          fir_dec_tvalid;

    assign dec_cnt_done   = (dec_cnt == decimation_i - 1);
    assign fir_dec_tvalid = fir_tvalid && (dec_cnt == '0);

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            dec_cnt <= '0;
        end else if (en_i) begin
            if (fir_tvalid) begin
                if (dec_cnt_done) begin
                    dec_cnt <= '0;
                end else begin
                    dec_cnt <= dec_cnt + 1'b1;
                end
            end
        end
    end

    round #(
        .CH_NUM        (IQ_NUM),
        .DATA_WIDTH_IN (DATA_WIDTH + COEF_WIDTH),
        .DATA_WIDTH_OUT(DATA_WIDTH)
    ) i_fir_round (
        .clk_i     (clk_i),
        .rstn_i    (rstn_i),
        .odd_even_i(round_type_i),
        .tvalid_i  (fir_dec_tvalid),
        .tdata_i   (fir_tdata),
        .tvalid_o  (tvalid_o),
        .tdata_o   (tdata_o)
    );

endmodule
