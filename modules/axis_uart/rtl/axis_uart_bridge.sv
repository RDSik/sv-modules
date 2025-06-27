/* verilator lint_off TIMESCALEMOD */
module axis_uart_bridge #(
    parameter int   FIFO_DEPTH = 128,
    parameter int   MEM_DEPTH  = 8192,
    parameter int   BYTE_NUM   = 4,
    parameter int   BYTE_WIDTH = 8,
    parameter int   ADDR_WIDTH = 32,
    parameter logic SIM_EN     = 0,
    parameter int   MEM_WIDTH  = BYTE_NUM * BYTE_WIDTH
) (
    input  logic uart_rx_i,
    output logic uart_tx_o
);

logic                  clk_i;
logic                  arstn_i;
logic [ADDR_WIDTH-1:0] addr;
logic [MEM_WIDTH-1:0]  data_in;
logic [MEM_WIDTH-1:0]  data_out;
logic [BYTE_NUM-1:0]   wr_en;

axis_uart_bram_ctrl #(
    .BYTE_NUM   (BYTE_NUM  ),
    .BYTE_WIDTH (BYTE_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .FIFO_DEPTH (FIFO_DEPTH)
) i_axis_uart_bram_ctrl (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   ),
    .uart_rx_i  (uart_rx_i ),
    .uart_tx_o  (uart_tx_o ),
    .data_i     (data_in   ),
    .data_o     (data_out  ),
    .addr_o     (addr      ),
    .wr_en_o    (wr_en     )
);

if (SIM_EN) begin : g_sim
    bram_true_dp #(
        .BYTE_NUM   (BYTE_NUM   ),
        .BYTE_WIDTH (BYTE_WIDTH ),
        .ADDR_WIDTH (ADDR_WIDTH ),
        .MEM_DEPTH  (MEM_DEPTH  ),
        .MODE       ("NO_CHANGE")
    ) i_bram_true_dp (
        .a_clk_i    (clk_i      ),
        .a_en_i     (en_i       ),
        .a_wr_en_i  (wr_en_i    ),
        .a_addr_i   (addr_i     ),
        .a_data_i   (data_i     ),
        .a_data_o   (data_o     ),
        .b_clk_i    (clk_i      ),
        .b_en_i     (1'b1       ),
        .b_wr_en_i  (wr_en      ),
        .b_addr_i   (addr       ),
        .b_data_i   (data_out   ),
        .b_data_o   (data_in    )
    );
end else begin : g_synth
    zynq_bd_wrapper (
        .BRAM_PORTB_0_addr    (addr     ),
        .BRAM_PORTB_0_clk     (clk_i    ),
        .BRAM_PORTB_0_din     (data_out ),
        .BRAM_PORTB_0_dout    (data_in  ),
        .BRAM_PORTB_0_en      (1'b1     ),
        .BRAM_PORTB_0_rst     (~arstn_i ),
        .BRAM_PORTB_0_we      (wr_en    ),
        .FCLK_CLK0_0          (clk_i    ),
        .peripheral_aresetn_0 (arstn_i  ),
        .probe0_0             (arstn_i  ),
        .probe1_0             (uart_rx_i),
        .probe2_0             (uart_tx_o),
        .probe3_0             (addr     ),
        .probe4_0             (data_out ),
        .probe5_0             (data_in  ),
        .probe6_0             (wr_en    )
    );
end

endmodule
