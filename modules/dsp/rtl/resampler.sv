/* verilator lint_off TIMESCALEMOD */
module resampler #(
    parameter logic INTERPOLATION_EN = 1,
    parameter logic DECIMATION_EN    = 1,
    parameter int CH_NUM             = 2,
    parameter int DATA_WIDTH         = 16,
    parameter int COEF_WIDTH         = 18,
    parameter int TAP_NUM            = 28,
    // verilog_format: off
    parameter int COEF         [0:TAP_NUM-1] = '{
        560, 608, -120, -354, -34, 538, 40, -560,
        -250, 692, 412, -710, -704, 740, 1014,  -662,
        -1436, 514, 1936, -198, -2608, -354, 3572, 1438,
        -5354, -4176, 11198, 27938}
    // verilog_format: on
) (
    axis_if.slave s_axis,

    input logic en_i,

    input logic [DATA_WIDTH-1:0] decimation_i,
    input logic [DATA_WIDTH-1:0] interpolation_i,

    output logic                                                tvalid_o,
    output logic signed [CH_NUM-1:0][DATA_WIDTH+COEF_WIDTH-1:0] tdata_o
);

    typedef enum logic {
        IDLE   = 1'b0,
        INTERP = 1'b1
    } state_e;

    state_e state;

    logic   clk_i;
    logic   rstn_i;

    assign clk_i  = s_axis.clk_i;
    assign rstn_i = s_axis.rstn_i;

    logic                              int_tvalid;
    logic [CH_NUM-1:0][DATA_WIDTH-1:0] int_tdata;

    if (INTERPOLATION_EN) begin
        assign s_axis.tready = (state == IDLE) && rstn_i;

        logic [$clog2(DATA_WIDTH)-1:0] int_cnt;
        logic                          int_cnt_done;

        assign int_cnt_done = (int_cnt == interpolation_i - 1);

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                int_cnt <= '0;
            end else if (en_i) begin
                if (state == INTERP) begin
                    if (int_cnt_done) begin
                        int_cnt <= '0;
                    end else begin
                        int_cnt <= int_cnt + 1'b1;
                    end
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
                int_tvalid <= 1'b0;
                state      <= IDLE;
            end else begin
                unique case (state)
                    IDLE: begin
                        if (s_axis.tvalid) begin
                            int_tdata  <= s_axis.tdata;
                            int_tvalid <= s_axis.tvalid;
                            state      <= INTERP;
                        end
                    end
                    INTERP: begin
                        int_tdata  <= '0;
                        int_tvalid <= '1;
                        if (int_cnt_done) begin
                            state <= IDLE;
                        end
                    end
                endcase
            end
        end
    end else begin
        assign s_axis.tready = rstn_i;
        assign int_tdata     = s_axis.tdata;
        assign int_tvalid    = s_axis.tvalid;
    end

    fir_filter #(
        .CH_NUM    (IQ_NUM),
        .DATA_WIDTH(DATA_WIDTH),
        .COEF_WIDTH(COEF_WIDTH),
        .TAP_NUM   (TAP_NUM),
        .COEF      (COEF)
    ) i_fir_filter (
        .clk_i   (clk_i),
        .rstn_i  (rstn_i),
        .en_i    (en_i),
        .tvalid_i(int_tvalid),
        .tdata_i (int_tdata),
        .tvalid_o(fir_tvalid),
        .tdata_o (fir_tdata)
    );

    logic dec_tvalid;

    if (DECIMATION_EN) begin
        logic [$clog2(DATA_WIDTH)-1:0] dec_cnt;
        logic                          dec_cnt_done;

        assign dec_cnt_done = (dec_cnt == decimation_i - 1);

        always_ff @(posedge clk_i) begin
            if (~rstn_i) begin
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
    end else begin
        assign dec_tvalid = fir_tvalid;
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            tvalid_o <= 1'b0;
        end else begin
            if (en_i) begin
                tvalid_o <= dec_tvalid;
            end else begin
                tvalid_o <= 1'b0;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        tdata_o <= fir_tdata;
    end

endmodule
