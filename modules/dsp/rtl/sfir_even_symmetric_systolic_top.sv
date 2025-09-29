/* verilator lint_off TIMESCALEMOD */
// sfir_even_symmetric_systolic_top.v
// FiR Symmetric Systolic Filter, Top module is sfir_even_symmetric_systolic_top

module sfir_even_symmetric_systolic_top #(
    parameter integer NBTAP = 28,
    parameter integer DSIZE = 16,
    parameter integer CSIZE = 18,
    parameter integer PSIZE = CSIZE + DSIZE,
    // verilog_format: off
    parameter int COEF         [0:NBTAP-1] = '{
        560, 608, -120, -354, -34, 538, 40, -560,
        -250, 692, 412, -710, -704, 740, 1014,  -662,
        -1436, 514, 1936, -198, -2608, -354, 3572, 1438,
        -5354, -4176, 11198, 27938}
    // verilog_format: on

) (
    input  logic                    clk,
    input  logic signed [DSIZE-1:0] datain,
    output logic signed [PSIZE-1:0] firout
);

    logic signed [CSIZE-1:0] h[NBTAP-1:0];
    logic signed [DSIZE-1:0] arraydata[NBTAP-1:0];
    logic signed [PSIZE-1:0] arrayprod[NBTAP-1:0];

    logic signed [DSIZE-1:0] shifterout;
    logic signed [DSIZE-1:0] dataz[NBTAP-1:0];

    assign firout = arrayprod[NBTAP-1];  // Connect last product to output

    sfir_shifter #(
        .DSIZE(DSIZE),
        .NBTAP(NBTAP)
    ) shifter_inst0 (
        .clk    (clk),
        .datain (datain),
        .dataout(shifterout)
    );

    for (genvar i = 0; i < NBTAP; i = i + 1) begin
        assign h[i] = COEF[i][CSIZE-1:0];

        if (i == 0) begin
            sfir_even_symmetric_systolic_element #(
                .DSIZE(DSIZE),
                .CSIZE(CSIZE)
            ) fte_inst0 (
                .clk     (clk),
                .coeffin (h[i]),
                .datain  (datain),
                .datazin (shifterout),
                .cascin  ('0),
                .cascdata(arraydata[i]),
                .cascout (arrayprod[i])
            );
        end else begin
            sfir_even_symmetric_systolic_element #(
                .DSIZE(DSIZE),
                .CSIZE(CSIZE)
            ) fte_inst (
                .clk     (clk),
                .coeffin (h[i]),
                .datain  (arraydata[i-1]),
                .datazin (shifterout),
                .cascin  (arrayprod[i-1]),
                .cascdata(arraydata[i]),
                .cascout (arrayprod[i])
            );
        end
    end

endmodule  // sfir_even_symmetric_systolic_top

// sfir_shifter - sub module which is used in top level
(* dont_touch = "yes" *)
module sfir_shifter #(
    parameter integer DSIZE = 16,
    parameter integer NBTAP = 4
) (
    input  logic             clk,
    input  logic [DSIZE-1:0] datain,
    output logic [DSIZE-1:0] dataout
);

    (* srl_style = "srl_logicister" *) logic [DSIZE-1:0] tmp[0:2*NBTAP-1];
    always @(posedge clk) begin
        tmp[0] <= datain;
        for (integer i = 0; i <= 2 * NBTAP - 2; i = i + 1) begin
            tmp[i+1] <= tmp[i];
        end
    end

    assign dataout = tmp[2*NBTAP-1];

endmodule

// sfir_even_symmetric_systolic_element - sub module which is used in top
module sfir_even_symmetric_systolic_element #(
    parameter integer DSIZE = 16,
    parameter integer CSIZE = 18
) (
    input  logic                          clk,
    input  logic signed [      CSIZE-1:0] coeffin,
    input  logic                          datain,
    input  logic                          datazin,
    input  logic signed [CSIZE+DSIZE-1:0] cascin,
    output logic signed [      DSIZE-1:0] cascdata,
    output logic signed [CSIZE+DSIZE-1:0] cascout
);

    logic signed [      CSIZE-1:0] coeff;
    logic signed [      DSIZE-1:0] data;
    logic signed [      DSIZE-1:0] dataz;
    logic signed [      DSIZE-1:0] datatwo;
    logic signed [        DSIZE:0] preadd;
    logic signed [CSIZE+DSIZE-1:0] product;

    assign cascdata = datatwo;

    always @(posedge clk) begin
        coeff   <= coeffin;
        data    <= datain;
        datatwo <= data;
        dataz   <= datazin;
        preadd  <= datatwo + dataz;
        product <= preadd * coeff;
        cascout <= product + cascin;
    end

endmodule
