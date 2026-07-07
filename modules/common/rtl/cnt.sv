module cnt #(
    parameter int MAX_VAL = 32
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    output logic [$clog2(MAX_VAL)-1:0] cnt_o,
    output logic                       cnt_last_o
);

    logic [$clog2(MAX_VAL)-1:0] cnt;
    logic                       cnt_last;

    assign cnt_last = (cnt == (MAX_VAL - 1));

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            cnt <= '0;
        end else if (en_i) begin
            if (cnt_last) begin
                cnt <= '0;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end

    assign cnt_o      = cnt;
    assign cnt_last_o = cnt_last;

endmodule
