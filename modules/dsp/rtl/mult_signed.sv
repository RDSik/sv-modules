/* verilator lint_off TIMESCALEMOD */

// Multiplier with 1 dsp and 4 latency

module mult_signed #(
    parameter int A_DATA_WIDTH = 16,
    parameter int B_DATA_WIDTH = 16
) (
    input logic clk_i,
    input logic rst_i,

    input logic signed [A_DATA_WIDTH-1:0] a_tdata_i,
    input logic signed [B_DATA_WIDTH-1:0] b_tdata_i,
    input logic                           tvalid_i,

    output logic signed [A_DATA_WIDTH+B_DATA_WIDTH:0] tdata_o,
    output logic                                      tvalid_o
);

    localparam int MULT_LATENCY = 4;

    logic signed [A_DATA_WIDTH-1:0] a_d, a_dd;
    logic signed [B_DATA_WIDTH-1:0] b_d, b_dd;
    logic signed [A_DATA_WIDTH+B_DATA_WIDTH:0] p_d, p_dd;

    always_ff @(posedge clk_i) begin  // a input dual reg
        a_d  <= a_tdata_i;
        a_dd <= a_d;
    end

    always_ff @(posedge clk_i) begin  // b input dual reg
        b_d  <= b_tdata_i;
        b_dd <= b_d;
    end

    always_ff @(posedge clk_i) begin
        p_d  <= a_dd * b_dd;  // mult + reg
        p_dd <= p_d;  // p output reg
    end

    assign tdata_o = p_dd;

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (MULT_LATENCY),
        .RESET_EN  (1),
        .SRL_STYLE ("register")
    ) i_shift_reg (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .en_i  (1'b1),
        .data_i(tvalid_i),
        .data_o(tvalid_o)
    );

endmodule
