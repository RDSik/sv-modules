`timescale 1ns / 1ps

module ddc_tb ();

    localparam int DDS_NUM = 2;
    localparam int PINC[0:DDS_NUM-1] = '{511, 263};

    localparam int IQ_NUM = 2;
    localparam int DECIMATION = 4;
    localparam logic ROUND_TYPE = 1;

    localparam int PHASE_WIDTH = 16;
    localparam int DATA_WIDTH = 16;
    localparam int COEF_WIDTH = 18;
    localparam int TAP_NUM = 28;

    localparam int CLK_PER = 2;
    localparam int RESET_DELAY = 10;
    localparam int SIM_TIME = 1000;

    logic                                               clk_i;
    logic                                               rstn_i;
    logic                                               en_i;
    logic [DDS_NUM-1:0]                                 dds_tvalid;
    logic [DDS_NUM-1:0][    IQ_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;
    logic                                               ddc_tvalid;
    logic [   IQ_NUM:0][DATA_WIDTH-1:0]                 ddc_tdata;
    logic [   IQ_NUM:0][DATA_WIDTH-1:0]                 noise;

    assign noise = (dds_tdata[0] + dds_tdata[1]) / 2;

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        en_i   = 1'b0;
        rstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        rstn_i = 1'b1;
        en_i   = 1'b1;
    end

    initial begin
        repeat (SIM_TIME) @(posedge clk_i);
`ifdef VERILATOR
        $finish();
`else
        $stop();
`endif
    end

    initial begin
        $dumpfile("ddc_tb.vcd");
        $dumpvars(0, ddc_tb);
    end

    ddc #(
        .IQ_NUM     (IQ_NUM),
        .DATA_WIDTH (DATA_WIDTH),
        .COEF_WIDTH (COEF_WIDTH),
        .PHASE_WIDTH(PHASE_WIDTH),
        .TAP_NUM    (TAP_NUM)
    ) dut (
        .clk_i         (clk_i),
        .rstn_i        (rstn_i),
        .en_i          (en_i),
        .round_type_i  (ROUND_TYPE),
        .decimation_i  (DECIMATION),
        .phase_inc_i   (0),
        .phase_offset_i(0),
        .tdata_i       (noise),
        .tvalid_i      (&dds_tvalid),
        .tvalid_o      (ddc_tvalid),
        .tdata_o       (ddc_tdata)
    );

    for (genvar dds_indx = 0; dds_indx < DDS_NUM; dds_indx++) begin : g_dds
        dds #(
            .IQ_NUM     (IQ_NUM),
            .DATA_WIDTH (DATA_WIDTH),
            .PHASE_WIDTH(PHASE_WIDTH)
        ) i_dds (
            .clk_i         (clk_i),
            .rstn_i        (rstn_i),
            .en_i          (en_i),
            .phase_inc_i   (PINC[dds_indx]),
            .phase_offset_i('0),
            .tvalid_o      (dds_tvalid[dds_indx]),
            .tdata_o       (dds_tdata[dds_indx])
        );
    end

endmodule
