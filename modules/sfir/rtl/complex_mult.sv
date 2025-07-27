
//  Complex Multiplier
//  The following code implements a parameterizable complex multiplier
//  The style described uses 3 DSP's to implement the complex multiplier
//  taking advantage of the pre-adder, so widths chosen should be less than what the architecture supports or else extra-logic/extra DSPs will be inferred
module complex_mult #(
    parameter int A_WIDTH = 16,  // size of 1st input of multiplier
    parameter int B_WIDTH = 18   // size of 2nd input of multiplier
) (
    input                             clk_i,
    input  signed [      A_WIDTH-1:0] ar_i,
    input  signed [      A_WIDTH-1:0] ai_i,
    input  signed [      B_WIDTH-1:0] br_i,
    input  signed [      A_WIDTH-1:0] bi_i,
    output signed [A_WIDTH+B_WIDTH:0] pr_o,
    output signed [A_WIDTH+B_WIDTH:0] pi_o
);

    logic signed [A_WIDTH-1:0] ai_d, ai_dd, ai_ddd, ai_dddd;
    logic signed [A_WIDTH-1:0] ar_d, ar_dd, ar_ddd, ar_dddd;
    logic signed [B_WIDTH-1:0] bi_d, bi_dd, bi_ddd, br_d, br_dd, br_ddd;
    logic signed [A_WIDTH:0] addcommon;
    logic signed [B_WIDTH:0] addr, addi;
    logic signed [A_WIDTH+B_WIDTH:0] mult0, multr, multi, pr_int, pi_int;
    logic signed [A_WIDTH+B_WIDTH:0] common, commonr1, commonr2;

    always_ff @(posedge clk_i) begin
        ar_d   <= ar_i;
        ar_dd  <= ar_d;
        ai_d   <= ai_i;
        ai_dd  <= ai_d;
        br_d   <= br_i;
        br_dd  <= br_d;
        br_ddd <= br_dd;
        bi_d   <= bi_i;
        bi_dd  <= bi_d;
        bi_ddd <= bi_dd;
    end

    // Common factor (ar ai) x bi, shared for the calculations of the real and imaginary final products
    //
    always_ff @(posedge clk_i) begin
        addcommon <= ar_d - ai_d;
        mult0     <= addcommon * bi_dd;
        common    <= mult0;
    end

    // Real product
    //
    always_ff @(posedge clk_i) begin
        ar_ddd   <= ar_dd;
        ar_dddd  <= ar_ddd;
        addr     <= br_ddd - bi_ddd;
        multr    <= addr * ar_dddd;
        commonr1 <= common;
        pr_int   <= multr + commonr1;
    end

    // Imaginary product
    //
    always_ff @(posedge clk_i) begin
        ai_ddd   <= ai_dd;
        ai_dddd  <= ai_ddd;
        addi     <= br_ddd + bi_ddd;
        multi    <= addi * ai_dddd;
        commonr2 <= common;
        pi_int   <= multi + commonr2;
    end

    assign pr_o = pr_int;
    assign pi_o = pi_int;

endmodule  // cmult
