/* verilator lint_off TIMESCALEMOD */
module axis_uart_bridge #(
    parameter int BYTE_NUM   = 4,
    parameter int BYTE_WIDTH = 8,
    parameter int ADDR_WIDTH = 32,
    parameter int MEM_WIDTH  = BYTE_NUM * BYTE_WIDTH
) (
    input  logic                  clk_i,
    input  logic                  arstn_i,

    input  logic                  uart_rx_i,
    output logic                  uart_tx_o,

    input  logic                  en_i,
    input  logic [BYTE_NUM-1:0]   wr_en_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [MEM_WIDTH-1:0]  data_i,
    output logic [MEM_WIDTH-1:0]  data_o
);

localparam int FIFO_DEPTH = 128;

logic [BYTE_NUM-1:0]   wr_en;
logic [ADDR_WIDTH-1:0] addr;
logic [MEM_WIDTH-1:0]  data_in;
logic [MEM_WIDTH-1:0]  data_out;

axis_uart_bram_ctrl #(
    .BYTE_NUM   (BYTE_NUM  ),
    .BYTE_WIDTH (BYTE_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH)
) i_axis_uart_bram_ctrl (
    .clk_i      (clk_i     ),
    .uart_rx_i  (uart_rx_i ),
    .uart_tx_o  (uart_tx_o ),
    .data_i     (data_in   ),
    .data_o     (data_out  ),
    .addr_o     (addr      ),
    .wr_en_o    (wr_en     )
);

bram_true_dp #(
    .BYTE_NUM   (BYTE_NUM  ),
    .BYTE_WIDTH (BYTE_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH)
) i_bram_true_dp (
    .a_clk_i    (clk_i     ),
    .a_en_i     (en_i      ),
    .a_wr_en_i  (wr_en_i   ),
    .a_addr_i   (addr_i    ),
    .a_data_i   (data_i    ),
    .a_data_o   (data_o    ),
    .b_clk_i    (clk_i     ),
    .b_en_i     (1'b1      ),
    .b_wr_en_i  (wr_en     ),
    .b_addr_i   (addr      ),
    .b_data_i   (data_out  ),
    .b_data_o   (data_in   )
);

endmodule
