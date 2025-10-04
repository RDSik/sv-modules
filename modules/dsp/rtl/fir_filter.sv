/* verilator lint_off TIMESCALEMOD */
module fir_filter #(
    parameter int CH_NUM      = 2,
    parameter int DATA_WIDTH = 16,
    parameter int COEF_WIDTH = 18,
    parameter int TAP_NUM    = 28,
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

    input logic                                     tvalid_i,
    input logic signed [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                                                tvalid_o,
    output logic signed [CH_NUM-1:0][DATA_WIDTH+COEF_WIDTH-1:0] tdata_o
);

    localparam int DELAY = ($countones(TAP_NUM) == 1) ? 1 : 0;

    logic tvalid_d;

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (TAP_NUM + $clog2(TAP_NUM) + DELAY),
        .RESET_EN  (1)
    ) i_shift_reg (
        .clk_i (clk_i),
        .rstn_i(rstn_i),
        .en_i  (en_i),
        .data_i(tvalid_i),
        .data_o(tvalid_d)
    );

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
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
        logic signed [                   COEF_WIDTH-1:0] coef [  TAP_NUM];
        logic signed [                   DATA_WIDTH-1:0] delay[  TAP_NUM];
        logic signed [        DATA_WIDTH+COEF_WIDTH-1:0] mult [  TAP_NUM];
        logic signed [DATA_WIDTH+COEF_WIDTH+TAP_NUM-1:0] acc  [TAP_NUM-1];

        for (genvar tap_indx = 0; tap_indx < TAP_NUM; tap_indx++) begin : g_tap
            assign coef[tap_indx] = COEF[tap_indx][COEF_WIDTH-1:0];

            if (tap_indx == 0) begin : g_first_delay
                always_ff @(posedge clk_i) begin
                    if (tvalid_i) begin
                        delay[tap_indx] <= tdata_i[ch_indx];
                    end
                end
            end else begin : g_others_delay
                always_ff @(posedge clk_i) begin
                    delay[tap_indx] <= delay[tap_indx-1];
                end
            end

            always_ff @(posedge clk_i) begin
                mult[tap_indx] <= delay[tap_indx] * coef[tap_indx];
            end

            if (tap_indx < TAP_NUM / 2) begin : g_acc_first_stage
                always_ff @(posedge clk_i) begin
                    acc[tap_indx] <= mult[2*tap_indx] + mult[2*tap_indx+1];
                end
            end else begin : g_acc_second_stage
                always_ff @(posedge clk_i) begin
                    acc[tap_indx] <= acc[2*(tap_indx-(TAP_NUM/2))] + acc[2*(tap_indx-(TAP_NUM/2))+1];
                end
            end
        end

        always_ff @(posedge clk_i) begin
            tdata_o[ch_indx] <= acc[TAP_NUM-2];
        end
    end

endmodule
