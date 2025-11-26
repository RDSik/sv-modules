/* verilator lint_off TIMESCALEMOD */
module dds #(
    parameter int IQ_NUM      = 2,
    parameter int PHASE_WIDTH = 14,
    parameter int DATA_WIDTH  = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic [PHASE_WIDTH-1:0] phase_inc_i,
    input logic [PHASE_WIDTH-1:0] phase_offset_i,

    output logic                                     tvalid_o,
    output logic signed [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    if (IQ_NUM != 2) begin : g_iq_num_err
        $error("IQ_NUM must be 2!");
    end

    localparam int SIN_NUM = 2 ** PHASE_WIDTH;
    localparam int AMPL = 2 ** (DATA_WIDTH - 1) - 1;
    localparam real PI = 3.14159265359;

    logic [DATA_WIDTH-1:0] sin_lut[0:SIN_NUM-1];

    initial begin
        for (int i = 0; i < SIN_NUM; i++) begin
            /* verilator lint_off WIDTHTRUNC */
            sin_lut[i] = $rtoi(AMPL * (1 + $sin(2 * PI * i / SIN_NUM)));
            /* verilator lint_on WIDTHTRUNC */
        end
    end

    logic [PHASE_WIDTH-1:0] phase_acc;
    logic [PHASE_WIDTH-1:0] lut_addr_i;
    logic [PHASE_WIDTH-1:0] lut_addr_q;

    assign lut_addr_i = phase_acc + phase_offset_i;
    assign lut_addr_q = lut_addr_i + (SIN_NUM / 4);

    always @(posedge clk_i) begin
        if (rst_i) begin
            phase_acc <= '0;
        end else if (en_i) begin
            phase_acc <= phase_acc + phase_inc_i;
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            tvalid_o <= 1'b0;
        end else begin
            tvalid_o <= en_i;
        end
        tdata_o <= {sin_lut[lut_addr_q], sin_lut[lut_addr_i]};
    end

endmodule
