module mixer #(
    parameter int IQ_NUM = 2,
    parameter int DATA_WIDTH = 16,
    parameter int PHASE_WIDTH = 32
) (
    input logic clk_i,
    input logic rstn_i,
    input logic en_i,

    input logic                   round_type_i,   // 1 - round to odd, 0 - round to even
    input logic [PHASE_WIDTH-1:0] phase_inc_i,
    input logic [PHASE_WIDTH-1:0] phase_offset_i,

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                              tvalid_o,
    output logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    logic                              dds_tvalid;
    logic [IQ_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;

    dds #(
        .IQ_NUM     (IQ_NUM),
        .DATA_WIDTH (DATA_WIDTH),
        .PHASE_WIDTH(PHASE_WIDTH)
    ) i_dds (
        .clk_i         (clk_i),
        .rstn_i        (rstn_i),
        .en_i          (en_i),
        .phase_inc_i   (phase_inc_i),
        .phase_offset_i(phase_offset_i),
        .tvalid_o      (dds_tvalid),
        .tdata_o       (dds_tdata)
    );

    localparam int CMULT_DELAY = 6;

    logic [IQ_NUM-1:0][2*DATA_WIDTH:0] mixed_tdata;
    logic                              mixed_tvalid;

    cmult #(
        .AWIDTH(DATA_WIDTH),
        .BWIDTH(DATA_WIDTH)
    ) i_cmult (
        .clk(clk_i),
        .ar (tdata_i[0]),
        .ai (tdata_i[1]),
        .br (dds_tdata[0]),
        .bi (dds_tdata[1]),
        .pr (mixed_tdata[0]),
        .pi (mixed_tdata[1])
    );

    shift_reg #(
        .DATA_WIDTH($bits(tvalid_i)),
        .DELAY     (CMULT_DELAY),
        .RESET_EN  (1)
    ) i_shift_reg (
        .clk_i (clk_i),
        .rstn_i(rstn_i),
        .en_i  (en_i),
        .data_i(tvalid_i),
        .data_o(mixed_tvalid)
    );

    round #(
        .CH_NUM        (IQ_NUM),
        .DATA_WIDTH_IN (2 * DATA_WIDTH + 1),
        .DATA_WIDTH_OUT(DATA_WIDTH)
    ) i_round (
        .clk_i     (clk_i),
        .rstn_i    (rstn_i),
        .odd_even_i(round_type_i),
        .tvalid_i  (mixed_tvalid & dds_tvalid),
        .tdata_i   (mixed_tdata),
        .tvalid_o  (tvalid_o),
        .tdata_o   (tdata_o)
    );

endmodule
