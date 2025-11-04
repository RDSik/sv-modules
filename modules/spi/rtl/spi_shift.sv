/* verilator lint_off TIMESCALEMOD */
module spi_shift #(
    parameter int DATA_WIDTH = 8
) (
    input logic clk_i,
    input logic rstn_i,
    input logic enable_i,
    input logic cpha_i,

    input logic pos_edge_i,
    input logic neg_edge_i,

    input  logic [DATA_WIDTH-1:0] data_i,
    output logic [DATA_WIDTH-1:0] data_o,

    input  logic miso_i,
    output logic mosi_o
);

    localparam int DATA_CNT_WIDTH = $clog2(DATA_WIDTH);

    logic [    DATA_WIDTH-1:0] tx_data;
    logic [DATA_CNT_WIDTH-1:0] tx_bit_cnt;

    logic [    DATA_WIDTH-1:0] rx_data;
    logic [DATA_CNT_WIDTH-1:0] rx_bit_cnt;
    logic                      rx_bit_done;

    logic                      enable_d;

    always_ff @(posedge clk_i) begin
        enable_d <= enable_i;
    end

    // MISO data---------------------------------------------------
    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            rx_bit_cnt <= '0;
            rx_data    <= '0;
        end else if (rx_bit_done) begin
            rx_bit_cnt <= '0;
        end else if ((pos_edge_i & ~cpha_i) || (neg_edge_i & cpha_i)) begin
            rx_bit_cnt <= rx_bit_cnt + 1'b1;
            rx_data    <= {rx_data[DATA_WIDTH-2:0], miso_i};
        end
    end

    /* verilator lint_off WIDTHEXPAND */
    assign rx_bit_done = (rx_bit_cnt == DATA_WIDTH - 1);
    /* verilator lint_on WIDTHEXPAND */

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            /* verilator lint_off WIDTHTRUNC */
            tx_bit_cnt <= DATA_WIDTH - 1;
            mosi_o     <= 1'b0;
        end else if (enable_i) begin
            tx_bit_cnt <= DATA_WIDTH - 1;
        end else if (enable_d & ~cpha_i) begin // Catch the case where we start transaction and CPHA = 0
            tx_bit_cnt <= DATA_WIDTH - 2;
            /* verilator lint_on WIDTHTRUNC */
            mosi_o <= tx_data[DATA_WIDTH-1];
        end else if ((pos_edge_i & cpha_i) || (neg_edge_i & ~cpha_i)) begin
            tx_bit_cnt <= tx_bit_cnt - 1'b1;
            mosi_o     <= tx_data[tx_bit_cnt];
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            tx_data <= '0;
        end else if (enable_i) begin
            tx_data <= data_i;
        end
    end

    assign data_o = rx_data;

endmodule
