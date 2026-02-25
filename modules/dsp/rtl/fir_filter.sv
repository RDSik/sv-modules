/* verilator lint_off TIMESCALEMOD */
module fir_filter #(
    parameter     COE_FILE   = "fir.mem",
    parameter int CH_NUM     = 2,
    parameter int DATA_WIDTH = 16,
    parameter int COEF_WIDTH = 18,
    parameter int TAP_NUM    = 32
) (
    input logic clk_i,
    input logic rst_i,

    input logic                                     tvalid_i,
    input logic signed [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                                                        tvalid_o,
    output logic signed [CH_NUM-1:0][COEF_WIDTH+DATA_WIDTH+TAP_NUM-1:0] tdata_o
);

    if ($countones(TAP_NUM) != 1) begin : g_tap_num_err
        $error("TAP_NUM must be pow of 2!");
    end

    logic [COEF_WIDTH-1:0] coe_mem[TAP_NUM];

    initial begin
        $readmemh(COE_FILE, coe_mem);
    end

    localparam int DELAY = TAP_NUM + $clog2(TAP_NUM);

    logic tvalid_d;

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (DELAY),
        .RESET_EN  (1),
        .SRL_STYLE ("srl")
    ) i_shift_reg (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .en_i  (tvalid_i),
        .data_i(tvalid_i),
        .data_o(tvalid_d)
    );

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            tvalid_o <= 1'b0;
        end else begin
            tvalid_o <= tvalid_d;
        end
    end

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        logic signed [TAP_NUM-1:0][                   DATA_WIDTH-1:0] delay;
        logic signed [TAP_NUM-1:0][        DATA_WIDTH+COEF_WIDTH-1:0] mult;
        logic signed [TAP_NUM-2:0][DATA_WIDTH+COEF_WIDTH+TAP_NUM-1:0] acc;

        always_ff @(posedge clk_i) begin
            if (tvalid_i) begin
                delay[0] <= tdata_i[ch_indx];
                for (int tap_indx = 1; tap_indx < TAP_NUM; tap_indx++) begin
                    delay[tap_indx] <= delay[tap_indx-1];
                end
             end
        end

        always_ff @(posedge clk_i) begin
            for (int tap_indx = 0; tap_indx < TAP_NUM; tap_indx++) begin
                mult[tap_indx] <= delay[tap_indx] * signed'(coe_mem[tap_indx]);
            end
        end

        always_ff @(posedge clk_i) begin
            for (int tap_indx = 0; tap_indx < TAP_NUM - 1; tap_indx++) begin
                if (tap_indx < TAP_NUM / 2) begin
                    acc[tap_indx] <= mult[2*tap_indx] + mult[2*tap_indx+1];
                end else begin
                    acc[tap_indx] <= acc[2*(tap_indx-(TAP_NUM/2))] + acc[2*(tap_indx-(TAP_NUM/2))+1];
                end
            end
        end

        always_ff @(posedge clk_i) begin
            tdata_o[ch_indx] <= acc[TAP_NUM-2];
        end
    end

endmodule
