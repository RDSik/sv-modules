/* verilator lint_off TIMESCALEMOD */
module dds #(
    parameter int PHASE_WIDTH = 32,
    parameter int DATA_WIDTH  = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic [PHASE_WIDTH-1:0] pinc_i,
    input logic [PHASE_WIDTH-1:0] poff_i,

    output logic                       tvalid_o,
    output logic [1:0][DATA_WIDTH-1:0] tdata_o
);

    logic [PHASE_WIDTH-1:0] poff_d;
    logic [PHASE_WIDTH-1:0] pinc_d;
    logic [PHASE_WIDTH-1:0] pinc_dd;
    logic                   dds_tvalid;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            dds_tvalid        <= '0;
            poff_d            <= '0;
            {pinc_dd, pinc_d} <= '0;
        end else if (en_i) begin
            dds_tvalid        <= 1'b1;
            poff_d            <= poff_i;
            {pinc_dd, pinc_d} <= {pinc_d, pinc_i};
        end
    end

    dds_compiler i_dds_compiler (
        .aclk               (clk_i),
        .aresetn            (~rst_i),
        .s_axis_phase_tvalid(dds_tvalid),
        .s_axis_phase_tdata ({poff_d, pinc_dd}),
        .m_axis_data_tvalid (tvalid_o),
        .m_axis_data_tdata  (tdata_o)
    );

endmodule
