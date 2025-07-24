`timescale 1ns / 1ps

module sfir_tb ();

    localparam int DATA_WIDTH = 16;
    localparam int COE_WIDTH = 16;
    localparam int TAP_NUM = 66;
    localparam int PHASE_WIDTH = 8;
    localparam SIN_FILE = "sin_lut.mem";
    localparam int OUT_WIDTH = DATA_WIDTH + COE_WIDTH;

    localparam int CLK_PER = 2;
    localparam int RESET_DELAY = 10;
    localparam int SIM_TIME = 1000;
    localparam PHASE_INC_1 = PHASE_WIDTH'(2000);
    localparam PHASE_INC_2 = PHASE_WIDTH'(200);

    logic                  clk_i;
    logic                  rstn_i;
    logic [DATA_WIDTH-1:0] sin_out_1;
    logic [DATA_WIDTH-1:0] sin_out_2;
    logic [ OUT_WIDTH-1:0] fir_out;
    logic [DATA_WIDTH-1:0] noise;

    assign noise = (sin_out_1 + sin_out_2) / 2;

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


    sfir_even_symmetric_systolic_top #(
        .DATA_WIDTH(DATA_WIDTH),
        .COE_WIDTH (COE_WIDTH),
        .TAP_NUM   (TAP_NUM),
        .COEF      ()
    ) i_sfir_even_symmetric_systolic_top (
        .clk_i (clk_i),
        .data_i(noise),
        .fir_o (fir_out)
    );

    dds #(
        .PHASE_WIDTH(PHASE_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .SIN_FILE   (SIN_FILE)
    ) i_dds_1 (
        .clk_i      (clk_i),
        .rstn_i     (rstn_i),
        .en_i       (1'b1),
        .phase_inc_i(PHASE_INC_1),
        .sin_o      (sin_out_1)
    );

    dds #(
        .PHASE_WIDTH(PHASE_WIDTH),
        .DATA_WIDTH (DATA_WIDTH),
        .SIN_FILE   (SIN_FILE)
    ) i_dds_2 (
        .clk_i      (clk_i),
        .rstn_i     (rstn_i),
        .en_i       (1'b1),
        .phase_inc_i(PHASE_INC_2),
        .sin_o      (sin_out_2)
    );

endmodule
