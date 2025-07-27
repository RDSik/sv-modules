module sfir_even_symmetric_systolic_element #(
    parameter int DATA_WIDTH    = 16,
    parameter int COEF_WIDTH    = 16,
    parameter int PRODUCT_WIDTH = COEF_WIDTH + DATA_WIDTH

) (
    input  logic                            clk_i,
    input  logic signed [   COEF_WIDTH-1:0] coeff_i,
    input  logic signed [   DATA_WIDTH-1:0] data_i,
    input  logic signed [   DATA_WIDTH-1:0] dataz_i,
    input  logic signed [PRODUCT_WIDTH-1:0] casc_i,
    output logic signed [   DATA_WIDTH-1:0] cascdata_o,
    output logic signed [PRODUCT_WIDTH-1:0] casc_o
);

    logic signed [   COEF_WIDTH-1:0] coeff;
    logic signed [   DATA_WIDTH-1:0] data;
    logic signed [   DATA_WIDTH-1:0] dataz;
    logic signed [   DATA_WIDTH-1:0] datatwo;
    logic signed [     DATA_WIDTH:0] preadd;
    logic signed [PRODUCT_WIDTH-1:0] product;

    assign cascdata_o = datatwo;

    always @(posedge clk_i) begin
        coeff   <= coeff_i;
        data    <= data_i;
        datatwo <= data;
        dataz   <= dataz_i;
        preadd  <= datatwo + dataz;
        product <= preadd * coeff;
        casc_o  <= product + casc_i;
    end

endmodule
