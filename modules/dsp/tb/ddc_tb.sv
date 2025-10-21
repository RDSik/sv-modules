`timescale 1ns / 1ps

module ddc_tb ();

    localparam int DDS_NUM = 2;
    localparam logic [PHASE_WIDTH-1:0] FREQ[DDS_NUM-1:0] = '{50e6, 550e6};

    localparam int IQ_NUM = 2;
    localparam int DECIMATION = 4;
    localparam logic ROUND_TYPE = 1;

    localparam int PHASE_WIDTH = 16;
    localparam int DATA_WIDTH = 16;
    localparam int COEF_WIDTH = 18;
    localparam int TAP_NUM = 28;

    localparam int CLK_PER = 2;
    localparam int RESET_DELAY = 10;
    localparam int SIM_TIME = 100_000;

    logic                                               clk_i;
    logic                                               rstn_i;
    logic                                               en_i;
    logic [DDS_NUM-1:0]                                 dds_tvalid;
    logic [DDS_NUM-1:0][    IQ_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;
    logic                                               ddc_tvalid;
    logic [ IQ_NUM-1:0][DATA_WIDTH-1:0]                 ddc_tdata;
    logic [ IQ_NUM-1:0][DATA_WIDTH-1:0]                 noise;

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
        .phase_inc_i   ('0),
        .phase_offset_i('0),
        .tdata_i       (noise),
        .tvalid_i      (&dds_tvalid),
        .tvalid_o      (ddc_tvalid),
        .tdata_o       (ddc_tdata)
    );

    for (genvar dds_indx = 0; dds_indx < DDS_NUM; dds_indx++) begin : g_dds
        dds_compilter i_dds_compiler (
            .aclk               (clk_i),
            .aclken             (en_i),
            .aresetn            (rstn_i),
            .s_axis_phase_tvalid(en_i),
            .s_axis_phase_tdata (freq_to_phase(FREQ[dds_indx])),
            .m_axis_data_tvalid (dds_tdata[dds_indx]),
            .m_axis_data_tdata  (dds_tvalid[dds_indx])
        );
    end

    function logic [PHASE_WIDTH-1:0] freq_to_phase(logic [PHASE_WIDTH-1:0] freq);
        logic [PHASE_WIDTH-1:0] Fs = 100e6;
        begin
            freq_to_phase = (freq * 2 ** PHASE_WIDTH) / Fs;
        end
    endfunction

endmodule
