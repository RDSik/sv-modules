/* verilator lint_off TIMESCALEMOD */
module resampler #(
    parameter       COE_FILE         = "fir.mem",
    parameter logic INTERPOLATION_EN = 1,
    parameter logic DECIMATION_EN    = 1,
    parameter int   CH_NUM           = 2,
    parameter int   DATA_WIDTH       = 16,
    parameter int   COEF_WIDTH       = 18,
    parameter int   TAP_NUM          = 16
) (
    axis_if.slave s_axis,

    input logic en_i,

    input logic [           2:0] round_type_i,
    input logic [DATA_WIDTH-1:0] decimation_i,
    input logic [DATA_WIDTH-1:0] interpolation_i,

    output logic                                     tvalid_o,
    output logic signed [CH_NUM-1:0][DATA_WIDTH-1:0] tdata_o
);

    typedef enum logic {
        IDLE   = 1'b0,
        INTERP = 1'b1
    } state_e;

    state_e state;

    logic   clk_i;
    logic   rst_i;

    assign clk_i = s_axis.clk_i;
    assign rst_i = s_axis.rst_i;

    logic                              int_tvalid;
    logic [CH_NUM-1:0][DATA_WIDTH-1:0] int_tdata;

    if (INTERPOLATION_EN) begin : g_int_en
        assign s_axis.tready = (state == IDLE) && en_i && ~rst_i;

        logic [$clog2(DATA_WIDTH)-1:0] int_cnt;
        logic                          int_cnt_done;

        assign int_cnt_done = (int_cnt == interpolation_i - 1);

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                int_tvalid <= '0;
                int_cnt    <= '0;
                state      <= IDLE;
            end else if (en_i) begin
                unique case (state)
                    IDLE: begin
                        if (s_axis.tvalid) begin
                            int_tdata  <= s_axis.tdata;
                            int_tvalid <= s_axis.tvalid;
                            state      <= INTERP;
                        end
                    end
                    INTERP: begin
                        int_tdata <= '0;
                        if (int_cnt_done) begin
                            int_cnt    <= '0;
                            int_tvalid <= '0;
                            state      <= IDLE;
                        end else begin
                            int_cnt    <= int_cnt + 1'b1;
                            int_tvalid <= 1'b1;
                        end
                    end
                endcase
            end
        end
    end else begin : g_int_disable
        assign s_axis.tready = en_i & ~rst_i;
        assign int_tdata     = s_axis.tdata;
        assign int_tvalid    = s_axis.tvalid;
    end

    localparam int FIR_WIDTH = DATA_WIDTH + COEF_WIDTH;

    logic                             fir_tvalid;
    logic [CH_NUM-1:0][FIR_WIDTH-1:0] fir_tdata;

    sfir #(
        .CH_NUM    (CH_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH),
        .TAP_NUM   (TAP_NUM),
        .COE_FILE  (COE_FILE)
    ) i_sfir (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .en_i    (en_i),
        .tvalid_i(int_tvalid),
        .tdata_i (int_tdata),
        .tvalid_o(fir_tvalid),
        .tdata_o (fir_tdata)
    );

    logic dec_tvalid;

    if (DECIMATION_EN) begin : g_dec_en
        logic [$clog2(DATA_WIDTH)-1:0] dec_cnt;
        logic                          dec_cnt_done;

        assign dec_cnt_done = (dec_cnt == decimation_i - 1);

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                dec_cnt <= '0;
            end else if (en_i) begin
                if (fir_tvalid) begin
                    if (dec_cnt_done) begin
                        dec_cnt <= '0;
                    end else begin
                        dec_cnt <= dec_cnt + 1'b1;
                    end
                end
            end
        end

        assign dec_tvalid = fir_tvalid && (dec_cnt == '0);
    end else begin : g_dec_disable
        assign dec_tvalid = fir_tvalid;
    end

    round #(
        .CH_NUM  (CH_NUM),
        .BITS_IN (FIR_WIDTH),
        .BITS_OUT(DATA_WIDTH)
    ) i_round (
        .clk_i           (clk_i),
        .rst_i           (rst_i),
        .round_to_zero   (round_type_i[0]),
        .round_to_nearest(round_type_i[1]),
        .trunc           (round_type_i[2]),
        .tvalid_i        (dec_tvalid),
        .tdata_i         (fir_tdata),
        .tvalid_o        (tvalid_o),
        .tdata_o         (tdata_o),
        .err_o           ()
    );

endmodule
