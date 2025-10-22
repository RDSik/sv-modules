/* verilator lint_off TIMESCALEMOD */
module round #(
    parameter int CH_NUM         = 2,
    parameter int DATA_WIDTH_IN  = 40,
    parameter int DATA_WIDTH_OUT = 16
) (
    input logic clk_i,
    input logic rstn_i,
    input logic odd_even_i, // 1 - round to odd, 0 - round to even

    input logic                                 tvalid_i,
    input logic [CH_NUM-1:0][DATA_WIDTH_IN-1:0] tdata_i,

    output logic                                  tvalid_o,
    output logic [CH_NUM-1:0][DATA_WIDTH_OUT-1:0] tdata_o
);

    // Convergent Rounding: LSB Correction Technique
    // ---------------------------------------------
    // For static convergent rounding, the pattern detector can be used
    // to detect the midpoint case. For example, in an 8-bit round, if
    // the decimal place is set at 4, the C input should be set to
    // 0000.0111.  Round to even rounding should use CARRYIN = "1" and
    // check for PATTERN "XXXX.0000" and replace the units place with 0
    // if the pattern is matched. See UG193 for more details.

    localparam int SHIFT = DATA_WIDTH_IN - DATA_WIDTH_OUT;

    logic [        SHIFT-1:0] pattern;
    logic [DATA_WIDTH_IN-1:0] c;

    assign pattern = (odd_even_i) ? {SHIFT{1'b1}} : {SHIFT{1'b0}};

    assign c = {{(DATA_WIDTH_IN - SHIFT) {1'b0}}, {SHIFT{1'b1}}};

    for (genvar ch_indx = 0; ch_indx < CH_NUM; ch_indx++) begin : g_ch
        logic                     pattern_detect;
        logic [DATA_WIDTH_IN-1:0] multadd;
        logic [DATA_WIDTH_IN-1:0] multadd_reg;

        assign multadd = (odd_even_i) ? (tdata_i[ch_indx] + c) : (tdata_i[ch_indx] + c + 1'b1);

        always_ff @(posedge clk_i) begin
            if (tvalid_i) begin
                multadd_reg <= multadd;
            end
            pattern_detect <= (multadd[SHIFT-1:0] == pattern);
        end

        always_ff @(posedge clk_i) begin
            if (pattern_detect) begin
                if (odd_even_i) begin
                    tdata_o[ch_indx] <= {multadd_reg[DATA_WIDTH_IN-1:SHIFT+1], 1'b1};
                end else begin
                    tdata_o[ch_indx] <= {multadd_reg[DATA_WIDTH_IN-1:SHIFT+1], 1'b0};
                end
            end else begin
                tdata_o[ch_indx] <= multadd_reg[DATA_WIDTH_IN-1:SHIFT];
            end
        end
    end

    localparam int DELAY = 2;

    logic [DELAY-1:0] tvalid_d;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            tvalid_d <= '0;
        end else begin
            tvalid_d <= {tvalid_d[DELAY-2:0], tvalid_i};
        end
    end

    assign tvalid_o = tvalid_d[DELAY-1];

endmodule
