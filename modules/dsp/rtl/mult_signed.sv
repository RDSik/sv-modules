/* verilator lint_off TIMESCALEMOD */

// Multiplier with 1 dsp and 4 latency

module mult_signed #(
    parameter int AWIDTH = 16,
    parameter int BWIDTH = 16
) (
    input  logic                          clk,
    input  logic signed [     AWIDTH-1:0] a,
    input  logic signed [     BWIDTH-1:0] b,
    output logic signed [AWIDTH+BWIDTH:0] p
);

    logic signed [AWIDTH-1:0] a_d, a_dd;
    logic signed [BWIDTH-1:0] b_d, b_dd;
    logic signed [AWIDTH+BWIDTH:0] p_d, p_dd;

    always_ff @(posedge clk) begin  // a input dual reg
        a_d  <= a;
        a_dd <= a_d;
    end

    always_ff @(posedge clk) begin  // b input dual reg
        b_d  <= b;
        b_dd <= b_d;
    end

    always_ff @(posedge clk) begin
        p_d  <= a_dd * b_dd;  // mult reg
        p_dd <= p_d;  // p output reg
    end

    assign p = p_dd;

endmodule
