/* verilator lint_off TIMESCALEMOD */
module spi_clk_gen #(
    parameter int DIVIDER_WIDTH = 32
) (
    input logic clk_i,
    input logic rstn_i,
    input logic enable_i,
    input logic cpol_i,

    input logic [DIVIDER_WIDTH-1:0] clk_divider_i,

    output logic edge_done_o,
    output logic neg_edge_o,
    output logic pos_edge_o,
    output logic clk_o
);

    localparam int EDGE_NUM = 16;  // need 16 edges to transmit 8 bits

    logic [$clog2(EDGE_NUM):0] edge_cnt;
    logic                      edge_done;

    logic [ DIVIDER_WIDTH-1:0] clk_cnt;
    logic                      clk_done;
    logic                      half_clk_done;
    logic                      clk_reg;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            clk_cnt <= '0;
        end else if (clk_done) begin
            clk_cnt <= '0;
        end else if (~edge_done_o) begin
            clk_cnt <= clk_cnt + 1'b1;
        end
    end

    assign clk_done      = (clk_cnt == clk_divider_i - 1);
    assign half_clk_done = (clk_cnt == (clk_divider_i / 2) - 1);

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            neg_edge_o <= 1'b0;
            pos_edge_o <= 1'b0;
            edge_cnt   <= '0;
            clk_reg    <= cpol_i;
        end else begin
            neg_edge_o <= 1'b0;
            pos_edge_o <= 1'b0;
            if (enable_i) begin
                edge_cnt <= '0;
            end else if (~edge_done_o) begin
                if (clk_done) begin
                    neg_edge_o <= 1'b1;
                    edge_cnt   <= edge_cnt + 1'b1;
                    clk_reg    <= ~clk_reg;
                end else if (half_clk_done) begin
                    pos_edge_o <= 1'b1;
                    edge_cnt   <= edge_cnt + 1'b1;
                    clk_reg    <= ~clk_reg;
                end
            end
        end
    end

    /* verilator lint_off WIDTHEXPAND */
    assign edge_done_o = (edge_cnt == EDGE_NUM);
    /* verilator lint_on WIDTHEXPAND */

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            clk_o <= cpol_i;
        end else begin
            clk_o <= clk_reg;
        end
    end

endmodule
