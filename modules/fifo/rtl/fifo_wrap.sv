/* verilator lint_off TIMESCALEMOD */
module fifo_wrap #(
    parameter int FIFO_WIDTH       = 32,
    parameter int FIFO_DEPTH       = 128,
    parameter int CDC_REG_NUM      = 2,
    parameter int RAM_READ_LATENCY = 0,
    parameter     RAM_STYLE        = "distributed",
    parameter     FIFO_MODE        = "sync"
) (
    input logic                  wr_clk_i,
    input logic                  wr_rstn_i,
    input logic [FIFO_WIDTH-1:0] wr_data_i,

    input  logic                  rd_clk_i,
    input  logic                  rd_rstn_i,
    output logic [FIFO_WIDTH-1:0] rd_data_o,

    input logic push_i,
    input logic pop_i,

    output logic a_full_o,
    output logic full_o,
    output logic a_empty_o,
    output logic empty_o
);

    if (FIFO_MODE == "sync") begin : g_fifo
        sync_fifo #(
            .FIFO_WIDTH      (FIFO_WIDTH),
            .FIFO_DEPTH      (FIFO_DEPTH),
            .RAM_READ_LATENCY(RAM_READ_LATENCY),
            .RAM_STYLE       (RAM_STYLE)
        ) i_fifo (
            .clk_i    (wr_clk_i),
            .rstn_i   (wr_rstn_i),
            .data_i   (wr_data_i),
            .data_o   (rd_data_o),
            .push_i   (push_i),
            .pop_i    (pop_i),
            .empty_o  (empty_o),
            .full_o   (full_o),
            .a_empty_o(a_empty_o),
            .a_full_o (a_full_o)
        );
    end else if (FIFO_MODE == "async") begin : g_fifo
        async_fifo #(
            .FIFO_WIDTH (FIFO_WIDTH),
            .FIFO_DEPTH (FIFO_DEPTH),
            .CDC_REG_NUM(CDC_REG_NUM),
            .RAM_STYLE  (RAM_STYLE)
        ) i_fifo (
            .wr_clk_i (wr_clk_i),
            .wr_rstn_i(wr_rstn_i),
            .wr_data_i(wr_data_i),
            .rd_clk_i (rd_clk_i),
            .rd_rstn_i(rd_rstn_i),
            .rd_data_o(rd_data_o),
            .push_i   (push),
            .pop_i    (pop),
            .empty_o  (empty),
            .full_o   (full),
            .a_empty_o(a_empty_o),
            .a_full_o (a_full_o)
        );
    end else begin : g_fifo
        $error("Only sync or async FIFO_MODE is available!");
    end
endmodule
