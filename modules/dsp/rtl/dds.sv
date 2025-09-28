/* verilator lint_off TIMESCALEMOD */
module dds #(
    parameter int PHASE_WIDTH = 16,
    parameter int DATA_WIDTH  = 16
) (
    input logic clk_i,
    input logic rstn_i,
    input logic en_i,

    input logic [PHASE_WIDTH-1:0] phase_inc_i,

    output logic                         tvalid_o,
    output logic signed [DATA_WIDTH-1:0] tdata_o
);

    localparam int SIN_NUM = 2 ** PHASE_WIDTH;
    localparam int AMPL = 2 ** (DATA_WIDTH - 1) - 1;
    localparam real PI = 3.14159265359;

    logic [DATA_WIDTH-1:0] sin_lut[0:SIN_NUM-1];
    logic [PHASE_WIDTH-1:0] phase_acc;

    initial begin
        for (int i = 0; i < SIN_NUM; i++) begin
            /* verilator lint_off WIDTHTRUNC */
            sin_lut[i] = $rtoi(AMPL * (1 + $sin(2 * PI * i / SIN_NUM)));
            /* verilator lint_on WIDTHTRUNC */
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
        if (~rstn_i) begin
            tvalid_o <= 1'b0;
        end else begin
            if (en_i) begin
                tvalid_o <= 1'b1;
            end else begin
                tvalid_o <= 1'b0;
            end
        end
        tdata_o <= sin_lut[phase_acc];
    end

endmodule
