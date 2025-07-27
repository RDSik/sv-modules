/* verilator lint_off TIMESCALEMOD */
module dds #(
    parameter int PHASE_WIDTH = 16,
    parameter int DATA_WIDTH  = 16
) (
    input  logic                   clk_i,
    input  logic                   rstn_i,
    input  logic                   en_i,
    input  logic [PHASE_WIDTH-1:0] phase_inc_i,
    output logic [ DATA_WIDTH-1:0] sin_o
);

    localparam int SIN_NUM = 2 ** PHASE_WIDTH;
    localparam int A = 2 ** (DATA_WIDTH - 1) - 1;
    localparam real PI = 3.14159265359;

    logic [DATA_WIDTH-1:0] sin_lut[SIN_NUM];
    logic [PHASE_WIDTH-1:0] phase_acc;

    initial begin
        for (int i = 0; i < SIN_NUM; i++) begin
            sin_lut[i] = $rtoi(A * (1 + $sin(2 * PI * i / SIN_NUM)));
        end
    end

    always @(posedge clk_i) begin
        if (~rstn_i) begin
            phase_acc <= '0;
        end else if (en_i) begin
            phase_acc <= phase_acc + phase_inc_i;
        end
    end

    always_ff @(posedge clk_i) begin
        sin_o <= sin_lut[phase_acc];
    end

endmodule
