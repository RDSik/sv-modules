module mult_signed #(
    parameter int A_WIDTH = 16,
    parameter int B_WIDTH = 16
) (
    input  logic                            clk,
    input  logic signed [      A_WIDTH-1:0] a,
    input  logic signed [      B_WIDTH-1:0] b,
    output logic signed [A_WIDTH+B_WIDTH:0] p
);

    logic signed [A_WIDTH-1:0] a_d, a_dd;
    logic signed [B_WIDTH-1:0] b_d, b_dd;
    logic signed [A_WIDTH+B_WIDTH:0] p_d, p_dd;

    always_ff @(posedge clk) begin
        a_d  <= a;
        a_dd <= a_d;
        b_d  <= b;
        b_dd <= b_d;
    end

    always_ff @(posedge clk) begin
        p_d  <= a_dd * b_dd;
        p_dd <= p_d;
    end

    assign p = p_dd;

endmodule
