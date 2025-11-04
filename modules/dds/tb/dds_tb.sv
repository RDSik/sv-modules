module dds_tb ();

    localparam int IQ_NUM = 2;
    localparam int DATA_WIDTH = 16;
    localparam int PHASE_WIDTH = 14;
    // localparam DATA_PATH = "dds_dump_out.bin";

    localparam logic [31:0] FREQ = 20e6;
    localparam int CLK_PER = 2;
    localparam int RESET_DELAY = 10;
    localparam int SIM_TIME = 100_000;

    logic                              clk_i;
    logic                              rstn_i;
    logic                              en_i;
    logic                              tvalid_o;
    logic [IQ_NUM-1:0][DATA_WIDTH-1:0] tdata_o;

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
        $dumpfile("dds_tb.vcd");
        $dumpvars(0, dds_tb);
    end

    dds_wrap #(
        .IQ_NUM     (IQ_NUM),
        .PHASE_WIDTH(PHASE_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .IP_EN      (0)
    ) dut (
        .clk_i         (clk_i),
        .rstn_i        (rstn_i),
        .en_i          (en_i),
        .phase_inc_i   (freq_to_phase(FREQ)),
        .phase_offset_i('0),
        .tvalid_o      (tvalid_o),
        .tdata_o       (tdata_o)
    );

    function automatic logic [PHASE_WIDTH-1:0] freq_to_phase(logic [31:0] freq);
        logic [31:0] Fs = 100e6;
        logic [61:0] tmp;
        begin
            tmp = freq * (2 ** PHASE_WIDTH);
            freq_to_phase = tmp / Fs;
        end
    endfunction

endmodule
