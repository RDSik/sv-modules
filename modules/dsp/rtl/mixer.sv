module mixer #(
    parameter int   IQ_NUM      = 2,
    parameter int   PHASE_WIDTH = 14,
    parameter int   DATA_WIDTH  = 16,
    parameter int   ADDR_WIDTH  = 14,
    parameter logic DDS_IP_EN   = 0
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic [            2:0] round_type_i,
    input logic [PHASE_WIDTH-1:0] phase_inc_i,
    input logic [PHASE_WIDTH-1:0] phase_offset_i,

    input logic                              tvalid_i,
    input logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_i,

    output logic                              tvalid_o,
    output logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    logic                              dds_tvalid;
    logic [IQ_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;


    logic                              dds_start;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            dds_start <= 1'b0;
        end else if (en_i) begin
            dds_start <= 1'b1;
        end
    end

    dds_compiler i_dds_compiler (
        .aclk               (clk_i),
        .aresetn            (~rst_i),
        .s_axis_phase_tvalid(dds_start),
        .s_axis_phase_tdata ({phase_offset_i, phase_inc_i}),
        .m_axis_data_tvalid (dds_tvalid),
        .m_axis_data_tdata  (dds_tdata)
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
        .RESET_EN  (1),
        .SRL_STYLE ("register")
    ) i_shift_reg (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .en_i  (en_i),
        .data_i(tvalid_i),
        .data_o(mixed_tvalid)
    );

    round #(
        .CH_NUM  (IQ_NUM),
        .BITS_IN (2 * DATA_WIDTH + 1),
        .BITS_OUT(DATA_WIDTH)
    ) i_round (
        .clk_i           (clk_i),
        .rst_i           (rst_i),
        .round_to_zero   (round_type_i[0]),
        .round_to_nearest(round_type_i[1]),
        .trunc           (round_type_i[2]),
        .tvalid_i        (mixed_tvalid & dds_tvalid),
        .tdata_i         (mixed_tdata),
        .tvalid_o        (tvalid_o),
        .tdata_o         (tdata_o),
        .err_o           ()
    );

endmodule
