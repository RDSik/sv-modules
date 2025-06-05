// ----------------------------------------------------------------------------
// From https://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf
// ----------------------------------------------------------------------------

module wr_ptr_full #(
    parameter int ADDR_WIDTH = 4
) (
    input  logic                  wr_en_i,
    input  logic                  wr_clk_i,
    input  logic                  wr_arstn_i,
    output logic [ADDR_WIDTH-1:0] wr_addr_o,
    input  logic [ADDR_WIDTH:0]   rd_sync_ptr_i,
    output logic [ADDR_WIDTH:0]   wr_ptr_o,
    output logic                  full_o
);

logic [ADDR_WIDTH:0] wbin;
logic [ADDR_WIDTH:0] wgraynext;
logic [ADDR_WIDTH:0] wbinnext;
logic                full_val;

always_ff @(posedge wr_clk_i or negedge wr_arstn_i) begin
    if (~wr_arstn_i) begin
        {wbin, wr_ptr_o} <= '0;
    end else begin
        {wbin, wr_ptr_o} <= {wbinnext, wgraynext};
    end
end

assign wr_addr_o = wbin[ADDR_WIDTH-1:0];
assign wbinnext  = wbin + (wr_en_i & ~full_o);
assign wgraynext = (wbinnext >> 1) ^ wbinnext;

assign full_val = (wgraynext == {~rd_sync_ptr_i[ADDR_WIDTH:ADDR_WIDTH-1], rd_sync_ptr_i[ADDR_WIDTH-2:0]});

always_ff @(posedge wr_clk_i or negedge wr_arstn_i) begin
    if (~wr_arstn_i) begin
        full_o <= 1'b0;
    end else begin
        full_o <= full_val;
    end
end

endmodule
