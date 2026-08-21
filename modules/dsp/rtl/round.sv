/* verilator lint_off TIMESCALEMOD */

// Convergent Rounding (LSB Correction Technique)

module round #(
    parameter int   CH_NUM         = 2,
    parameter int   DATA_WIDTH_IN  = 32,
    parameter int   DATA_WIDTH_OUT = 16,
    parameter logic ROUND_TYPE     = 1,     // 1 - even, 0 - odd
    parameter       USE_DSP        = "no"
) (
    input logic clk_i,
    input logic rst_i,

    input logic [CH_NUM-1:0][DATA_WIDTH_IN-1:0] tdata_i,
    input logic                                 tvalid_i,

    output logic [CH_NUM-1:0][DATA_WIDTH_OUT-1:0] tdata_o,
    output logic                                  tvalid_o
);

    if (DATA_WIDTH_IN == DATA_WIDTH_OUT) begin : g_equal
        assign tdata_o  = tdata_i;
        assign tvalid_o = tvalid_i;
    end else begin : g_round
        localparam int FRAC_WIDTH = DATA_WIDTH_IN - DATA_WIDTH_OUT;

        for (genvar i = 0; i < CH_NUM; i++) begin : g_ch
            logic [FRAC_WIDTH-1:0] add;
            assign add = (ROUND_TYPE) ? {1'b1, {{FRAC_WIDTH - 1} {1'b0}}} : {1'b0, {{FRAC_WIDTH - 1} {1'b1}}};

            logic [FRAC_WIDTH-1:0] pattern;
            assign pattern = (ROUND_TYPE) ? {FRAC_WIDTH{1'b0}} : {FRAC_WIDTH{1'b1}};

            (* use_dsp = USE_DSP *) logic signed [DATA_WIDTH_IN-1:0] sum_reg;
            logic signed [DATA_WIDTH_IN-1:0] sum;
            logic signed [DATA_WIDTH_IN-1:0] data_in;
            logic pattern_detect;

            assign sum = data_in + {{DATA_WIDTH_OUT{1'b0}}, add}; // pre_adder 
            
            always_ff @(posedge clk_i) begin // dsp
                data_in        <= signed'(tdata_i[i]);  // input reg
                sum_reg        <= sum; // pre_adder reg
                pattern_detect <= (sum[FRAC_WIDTH-1:0] == pattern); // pattern_detect
            end

            logic signed [DATA_WIDTH_OUT-1:0] data_out;

            always_ff @(posedge clk_i) begin
                if (pattern_detect) begin
                    data_out <= {sum_reg[DATA_WIDTH_IN-1:FRAC_WIDTH+1], ~ROUND_TYPE};
                end else begin
                    data_out <= sum_reg[DATA_WIDTH_IN-1:FRAC_WIDTH];
                end
            end

            assign tdata_o[i] = data_out;
        end

        shift_reg #(
            .DATA_WIDTH($bits(tvalid_i)),
            .DELAY     (3),
            .RESET_EN  (1),
            .SRL_STYLE ("register")
        ) i_shift_reg (
            .clk_i (clk_i),
            .rst_i (rst_i),
            .en_i  (1'b1),
            .data_i(tvalid_i),
            .data_o(tvalid_o)
        );
    end

endmodule
