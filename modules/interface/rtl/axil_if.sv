interface axil_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk_i,
    input logic rstn_i
);

    localparam int STRB_WIDTH = (DATA_WIDTH / 8);

    logic [ADDR_WIDTH-1:0] awaddr;
    logic                  awvalid;
    logic                  awready;

    logic [DATA_WIDTH-1:0] wdata;
    logic [STRB_WIDTH-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;

    logic [           1:0] bresp;
    logic                  bvalid;
    logic                  bready;

    logic [ADDR_WIDTH-1:0] araddr;
    logic                  arvalid;
    logic                  arready;

    logic [DATA_WIDTH-1:0] rdata;
    logic                  rvalid;
    logic                  rready;
    logic [           1:0] rresp;

    modport master(
        input clk_i,
        input rstn_i,
        output awaddr,
        output awvalid,
        input awready,
        output wdata,
        output wstrb,
        output wvalid,
        input wready,
        input rresp,
        input bresp,
        input bvalid,
        output bready,
        output araddr,
        output arvalid,
        input arready,
        input rdata,
        input rvalid,
        output rready
    );

    modport slave(
        input clk_i,
        input rstn_i,
        input awaddr,
        input awvalid,
        output awready,
        input wdata,
        input wstrb,
        input wvalid,
        output wready,
        output rresp,
        output bresp,
        output bvalid,
        input bready,
        input araddr,
        input arvalid,
        output arready,
        output rdata,
        output rvalid,
        input rready
    );

endinterface
