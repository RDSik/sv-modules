/* verilator lint_off TIMESCALEMOD */
module async_fifo #(
    parameter int FIFO_WIDTH   = 32,
    parameter int FIFO_DEPTH   = 64,
    parameter int CDC_REG_NUM  = 2,
    parameter int READ_LATENCY = 1,
    parameter     RAM_STYLE    = "block"
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
    output logic empty_o
);

    if (CDC_REG_NUM < 2) begin : g_reg_num_err
        $error("CDC_REG_NUM must greater or equal 2!");
    end

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
        .wr_rst_i  (wr_rst_i),
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
        .rd_rst_i  (rd_rst_i),
        .rd_en_i   (pop_i),
        .rq2_wptr_i(rq2_wptr),
        .rd_addr_o (rd_addr),
        .rd_ptr_o  (rd_ptr),
        .a_empty_o (a_empty_o),
        .empty_o   (empty_o)
    );

    ram_sdp #(
        .MEM_DEPTH   (FIFO_DEPTH),
        .BYTE_WIDTH  (FIFO_WIDTH),
        .BYTE_NUM    (1),
        .READ_LATENCY(READ_LATENCY),
        .RAM_STYLE   (RAM_STYLE),
        .MEM_MODE    ("read_first")
    ) i_ram_sdp (
        .a_clk_i  (wr_clk_i),
        .a_en_i   (wr_en),
        .a_wr_en_i(wr_en),
        .a_addr_i (wr_addr),
        .a_data_i (wr_data_i),
        .b_clk_i  (rd_clk_i),
        .b_en_i   (rd_en),
        .b_addr_i (rd_addr),
        .b_data_o (rd_data_o)
    );

    shift_reg #(
        .RESET_EN  (1),
        .DATA_WIDTH(ADDR_WIDTH + 1),
        .DELAY     (CDC_REG_NUM),
        .SRL_STYLE ("register")
    ) wr_shift_reg (
        .clk_i (wr_clk_i),
        .rst_i (wr_rst_i),
        .en_i  (1'b1),
        .data_i(rd_ptr),
        .data_o(wq2_rptr)
    );

    shift_reg #(
        .RESET_EN  (1),
        .DATA_WIDTH(ADDR_WIDTH + 1),
        .DELAY     (CDC_REG_NUM),
        .SRL_STYLE ("register")
    ) rd_shift_reg (
        .clk_i (rd_clk_i),
        .rst_i (rd_rst_i),
        .en_i  (1'b1),
        .data_i(wr_ptr),
        .data_o(rq2_wptr)
    );

endmodule
