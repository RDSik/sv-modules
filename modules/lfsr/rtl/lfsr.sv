/* verilator lint_off TIMESCALEMOD */
module lfsr #(
    parameter int DATA_WIDTH = 16
) (
    input  logic                  clk_i,
    input  logic                  rstn_i,
    input  logic                  en_i,
    input  logic [DATA_WIDTH-1:0] seed_i,
    input  logic [DATA_WIDTH-1:0] poly_i,
    output logic [DATA_WIDTH-1:0] data_o
);

    logic feedback;

    assign feedback = ^(data_o & poly_i);

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            data_o <= seed_i;
        end else if (en_i) begin
            data_o <= {data_o[DATA_WIDTH-2:0], feedback};
        end
    end

endmodule
