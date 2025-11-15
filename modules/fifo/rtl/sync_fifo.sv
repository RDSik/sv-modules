/* verilator lint_off TIMESCALEMOD */
module sync_fifo #(
    parameter int FIFO_WIDTH       = 32,
    parameter int FIFO_DEPTH       = 64,
    parameter int RAM_READ_LATENCY = 0,
    parameter     RAM_STYLE        = "block"
) (
    input logic clk_i,
    input logic rstn_i,

    input  logic [FIFO_WIDTH-1:0] data_i,
    output logic [FIFO_WIDTH-1:0] data_o,

    input logic push_i,
    input logic pop_i,

    output logic a_full_o,
    output logic full_o,
    output logic a_empty_o,
    output logic empty_o
);

    localparam logic SHOW_AHEAD_EN = (RAM_READ_LATENCY > 0);
    localparam int PTR_WIDTH = $clog2(FIFO_DEPTH);
    localparam MAX_PTR = PTR_WIDTH'(FIFO_DEPTH - 1);

    logic [ PTR_WIDTH-1:0] wr_ptr;
    logic [ PTR_WIDTH-1:0] rd_ptr;
    logic [ PTR_WIDTH-1:0] prefetch_ptr;
    logic                  wr_en;
    logic                  rd_en;
    logic [FIFO_WIDTH-1:0] ram_data;

    // Write pointer
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
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
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            rd_ptr <= '0;
        end else if (pop_i) begin
            if (rd_ptr == MAX_PTR) begin
                rd_ptr <= '0;
            end else begin
                rd_ptr <= rd_ptr + 1'b1;
            end
        end
    end

    if (SHOW_AHEAD_EN) begin : g_show_ahead
        logic [FIFO_WIDTH-1:0] bypass_data;
        logic                  bypass_valid;
        logic                  bypass_en;

        assign wr_en = push_i & ~bypass_en;
        assign rd_en = pop_i & ~a_empty_o;

        assign prefetch_ptr = (rd_ptr == MAX_PTR) ? '0 : rd_ptr + 1'b1;

        assign bypass_en = push_i && (empty_o || (pop_i && a_empty_o));

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                bypass_valid <= 1'b0;
            end else if (bypass_en) begin
                bypass_valid <= 1'b1;
            end else if (pop_i) begin
                bypass_valid <= 1'b0;
            end
        end

        always_ff @(posedge clk_i) begin
            if (bypass_en) begin
                bypass_data <= data_i;
            end
        end

        assign data_o = bypass_valid ? bypass_data : ram_data;
    end else begin : g_others
        assign wr_en        = push_i & ~full_o;
        assign rd_en        = pop_i & ~empty_o;
        assign prefetch_ptr = rd_ptr;
        assign data_o       = ram_data;
    end

    ram_sdp #(
        .MEM_DEPTH   (FIFO_DEPTH),
        .BYTE_WIDTH  (FIFO_WIDTH),
        .BYTE_NUM    (1),
        .READ_LATENCY(RAM_READ_LATENCY),
        .RAM_STYLE   (RAM_STYLE),
        .MEM_MODE    ("read_first")
    ) i_ram_sdp (
        .a_clk_i  (clk_i),
        .a_en_i   (wr_en),
        .a_wr_en_i(wr_en),
        .a_addr_i (wr_ptr),
        .a_data_i (data_i),
        .b_clk_i  (clk_i),
        .b_en_i   (rd_en),
        .b_addr_i (prefetch_ptr),
        .b_data_o (ram_data)
    );

    logic [PTR_WIDTH:0] data_cnt;
    logic [PTR_WIDTH:0] data_cnt_next;
    logic               a_full;
    logic               full;
    logic               a_empty;
    logic               empty;

    always_comb begin
        data_cnt_next = data_cnt;
        if (push_i & ~pop_i) begin
            data_cnt_next = data_cnt + 1'b1;
        end else if (pop_i & ~push_i) begin
            data_cnt_next = data_cnt - 1'b1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            data_cnt <= '0;
        end else begin
            data_cnt <= data_cnt_next;
        end
    end

    /* verilator lint_off WIDTHEXPAND*/
    assign a_full  = (data_cnt_next == FIFO_DEPTH - 1);
    assign full    = (data_cnt_next == FIFO_DEPTH);
    assign a_empty = (data_cnt_next == 1);
    assign empty   = (data_cnt_next == 0);
    /* verilator lint_on WIDTHEXPAND*/

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            a_full_o  <= 1'b0;
            full_o    <= 1'b0;
            a_empty_o <= 1'b0;
            empty_o   <= 1'b1;
        end else begin
            a_full_o  <= a_full;
            full_o    <= full;
            a_empty_o <= a_empty;
            empty_o   <= empty;
        end
    end

endmodule
