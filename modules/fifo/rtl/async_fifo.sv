/* verilator lint_off TIMESCALEMOD */
module async_fifo #(
    parameter int FIFO_WIDTH  = 32,
    parameter int FIFO_DEPTH  = 64,
    parameter int CDC_REG_NUM = 2,
    parameter     FIFO_TYPE   = "block"
) (
    input logic                  wr_clk_i,
    input logic                  wr_rstn_i,
    input logic [FIFO_WIDTH-1:0] wr_data_i,

    input  logic                  rd_clk_i,
    input  logic                  rd_rstn_i,
    output logic [FIFO_WIDTH-1:0] rd_data_o,

    input  logic push_i,
    input  logic pop_i,
    output logic a_full_o,
    output logic full_o,
    output logic a_empty_o,
    output logic empty_o
);

    localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);

    logic [ADDR_WIDTH-1:0] wr_addr;
    logic [  ADDR_WIDTH:0] wr_ptr;
    logic [  ADDR_WIDTH:0] rq2_wptr;
    logic                  wr_en;

    logic [ADDR_WIDTH-1:0] rd_addr;
    logic [  ADDR_WIDTH:0] rd_ptr;
    logic [  ADDR_WIDTH:0] wq2_rptr;
    logic                  rd_en;

    assign wr_en = push_i & ~full_o;
    assign rd_en = pop_i & ~empty_o;

    wr_ptr_full #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) i_wr_ptr_full (
        .wr_clk_i  (wr_clk_i),
        .wr_rstn_i (wr_rstn_i),
        .wr_en_i   (push_i),
        .wq2_rptr_i(wq2_rptr),
        .wr_addr_o (wr_addr),
        .wr_ptr_o  (wr_ptr),
        .a_full_o  (a_full_o),
        .full_o    (full_o)
    );

    rd_ptr_empty #(
        .ADDR_WIDTH(ADDR_WIDTH)
    ) i_rd_ptr_empty (
        .rd_clk_i  (rd_clk_i),
        .rd_rstn_i (rd_rstn_i),
        .rd_en_i   (pop_i),
        .rq2_wptr_i(rq2_wptr),
        .rd_addr_o (rd_addr),
        .rd_ptr_o  (rd_ptr),
        .a_empty_o (a_empty_o),
        .empty_o   (empty_o)
    );

    ram_dp_2clk #(
        .MEM_WIDTH(FIFO_WIDTH),
        .MEM_DEPTH(FIFO_DEPTH),
        .MEM_TYPE (FIFO_TYPE)
    ) i_ram_dp_2clk (
        .wr_clk_i (wr_clk_i),
        .wr_en_i  (wr_en),
        .wr_addr_i(wr_addr),
        .wr_data_i(wr_data_i),
        .rd_clk_i (rd_clk_i),
        .rd_en_i  (rd_en),
        .rd_addr_i(rd_addr),
        .rd_data_o(rd_data_o)
    );

    localparam int SEL_WIDTH = $clog2(CDC_REG_NUM);
    logic [SEL_WIDTH-1:0] sel;
    assign sel = SEL_WIDTH'(CDC_REG_NUM - 1);

    shift_reg #(
        .RESET_EN  (1),
        .DATA_WIDTH(ADDR_WIDTH + 1),
        .DELAY     (CDC_REG_NUM),
        .SEL_WIDTH (SEL_WIDTH)
    ) wr_shift_reg (
        .clk_i (wr_clk_i),
        .rstn_i(wr_rstn_i),
        .en_i  (1'b1),
        .sel_i (sel),
        .data_i(rd_ptr),
        .data_o(wq2_rptr)
    );

    shift_reg #(
        .RESET_EN  (1),
        .DATA_WIDTH(ADDR_WIDTH + 1),
        .DELAY     (CDC_REG_NUM),
        .SEL_WIDTH (SEL_WIDTH)
    ) rd_shift_reg (
        .clk_i (rd_clk_i),
        .rstn_i(rd_rstn_i),
        .en_i  (1'b1),
        .sel_i (sel),
        .data_i(wr_ptr),
        .data_o(rq2_wptr)
    );

endmodule
