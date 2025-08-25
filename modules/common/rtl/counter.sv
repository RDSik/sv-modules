/* verilator lint_off TIMESCALEMOD */
module counter #(
    parameter int CNT_WIDTH = 8
) (
    input logic clk_i,
    input logic rstn_i,
    input logic en_i,

    input logic [CNT_WIDTH-1:0] num_i,

    output logic cnt_done_o
);

    logic [CNT_WIDTH-1:0] cnt;

    always @(posedge clk_i) begin
        if (~rstn_i) begin
            cnt <= '0;
        end else if (en_i) begin
            if (cnt_done_o) begin
                cnt <= '0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    assign cnt_done_o = (cnt == num_i - 1);

endmodule
