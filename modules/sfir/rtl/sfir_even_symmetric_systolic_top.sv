/* verilator lint_off TIMESCALEMOD */
module sfir_even_symmetric_systolic_top #(
    parameter int TAP_NUM                    = 28,
    parameter int DATA_WIDTH                 = 16,
    parameter int COEF_WIDTH                 = 16,
    parameter int PRODUCT_WIDTH              = COEF_WIDTH + DATA_WIDTH,
    // verilog_format: off
    parameter int COEF         [0:TAP_NUM-1] = '{
        560, 608, -120, -354, -34, 538, 40, -560,
        -250, 692, 412, -710, -704, 740, 1014,  -662,
        -1436, 514, 1936, -198, -2608, -354, 3572, 1438,
        -5354, -4176, 11198, 27938}
    // verilog_format: on
) (
    input  logic                         clk_i,
    input  logic signed [DATA_WIDTH-1:0] data_i,
    output logic signed [DATA_WIDTH-1:0] fir_o
);

    /* verilator lint_off WIDTHEXPAND */
    if ((TAP_NUM % 2) != 0) begin : g_tap_num_err
        $error("TAP_NUM must be even!");
    end
    // /* verilator lint_on WIDTHEXPAND */


    logic signed [   COEF_WIDTH-1:0] h          [TAP_NUM-1:0];
    logic signed [   DATA_WIDTH-1:0] arraydata  [TAP_NUM-1:0];
    logic signed [PRODUCT_WIDTH-1:0] arrayprod  [TAP_NUM-1:0];

    logic signed [PRODUCT_WIDTH-1:0] fir;
    logic signed [   DATA_WIDTH-1:0] shifterout;
    logic signed [   DATA_WIDTH-1:0] dataz      [TAP_NUM-1:0];

    assign fir = arrayprod[TAP_NUM-1];  // Connect last product to output

    logic [$clog2(TAP_NUM)-1] sel;
    assign sel = (TAP_NUM * 2) - 1;

    shift_reg #(
        .RESET_EN  (0),
        .DATA_WIDTH(DATA_WIDTH),
        .DELAY     (TAP_NUM * 2)
    ) shift_reg (
        .clk_i (clk_i),
        .rstn_i(),
        .en_i  (1'b1),
        .sel_i (sel),
        .data_i(data_i),
        .data_o(shifterout)
    );

    for (genvar i = 0; i < TAP_NUM; i++) begin : g_fte
        assign h[i] = COEF[i][COEF_WIDTH-1:0];

        if (i == 0) begin : g_fte_0
            sfir_even_symmetric_systolic_element #(
                .DATA_WIDTH(DATA_WIDTH),
                .COEF_WIDTH(COEF_WIDTH)
            ) fte_inst0 (
                .clk_i     (clk_i),
                .coeff_i   (h[i]),
                .data_i    (data_i),
                .dataz_i   (shifterout),
                .casc_i    ({32{1'b0}}),
                .cascdata_o(arraydata[i]),
                .casc_o    (arrayprod[i])
            );
        end else begin : g_fte_n
            sfir_even_symmetric_systolic_element #(
                .DATA_WIDTH(DATA_WIDTH),
                .COEF_WIDTH(COEF_WIDTH)
            ) fte_inst (
                .clk_i     (clk_i),
                .coeff_i   (h[i]),
                .data_i    (arraydata[i-1]),
                .dataz_i   (shifterout),
                .casc_i    (arrayprod[i-1]),
                .cascdata_o(arraydata[i]),
                .casc_o    (arrayprod[i])
            );
        end
    end

endmodule
