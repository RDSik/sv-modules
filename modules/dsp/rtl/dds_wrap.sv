/* verilator lint_off TIMESCALEMOD */
module dds_wrap #(
    parameter       DATA_PATH   = "dds_out.bin",
    parameter int   IQ_NUM      = 2,
    parameter int   PHASE_WIDTH = 14,
    parameter int   DATA_WIDTH  = 16,
    parameter logic IP_EN       = 1
) (
    input logic clk_i,
    input logic rst_i,
    input logic en_i,

    input logic [PHASE_WIDTH-1:0] phase_inc_i,
    input logic [PHASE_WIDTH-1:0] phase_offset_i,

    output logic                                     tvalid_o,
    output logic signed [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    if (IP_EN) begin : g_ip_en
        logic dds_tvalid;

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                dds_tvalid <= 1'b0;
            end else if (en_i) begin
                dds_tvalid <= 1'b1;
            end
        end

        dds_compiler i_dds_compiler (
            .aclk               (clk_i),
            .aresetn            (~rst_i),
            .s_axis_phase_tvalid(dds_tvalid),
            .s_axis_phase_tdata ({phase_offset_i, phase_inc_i}),
            .m_axis_data_tvalid (tvalid_o),
            .m_axis_data_tdata  (tdata_o)
        );
    end else begin : g_custom
        dds #(
            .IQ_NUM     (IQ_NUM),
            .PHASE_WIDTH(PHASE_WIDTH),
            .DATA_WIDTH (DATA_WIDTH),
            .DATA_PATH  (DATA_PATH)
        ) i_dds (
            .clk_i         (clk_i),
            .rst_i         (rst_i),
            .en_i          (en_i),
            .phase_inc_i   (phase_inc_i),
            .phase_offset_i(phase_offset_i),
            .tvalid_o      (tvalid_o),
            .tdata_o       (tdata_o)
        );
    end

endmodule
