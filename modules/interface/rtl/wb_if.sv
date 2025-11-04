interface wb_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk_i,
    input logic rst_i
);

    localparam int SEL_WIDTH = (DATA_WIDTH / 8);

    logic [ADDR_WIDTH-1:0] adr;
    logic [DATA_WIDTH-1:0] wdat;
    logic [DATA_WIDTH-1:0] rdat;
    logic [ SEL_WIDTH-1:0] sel;
    logic                  we;
    logic                  stb;
    logic                  cyc;
    logic                  ack;
    logic                  err;
    logic                  inta;

    modport master(
        input clk_i,
        input rst_i,
        output adr,
        output wdat,
        input rdat,
        output sel,
        output we,
        output stb,
        output cyc,
        input ack,
        input err,
        input inta
    );

    modport slave(
        input clk_i,
        input rst_i,
        input adr,
        input wdat,
        output rdat,
        input sel,
        input we,
        input stb,
        input cyc,
        output ack,
        output err,
        output inta
    );

endinterface
