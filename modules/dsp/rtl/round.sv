/* verilator lint_off TIMESCALEMOD */
module round #(
    parameter int CH_NUM         = 2,
    parameter int DATA_WIDTH_IN  = 32,
    parameter int DATA_WIDTH_OUT = 16
) (
    input logic clk_i,
    input logic rst_i,

    input logic round_type_i,

    input logic [CH_NUM-1:0][DATA_WIDTH_IN-1:0] tdata_i,
    input logic                                 tvalid_i,

    output logic [CH_NUM-1:0][DATA_WIDTH_OUT-1:0] tdata_o,
    output logic                                  tvalid_o
);

    localparam int FRAC_WIDTH = DATA_WIDTH_IN - DATA_WIDTH_OUT;

    for (genvar i = 0; i < CH_NUM; i++) begin : g_ch
        logic signed [DATA_WIDTH_IN-1:0] data_in;
        assign data_in = tdata_i[i];
        
        logic [FRAC_WIDTH-1:0] even_val;
        logic [FRAC_WIDTH-1:0] odd_val;

        assign even_val = {1'b1, {{FRAC_WIDTH - 1} {1'b0}}};
        assign odd_val  = {1'b0, {{FRAC_WIDTH - 1} {1'b1}}};

        logic [DATA_WIDTH_IN-1:0] add;
        assign add = (round_type_i) ? {{DATA_WIDTH_OUT{1'b0}}, even_val} : {{DATA_WIDTH_OUT{1'b0}}, odd_val};
        
        logic signed [DATA_WIDTH_IN-1:0] sum;
        logic signed [DATA_WIDTH_IN-1:0] sum_reg;

        assign sum = data_in + add;

        logic [FRAC_WIDTH-1:0] pattern_even;
        logic [FRAC_WIDTH-1:0] pattern_odd;
        logic [FRAC_WIDTH-1:0] pattern;
        logic                  pattern_detect;

        assign pattern_even = {FRAC_WIDTH{1'b0}};
        assign pattern_odd  = {FRAC_WIDTH{1'b1}};
        assign pattern      = (round_type_i) ? pattern_even : pattern_odd;

        always_ff @(posedge clk_i) begin
            pattern_detect <= (sum[FRAC_WIDTH-1:0] == pattern);
            sum_reg        <= sum;
        end

        logic lsb_bit;
        assign lsb_bit = (round_type_i) ? 1'b0 : 1'b1;

        logic signed [DATA_WIDTH_OUT-1:0] data_out;
        assign tdata_o[i] = data_out;
        
        always_ff @(posedge clk_i) begin
            if (pattern_detect) begin
                data_out <= {sum_reg[DATA_WIDTH_IN-1:FRAC_WIDTH+1], lsb_bit};
            end else begin
                data_out <= sum_reg[DATA_WIDTH_IN-1:FRAC_WIDTH];
            end
        end
    end

    logic tvalid_d;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            {tvalid_o, tvalid_d} <= '0;
        end else begin
            {tvalid_o, tvalid_d} <= {tvalid_d, tvalid_i};
        end
    end

endmodule
