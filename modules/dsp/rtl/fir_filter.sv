/* verilator lint_off TIMESCALEMOD */
module fir_filter #(
    parameter     COE_FILE   = "fir.mem",
    parameter int CH_NUM     = 2,
    parameter int DATA_WIDTH = 16,
    parameter int COEF_WIDTH = 18,
    parameter int TAP_NUM    = 25
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

    logic [COEF_WIDTH-1:0] coe_mem[TAP_NUM];

    initial begin
        $readmemh(COE_FILE, coe_mem);
    end

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
        logic signed [                   DATA_WIDTH-1:0] delay[  TAP_NUM];
        logic signed [        DATA_WIDTH+COEF_WIDTH-1:0] mult [  TAP_NUM];
        logic signed [DATA_WIDTH+COEF_WIDTH+TAP_NUM-1:0] acc  [TAP_NUM-1];

        for (genvar tap_indx = 0; tap_indx < TAP_NUM; tap_indx++) begin : g_tap
            always_ff @(posedge clk_i) begin
                if (tap_indx == 0) begin
                    if (tvalid_i) begin
                        delay[tap_indx] <= tdata_i[ch_indx];
                    end
                end else begin
                    delay[tap_indx] <= delay[tap_indx-1];
                end
            end

            always_ff @(posedge clk_i) begin
                mult[tap_indx] <= delay[tap_indx] * coe_mem[tap_indx];
            end

            always_ff @(posedge clk_i) begin
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
