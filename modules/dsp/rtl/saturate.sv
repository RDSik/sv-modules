/* verilator lint_off TIMESCALEMOD */
module saturate #(
    parameter int CH_NUM         = 2,
    parameter int DATA_WIDTH_IN  = 33,
    parameter int DATA_WIDTH_OUT = 16
) (
    input logic clk_i,
    input logic rst_i,

    input logic [CH_NUM-1:0][DATA_WIDTH_IN-1:0] tdata_i,
    input logic                                 tvalid_i,

    output logic [CH_NUM-1:0][DATA_WIDTH_OUT-1:0] tdata_o,
    output logic                                  tvalid_o,

    output logic ovf_o
);

    localparam MAX_NEG_VAL = {1'b1, {DATA_WIDTH_OUT - 1{1'b0}}};
    localparam MAX_POS_VAL = {1'b0, {DATA_WIDTH_OUT - 1{1'b1}}};

    logic [CH_NUM-1:0] overflow;

    for (genvar i = 0; i < CH_NUM; i++) begin : g_ch
        logic neg_val;
        logic pos_val;
        logic saturate;

        assign neg_val  = (tdata_i[i][DATA_WIDTH_IN-1:DATA_WIDTH_OUT-1] == '1);
        assign pos_val  = (tdata_i[i][DATA_WIDTH_IN-1:DATA_WIDTH_OUT-1] == '0);
        assign saturate = ~(neg_val | pos_val);

        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                overflow[i] <= 1'b0;
            end else begin
                if (saturate) begin
                    overflow[i] <= 1'b1;
                end else begin
                    overflow[i] <= 1'b0;
                end
            end
        end

        always_ff @(posedge clk_i) begin
            if (saturate) begin
                if (tdata_i[i][DATA_WIDTH_IN-1]) begin
                    tdata_o[i] <= MAX_NEG_VAL;
                end else begin
                    tdata_o[i] <= MAX_POS_VAL;
                end
            end else begin
                tdata_o[i] <= tdata_i[i][DATA_WIDTH_OUT-1:0];
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            tvalid_o <= '0;
        end else begin
            tvalid_o <= tvalid_i;
        end
    end

    assign ovf_o = |overflow;

endmodule
