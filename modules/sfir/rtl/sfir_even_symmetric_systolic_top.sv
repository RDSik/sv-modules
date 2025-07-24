module sfir_even_symmetric_systolic_top #(
    parameter int TAP_NUM                    = 4,
    parameter int DATA_WIDTH                 = 16,
    parameter int COEF_WIDTH                 = 16,
    parameter int PRODUCT_WIDTH              = COE_WIDTH + DATA_WIDTH,
    parameter int COEF         [0:TAP_NUM-1] = '{}
) (
    input  logic                            clk_i,
    input  logic                            rstn_i,
    input  logic                            en_i,
    input  logic signed [   DATA_WIDTH-1:0] data_i,
    output logic signed [PRODUCT_WIDTH-1:0] fir_o
);

    logic signed [   COEF_WIDTH-1:0] h          [TAP_NUM-1:0];
    logic signed [   DATA_WIDTH-1:0] arraydata  [TAP_NUM-1:0];
    logic signed [PRODUCT_WIDTH-1:0] arrayprod  [TAP_NUM-1:0];

    logic signed [   DATA_WIDTH-1:0] shifterout;
    logic signed [   DATA_WIDTH-1:0] dataz      [TAP_NUM-1:0];

    assign fir_o = arrayprod[TAP_NUM-1];

    shift_reg #(
        .DATA_WIDTH(DATA_WIDTH),
        .DELAY     (TAP_NUM*2)
    ) shift_reg (
        .clk_i (clk_i),
        .rstn_i(rstn_i),
        .en_i  (en_i),
        .sel_i (TAP_NUM*2 - 1),
        .data_i(data_i),
        .data_o(shifterout)
    );

    for (genvar i = 0; i < TAP_NUM; i++) begin
        assign h[i] = COEF[i][COEF_WIDTH-1:0];

        if (i == 0) begin
            sfir_even_symmetric_systolic_element #(
                .DATA_WIDTH(DATA_WIDTH),
                .COEF_WIDTH(COEF_WIDTH)
            ) fte_inst0 (
                .clk     (clk_i),
                .rstn_i  (rstn_i),
                .en_i    (en_i),
                .coeffin (h[i]),
                .datain  (data_i),
                .datazin (shifterout),
                .cascin  ({32{1'b0}}),
                .cascdata(arraydata[i]),
                .cascout (arrayprod[i])
            );
        end else begin
            sfir_even_symmetric_systolic_element #(
                .DATA_WIDTH(DATA_WIDTH),
                .COEF_WIDTH(COEF_WIDTH)
            ) fte_inst (
                .clk     (clk_i),
                .rstn_i  (rstn_i),
                .en_i    (en_i),
                .coeffin (h[i]),
                .datain  (arraydata[i-1]),
                .datazin (shifterout),
                .cascin  (arrayprod[i-1]),
                .cascdata(arraydata[i]),
                .cascout (arrayprod[i])
            );
        end
    end
endmodule
