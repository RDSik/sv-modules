`timescale 1ns / 1ps

module sfir_tb ();

    localparam int DDS_NUM = 2;
    localparam int PHASE_INC[0:DDS_NUM-1] = '{2000, 200};
    localparam int PHASE_OFF[0:DDS_NUM-1] = '{0, 0};

    localparam int DATA_WIDTH = 16;
    localparam int COEF_WIDTH = 16;
    localparam int TAP_NUM = 28;
    localparam int IQ_NUM = 2;
    localparam logic ROUND_ODD_EVEN = 1;

    localparam int CLK_PER = 2;
    localparam int RESET_DELAY = 10;
    localparam int SIM_TIME = 1000;

    logic                                               clk_i;
    logic                                               rstn_i;
    logic [DDS_NUM-1:0][    IQ_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;
    logic [DDS_NUM-1:0]                                 dds_tvalid;
    logic [ IQ_NUM-1:0][DATA_WIDTH-1:0]                 fir_tdata_o;
    logic                                               fir_tvalid_o;
    logic [ IQ_NUM-1:0][DATA_WIDTH-1:0]                 noise;

    assign noise = (dds_tdata[0] + dds_tdata[1]) / 2;

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        rstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        rstn_i = 1'b1;
        repeat (SIM_TIME) @(posedge clk_i);
`ifdef VERILATOR
        $finish();
`else
        $stop();
`endif
    end

    initial begin
        $dumpfile("sfir_tb.vcd");
        $dumpvars(0, sfir_tb);
    end

    sfir_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH),
        .TAP_NUM   (TAP_NUM),
        .IQ_NUM    (IQ_NUM)
    ) i_sfir_top (
        .clk_i     (clk_i),
        .rstn_i    (rstn_i),
        .en_i      ('1),
        .odd_even_i(ROUND_ODD_EVEN),
        .tvalid_i  (&dds_tvalid),
        .tdata_i   (noise),
        .tvalid_o  (tvalid_o),
        .tdata_o   (tdata_o)
    );

    for (genvar dds_indx = 0; dds_indx < DDS_NUM; dds_indx++) begin : g_dds
        dds_compiler i_dds (
            .aclk               (clk_i),
            .aresetn            (rstn_i),
            .aclken             ('1),
            .s_axis_phase_tdata ({PHASE_OFF[dds_indx], PHASE_INC[dds_indx]}),
            .s_axis_phase_tvalid('1),
            .m_axis_tdata       (dds_tdata[dds_indx]),
            .m_axis_tvalid      (dds_tvalid[dds_indx])
        );
    end

endmodule
