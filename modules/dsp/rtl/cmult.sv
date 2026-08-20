/* verilator lint_off TIMESCALEMOD */

// Complex multiplier with 3dsp and 6 latency

module cmult #(
    parameter integer AWIDTH = 16,
    parameter integer BWIDTH = 18
) (
    input  logic                          clk,
    input  logic signed [     AWIDTH-1:0] ar,   // i
    input  logic signed [     AWIDTH-1:0] ai,   // q
    input  logic signed [     BWIDTH-1:0] br,   // i
    input  logic signed [     BWIDTH-1:0] bi,   // q
    output logic signed [AWIDTH+BWIDTH:0] pr,   // i
    output logic signed [AWIDTH+BWIDTH:0] pi    // q
);

    logic signed [AWIDTH-1:0] ai_d, ai_dd, ai_ddd, ai_dddd;
    logic signed [AWIDTH-1:0] ar_d, ar_dd, ar_ddd, ar_dddd;
    logic signed [BWIDTH-1:0] bi_d, bi_dd, bi_ddd, br_d, br_dd, br_ddd;
    logic signed [AWIDTH:0] addcommon;
    logic signed [BWIDTH:0] addr, addi;
    logic signed [AWIDTH+BWIDTH:0] mult0, multr, multi, pr_int, pi_int;
    logic signed [AWIDTH+BWIDTH:0] common, commonr1, commonr2;

    // regs
    always_ff @(posedge clk) begin
        ar_dd   <= ar_d;
        ar_ddd  <= ar_dd;
        ar_dddd <= ar_ddd;
        ai_dd   <= ai_d;
        ai_ddd  <= ai_dd;
        ai_dddd <= ai_ddd;
        br_d    <= br;
        br_dd   <= br_d;
        br_ddd  <= br_dd;
        bi_d    <= bi;
        bi_dd   <= bi_d;
        bi_ddd  <= bi_dd;
    end

    // Common factor (ar ai) x bi, shared for the calculations of the real and imaginary final products
    always_ff @(posedge clk) begin  // first dsp
        ar_d      <= ar;  // d input reg
        ai_d      <= ai;  // a input reg
        addcommon <= ar_d - ai_d;  // pre_adder + reg
        mult0     <= addcommon * bi_dd;  // mult + reg
        common    <= mult0;  // p output reg
    end

    // Real product
    always_ff @(posedge clk) begin  // second dsp
        addr     <= br_ddd - bi_ddd;  // pre_adder + reg
        multr    <= addr * ar_dddd;  // mult + reg
        commonr1 <= common;  // c input reg
        pr_int   <= multr + commonr1;  // post_adder  + reg
    end

    // Imaginary product
    always_ff @(posedge clk) begin  // third dsp
        addi     <= br_ddd + bi_ddd;  // pre_adder + reg
        multi    <= addi * ai_dddd;  // mult + reg
        commonr2 <= common;  // c input reg
        pi_int   <= multi + commonr2;  // post_adder  + reg
    end

    assign pr = pr_int;
    assign pi = pi_int;

endmodule
