// ----------------------------------------------------------------------------
// Based on https://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
// ----------------------------------------------------------------------------

/* verilator lint_off TIMESCALEMOD */
module wr_ptr_full #(
    parameter int ADDR_WIDTH = 4
) (
    input  logic                  wr_en_i,
    input  logic                  wr_clk_i,
    input  logic                  wr_rstn_i,
    input  logic [  ADDR_WIDTH:0] wq2_rptr_i,
    output logic [ADDR_WIDTH-1:0] wr_addr_o,
    output logic [  ADDR_WIDTH:0] wr_ptr_o,
    output logic                  full_o,
    output logic                  a_full_o
);

    logic [ADDR_WIDTH:0] wbin;
    logic [ADDR_WIDTH:0] wgraynext;
    logic [ADDR_WIDTH:0] wbinnext;
    logic [ADDR_WIDTH:0] wgraynextp1;
    logic                full_val;
    logic                a_full_val;

    always_ff @(posedge wr_clk_i) begin
        if (~wr_rstn_i) begin
            {wbin, wr_ptr_o} <= '0;
        end else begin
            {wbin, wr_ptr_o} <= {wbinnext, wgraynext};
        end
    end

    assign wr_addr_o = wbin[ADDR_WIDTH-1:0];
    assign wbinnext = wbin + (wr_en_i & ~full_o);
    assign wgraynext = (wbinnext >> 1) ^ wbinnext;
    assign wgraynextp1 = ((wbinnext + 1'b1) >> 1) ^ (wbinnext + 1'b1);

    assign full_val   = (wgraynext == {~wq2_rptr_i[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr_i[ADDR_WIDTH-2:0]});
    assign a_full_val = (wgraynextp1 == {~wq2_rptr_i[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr_i[ADDR_WIDTH-2:0]});

    always_ff @(posedge wr_clk_i) begin
        if (~wr_rstn_i) begin
            a_full_o <= 1'b0;
            full_o   <= 1'b0;
        end else begin
            a_full_o <= a_full_val;
            full_o   <= full_val;
        end
    end

endmodule
