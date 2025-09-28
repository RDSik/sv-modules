`timescale 1ns / 1ps

module fir_filter_tb ();

    localparam int DDS_NUM = 2;
    localparam int PHASE_INC[0:DDS_NUM-1] = '{2000, 200};

    localparam int PHASE_WIDTH = 16;
    localparam int DATA_WIDTH = 16;
    localparam int COEF_WIDTH = 18;
    localparam int TAP_NUM = 28;

    localparam int CLK_PER = 2;
    localparam int RESET_DELAY = 10;
    localparam int SIM_TIME = 1000;

    logic                                          clk_i;
    logic                                          rstn_i;
    logic [           DDS_NUM-1:0][DATA_WIDTH-1:0] dds_tdata;
    logic [           DDS_NUM-1:0]                 dds_tvalid;
    logic [        DATA_WIDTH-1:0]                 fir_tdata_o;
    logic                                          fir_tvalid_o;
    logic [DDS_NUM*DATA_WIDTH-1:0]                 noise;

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
        $dumpfile("fir_filter_tb.vcd");
        $dumpvars(0, fir_filter_tb);
    end

    fir_filter #(
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH),
        .TAP_NUM   (TAP_NUM)
    ) i_fir_filter (
        .clk_i   (clk_i),
        .rstn_i  (rstn_i),
        .tvalid_i(&dds_tvalid),
        .tdata_i (noise),
        .tvalid_o(tvalid_o),
        .tdata_o (tdata_o)
    );

    for (genvar dds_indx = 0; dds_indx < DDS_NUM; dds_indx++) begin : g_dds
        dds #(
            .DATA_WIDTH (DATA_WIDTH),
            .PHASE_WIDTH(PHASE_WIDTH)
        ) i_dds (
            .clk_i      (clk_i),
            .rstn_i     (rstn_i),
            .en_i       ('1),
            .phase_inc_i(PHASE_INC[dds_indx]),
            .tvalid_o   (dds_tvalid[dds_indx]),
            .tdata_o    (dds_tdata[dds_indx])
        );
    end

endmodule
