/* verilator lint_off TIMESCALEMOD */

// Complex multiplier with 3dsp and 6 latency

module cmult #(
    parameter integer A_DATA_WIDTH = 16,
    parameter integer B_DATA_WIDTH = 18
) (
    input logic clk_i,
    input logic rst_i,

    input logic signed [1:0][A_DATA_WIDTH-1:0] a_tdata_i,  // {q, i} -> {msb, lsb}
    input logic signed [1:0][B_DATA_WIDTH-1:0] b_tdata_i,  // {q, i} -> {msb, lsb}
    input logic                                tvalid_i,

    output logic signed [1:0][A_WIDTH+B_DATA_WIDTH:0] tdata_o,  // {q, i} -> {msb, lsb}
    output logic                                      tvalid_o
);

    localparam int CMULT_LATENCY = 6;

    logic signed [A_DATA_WIDTH-1:0] ai_d, ai_dd, ai_ddd, ai_dddd;
    logic signed [A_DATA_WIDTH-1:0] ar_d, ar_dd, ar_ddd, ar_dddd;
    logic signed [B_DATA_WIDTH-1:0] bi_d, bi_dd, bi_ddd, br_d, br_dd, br_ddd;
    logic signed [A_DATA_WIDTH:0] addcommon;
    logic signed [B_DATA_WIDTH:0] addr, addi;
    logic signed [A_DATA_WIDTH+B_DATA_WIDTH:0] mult0, multr, multi, pr_int, pi_int;
    logic signed [A_DATA_WIDTH+B_DATA_WIDTH:0] common, commonr1, commonr2;

    always_ff @(posedge clk_i) begin
        ar_dd <= ar_d;
        ai_dd <= ai_d;
        br_d  <= b_tdata_i[0];
        br_dd <= br_d;
        bi_d  <= b_tdata_i[1];
        bi_dd <= bi_d;
    end

    always_ff @(posedge clk_i) begin
        ar_ddd  <= ar_dd;
        ar_dddd <= ar_ddd;
        ai_ddd  <= ai_dd;
        ai_dddd <= ai_ddd;
        br_ddd  <= br_dd;
        bi_ddd  <= bi_dd;
    end

    // Common factor (ar ai) x bi, shared for the calculations of the real and imaginary final products
    always_ff @(posedge clk_i) begin  // first dsp
        ai_d      <= a_tdata_i[1];  // a input reg
        ar_d      <= a_tdata_i[0];  // b input reg
        addcommon <= ar_d - ai_d;  // pre-adder + reg
        mult0     <= addcommon * bi_dd;  // mult + reg
        common    <= mult0;  // p output reg
    end

    // Real product
    always_ff @(posedge clk_i) begin  // second dsp
        addr     <= br_ddd - bi_ddd;  // pre-adder + reg
        multr    <= addr * ar_dddd;  // mult + reg
        commonr1 <= common;  // c input reg
        pr_int   <= multr + commonr1;  // alu + reg
    end

    // Imaginary product
    always_ff @(posedge clk_i) begin  // third dsp
        addi     <= br_ddd + bi_ddd;  // pre-adder + reg
        multi    <= addi * ai_dddd;  // mult + reg
        commonr2 <= common;  // c input reg
        pi_int   <= multi + commonr2;  // alu  + reg
    end

    assign tdata_o[0] = pr_int;
    assign tdata_o[1] = pi_int;

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (CMULT_LATENCY),
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
