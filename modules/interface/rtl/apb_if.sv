interface apb_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk_i,
    input logic rstn_i
);

    logic [ADDR_WIDTH-1:0] paddr;
    logic [DATA_WIDTH-1:0] pwdata;
    logic [DATA_WIDTH-1:0] prdata;
    logic                  psel;
    logic                  penable;
    logic                  pwrite;
    logic                  pready;
    logic                  pslverr;

    modport master(
        input clk_i,
        input rstn_i,
        output paddr,
        output pwdata,
        input prdata,
        output psel,
        output penable,
        output pwrite,
        input pready,
        input pslverr
    );

    modport slave(
        input clk_i,
        input rstn_i,
        input paddr,
        input pwdata,
        output prdata,
        input psel,
        input penable,
        input pwrite,
        output pready,
        output pslverr
    );

endinterface
