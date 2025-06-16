// ----------------------------------------------------------------------------
// From https://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
// ----------------------------------------------------------------------------

/* verilator lint_off TIMESCALEMOD */
module rd_ptr_empty #(
    parameter int ADDR_WIDTH = 4
) (
    input  logic                  rd_clk_i,
    input  logic                  rd_arstn_i,
    input  logic                  rd_en_i,
    input  logic [ADDR_WIDTH:0]   rq2_wptr_i,
    output logic [ADDR_WIDTH-1:0] rd_addr_o,
    output logic [ADDR_WIDTH:0]   rd_ptr_o,
    output logic                  empty_o
);

logic [ADDR_WIDTH:0] rbin;
logic [ADDR_WIDTH:0] rgraynext;
logic [ADDR_WIDTH:0] rbinnext;
logic                empty_val;

always_ff @(posedge rd_clk_i or negedge rd_arstn_i) begin
    if (~rd_arstn_i) begin
        {rbin, rd_ptr_o} <= '0;
    end else begin
        {rbin, rd_ptr_o} <= {rbinnext, rgraynext};
    end
end

assign rd_addr_o = rbin[ADDR_WIDTH-1:0];
assign rbinnext  = rbin + (rd_en_i & ~empty_o);
assign rgraynext = (rbinnext >> 1) ^ rbinnext;

assign empty_val = (rgraynext == rq2_wptr_i);

always_ff @(posedge rd_clk_i or negedge rd_arstn_i) begin
    if (~rd_arstn_i) begin
        empty_o <= 1'b1;
    end else begin
        empty_o <= empty_val;
    end
end

endmodule
