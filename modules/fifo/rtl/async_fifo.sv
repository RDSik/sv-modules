module async_fifo #(
    parameter int FIFO_WIDTH  = 32,
    parameter int FIFO_DEPTH  = 64,
    parameter int CDC_REG_NUM = 2
) (
    input  logic                  wr_clk_i,
    input  logic                  wr_arstn_i,
    input  logic [FIFO_WIDTH-1:0] wr_data_i,

    input  logic                  rd_clk_i,
    input  logic                  rd_arstn_i,
    output logic [FIFO_WIDTH-1:0] rd_data_o,

    input  logic                  push_i,
    input  logic                  pop_i,
    output logic                  full_o,
    output logic                  empty_o
);

localparam int ADDR_WIDTH = $clog2(FIFO_DEPTH);
localparam int DELAY      = 2;

logic [ADDR_WIDTH-1:0] wr_addr;
logic [ADDR_WIDTH:0]   wr_ptr;
logic [ADDR_WIDTH:0]   wr_sync_ptr;
logic                  wr_en;

logic [ADDR_WIDTH-1:0] rd_addr;
logic [ADDR_WIDTH:0]   rd_ptr;
logic [ADDR_WIDTH:0]   rd_sync_ptr;
logic                  rd_en;

assign wr_en = push_i & ~full_o;
assign rd_en = pop_i & ~empty_o;

wr_ptr_full #(
    .ADDR_WIDTH    (ADDR_WIDTH )
) i_wr_ptr_full (
    .wr_en_i       (push_i     ),
    .wr_clk_i      (wr_clk_i   ),
    .wr_arstn_i    (wr_arstn_i ),
    .wr_addr_o     (wr_addr    ),
    .rd_sync_ptr_i (rd_sync_ptr),
    .wr_ptr_o      (wr_ptr     ),
    .full_o        (full_o     )
);

rd_ptr_empty #(
    .ADDR_WIDTH    (ADDR_WIDTH )
) i_rd_ptr_empty (
    .rd_clk_i      (rd_clk_i   ),
    .rd_arstn_i    (rd_arstn_i ),
    .rd_en_i       (pop_i      ),
    .rd_addr_o     (rd_addr    ),
    .wr_sync_ptr_i (wr_sync_ptr),
    .rd_ptr_o      (rd_ptr     ),
    .empty_o       (empty_o    )
);

bram_dp #(
    .MEM_WIDTH   (FIFO_WIDTH ),
    .MEM_DEPTH   (FIFO_DEPTH )
) i_bram_dp (
    .wr_clk_i    (wr_clk_i   ),
    .wr_en_i     (wr_en      ),
    .wr_addr_i   (wr_addr    ),
    .wr_data_i   (wr_data_i  ),
    .rd_clk_i    (rd_clk_i   ),
    .rd_en_i     (rd_en      ),
    .rd_addr_i   (rd_addr    ),
    .rd_data_o   (rd_data_o  )
);

shift_reg #(
    .DATA_WIDTH (ADDR_WIDTH+1),
    .DELAY      (CDC_REG_NUM )
) wr_shift_reg (
    .clk_i      (wr_clk_i    ),
    .arstn_i    (wr_arstn_i  ),
    .en_i       (1'b1        ),
    .data_i     (rd_ptr      ),
    .data_o     (wr_sync_ptr )
);

shift_reg #(
    .DATA_WIDTH (ADDR_WIDTH+1),
    .DELAY      (CDC_REG_NUM )
) rd_shift_reg (
    .clk_i      (rd_clk_i    ),
    .arstn_i    (rd_arstn_i  ),
    .en_i       (1'b1        ),
    .data_i     (wr_ptr      ),
    .data_o     (rd_sync_ptr )
);

endmodule
