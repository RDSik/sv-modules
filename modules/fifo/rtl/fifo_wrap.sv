/* verilator lint_off TIMESCALEMOD */
module fifo_wrap #(
    parameter int FIFO_WIDTH   = 32,
    parameter int FIFO_DEPTH   = 128,
    parameter int CDC_REG_NUM  = 2,
    parameter int READ_LATENCY = 1,
    parameter     RAM_STYLE    = "block",
    parameter     FIFO_MODE    = "sync"
) (
    input logic                  wr_clk_i,
    input logic                  wr_rst_i,
    input logic [FIFO_WIDTH-1:0] wr_data_i,

    input  logic                  rd_clk_i,
    input  logic                  rd_rst_i,
    output logic [FIFO_WIDTH-1:0] rd_data_o,

    input logic push_i,
    input logic pop_i,

    output logic a_full_o,
    output logic full_o,
    output logic a_empty_o,
    output logic empty_o,

    output logic [$clog2(FIFO_DEPTH):0] data_cnt_o
);

    if (FIFO_MODE == "sync") begin : g_sync_fifo
        sync_fifo #(
            .FIFO_WIDTH  (FIFO_WIDTH),
            .FIFO_DEPTH  (FIFO_DEPTH),
            .READ_LATENCY(READ_LATENCY),
            .RAM_STYLE   (RAM_STYLE)
        ) i_sync_fifo (
            .clk_i     (wr_clk_i),
            .rst_i     (wr_rst_i),
            .data_i    (wr_data_i),
            .data_o    (rd_data_o),
            .push_i    (push_i),
            .pop_i     (pop_i),
            .empty_o   (empty_o),
            .full_o    (full_o),
            .a_empty_o (a_empty_o),
            .a_full_o  (a_full_o),
            .data_cnt_o(data_cnt_o)
        );
    end else if (FIFO_MODE == "async") begin : g_async_fifo
        async_fifo #(
            .FIFO_WIDTH (FIFO_WIDTH),
            .FIFO_DEPTH (FIFO_DEPTH),
            .CDC_REG_NUM(CDC_REG_NUM)
        ) i_async_fifo (
            .wr_clk_i (wr_clk_i),
            .wr_rst_i (wr_rst_i),
            .wr_data_i(wr_data_i),
            .rd_clk_i (rd_clk_i),
            .rd_rst_i (rd_rst_i),
            .rd_data_o(rd_data_o),
            .push_i   (push_i),
            .pop_i    (pop_i),
            .empty_o  (empty_o),
            .full_o   (full_o),
            .a_empty_o(a_empty_o),
            .a_full_o (a_full_o)
        );

        assign data_cnt_o = '0;
    end else begin : g_fifo
        $error("Only sync or async FIFO_MODE is available!");
    end
endmodule
