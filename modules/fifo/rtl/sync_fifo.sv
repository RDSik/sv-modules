/* verilator lint_off TIMESCALEMOD */
module sync_fifo #(
    parameter int FIFO_WIDTH  = 32,
    parameter int FIFO_DEPTH  = 64,
    parameter int CIRCLE_BUF  = 1
) (
    input  logic                  clk_i,
    input  logic                  arstn_i,

    input  logic [FIFO_WIDTH-1:0] data_i,
    output logic [FIFO_WIDTH-1:0] data_o,

    input  logic                  push_i,
    input  logic                  pop_i,
    output logic                  full_o,
    output logic                  empty_o
);

localparam PTR_WIDTH = $clog2(FIFO_DEPTH);
localparam MAX_PTR   = PTR_WIDTH'(FIFO_DEPTH-1);

logic [PTR_WIDTH-1:0]  wr_ptr;
logic [PTR_WIDTH-1:0]  rd_ptr;
logic [PTR_WIDTH-1:0]  prefetch_ptr;
logic                  almost_empty;
logic                  wr_en;
logic                  rd_en;
logic [FIFO_WIDTH-1:0] ram_data;
logic [FIFO_WIDTH-1:0] bypass_data;
logic                  bypass_valid;
logic                  bypass_en;

// Write pointer
always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        wr_ptr <= '0;
    end else if (push_i) begin
        if (wr_ptr == MAX_PTR) begin
            wr_ptr <= '0;
        end else begin
            wr_ptr <= wr_ptr + 1'b1;
        end
    end
end

// Read pointer
always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        rd_ptr <= '0;
    end else if (pop_i) begin
        if (rd_ptr == MAX_PTR) begin
            rd_ptr <= '0;
        end else begin
            rd_ptr <= rd_ptr + 1'b1;
        end
    end
end

assign wr_en = push_i & ~bypass_en;
assign rd_en = pop_i & ~almost_empty;

assign prefetch_ptr = (rd_ptr == MAX_PTR) ? '0 : rd_ptr + 1'b1;
assign almost_empty = (wr_ptr == prefetch_ptr);

assign bypass_en = push_i && (empty_o || (pop_i && almost_empty));

always_ff @(posedge clk_i) begin
    if (bypass_en) begin
        bypass_data <= data_i;
    end
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        bypass_valid <= 1'b0;
    end else if (bypass_en) begin
        bypass_valid <= 1'b1;
    end else if (pop_i) begin
        bypass_valid <= 1'b0;
    end
end

assign data_o = bypass_valid ? bypass_data : ram_data;

bram_dp #(
    .MEM_WIDTH   (FIFO_WIDTH  ),
    .MEM_DEPTH   (FIFO_DEPTH  )
) i_bram (
    .clk_i       (clk_i       ),
    .wr_en_i     (wr_en       ),
    .wr_addr_i   (wr_ptr      ),
    .wr_data_i   (data_i      ),
    .rd_en_i     (rd_en       ),
    .rd_addr_i   (prefetch_ptr),
    .rd_data_o   (ram_data    )
);

if (CIRCLE_BUF == 1) begin
    logic wr_odd_circle;
    logic rd_odd_circle;
    logic equal_ptr;

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            wr_odd_circle <= 1'b0;
        end else if (push_i) begin
            if (wr_ptr == MAX_PTR) begin
                wr_odd_circle <= ~wr_odd_circle;
            end
        end
    end

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            rd_odd_circle <= 1'b0;
        end else if (pop_i) begin
            if (rd_ptr == MAX_PTR) begin
                rd_odd_circle <= ~rd_odd_circle;
            end
        end
    end

    assign equal_ptr = (wr_ptr == rd_ptr);
    assign full_o    = equal_ptr && (wr_odd_circle != rd_odd_circle);
    assign empty_o   = equal_ptr && (wr_odd_circle == rd_odd_circle);
end else begin
    logic [PTR_WIDTH:0] status_cnt;

    always_ff @(posedge clk_i or negedge arstn_i) begin
        if (~arstn_i) begin
            status_cnt <= '0;
        end else if (push_i & ~pop_i) begin
            status_cnt <= status_cnt + 1'b1;
        end else if (pop_i & ~push_i) begin
            status_cnt <= status_cnt - 1'b1;
        end
    end

    assign full_o  = (status_cnt == MAX_PTR);
    assign empty_o = (status_cnt == '0);
end

endmodule
