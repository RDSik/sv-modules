/* verilator lint_off TIMESCALEMOD */
module round #(
    parameter int DATA_IN_WIDTH  = 40,
    parameter int DATA_OUT_WIDTH = 16
) (
    input  logic                      clk_i,
    input  logic                      odd_even_i,   // 1 - round to odd, 0 - round to even
    input  logic [ DATA_IN_WIDTH-1:0] data_i,
    output logic [DATA_OUT_WIDTH-1:0] round_data_o
);

    // Convergent Rounding: LSB Correction Technique
    // ---------------------------------------------
    // For static convergent rounding, the pattern detector can be used
    // to detect the midpoint case. For example, in an 8-bit round, if
    // the decimal place is set at 4, the C input should be set to
    // 0000.0111.  Round to even rounding should use CARRYIN = "1" and
    // check for PATTERN "XXXX.0000" and replace the units place with 0
    // if the pattern is matched. See UG193 for more details.

    localparam int SHIFT = DATA_IN_WIDTH - DATA_OUT_WIDTH;

    logic                     pattern_detect;
    logic [        SHIFT-1:0] pattern;
    logic [DATA_IN_WIDTH-1:0] c;

    logic [DATA_IN_WIDTH-1:0] multadd;
    logic [DATA_IN_WIDTH-1:0] multadd_reg;

    assign pattern = (odd_even_i) ? {SHIFT{1'b1}} : {SHIFT{1'b0}};

    assign c = {{(DATA_IN_WIDTH - SHIFT) {1'b0}}, {SHIFT{1'b1}}};

    assign multadd = (odd_even_i) ? data_i + c : data_i + c + 1'b1;

    always_ff @(posedge clk_i) begin
        pattern_detect <= (multadd[SHIFT-1:0] == pattern);
        multadd_reg    <= multadd;
    end

    always_ff @(posedge clk_i) begin
        if (pattern_detect) begin
            if (odd_even_i) begin
                round_data_o <= {multadd_reg[DATA_IN_WIDTH-1:SHIFT+1], 1'b1};
            end else begin
                round_data_o <= {multadd_reg[DATA_IN_WIDTH-1:SHIFT+1], 1'b0};
            end
        end else begin
            round_data_o <= multadd_reg[DATA_IN_WIDTH-1:SHIFT];
        end
    end

endmodule
