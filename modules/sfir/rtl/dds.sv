/* verilator lint_off TIMESCALEMOD */
module dds #(
    parameter int PHASE_WIDTH = 8,
    parameter int DATA_WIDTH  = 16,
    parameter     SIN_FILE    = "sin_lut.mem"
) (
    input  logic                   clk_i,
    input  logic                   rstn_i,
    input  logic                   en_i,
    input  logic [PHASE_WIDTH-1:0] phase_inc_i,
    output logic [ DATA_WIDTH-1:0] sin_o
);

    localparam int SIN_NUM = 2 ** PHASE_WIDTH;

    logic [PHASE_WIDTH-1:0] phase_acc;

    always @(posedge clk_i) begin
        if (~rstn_i) begin
            phase_acc <= '0;
        end else if (en_i) begin
            phase_acc <= phase_acc + phase_inc_i;
        end
    end

    ram #(
        .MEM_FILE (SIN_FILE),
        .MEM_DEPTH(SIN_NUM),
        .MEM_WIDTH(DATA_WIDTH),
        .MEM_TYPE ("block")
    ) i_ram (
        .clk_i (clk_i),
        .addr_i(phase_acc),
        .data_i(),
        .data_o(sin_o)
    );

endmodule
