module test_signal_gen #(
    parameter int CH_NUM      = 2,
    parameter int PHASE_WIDTH = 32,
    parameter int DATA_WIDTH  = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic round_type_i,

    input logic [ DATA_WIDTH-1:0] ampl_i,
    input logic [PHASE_WIDTH-1:0] pinc_i,
    input logic [PHASE_WIDTH-1:0] poff_i,

    output logic                              tvalid_o,
    output logic [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_o,

    output logic ovf_o
);

    logic [CH_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;
    logic                              dds_tvalid;

    dds #(
        .PHASE_WIDTH(PHASE_WIDTH),
        .DATA_WIDTH (DATA_WIDTH)
    ) i_dds (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .en_i    (en_i),
        .pinc_i  (pinc_i),
        .poff_i  (poff_i),
        .tdata_o (dds_tdata),
        .tvalid_o(dds_tvalid)
    );

    amplitude #(
        .CH_NUM    (CH_NUM),
        .DATA_WIDTH(DATA_WIDTH)
    ) i_amplitude (
        .clk_i       (clk_i),
        .rst_i       (rst_i),
        .round_type_i(round_type_i),
        .ampl_i      (ampl_i),
        .tdata_i     (dds_tdata),
        .tvalid_i    (dds_tvalid),
        .tdata_o     (tdata_o),
        .tvalid_o    (tvalid_o),
        .ovf_o       (ovf_o)
    );

endmodule
