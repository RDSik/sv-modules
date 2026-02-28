interface axi_if #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    input logic clk_i,
    input logic arstn_i
);

    localparam int STRB_WIDTH = (DATA_WIDTH / 8);

    logic [ADDR_WIDTH-1:0] awaddr;
    logic                  awvalid;
    logic                  awready;
    logic [           2:0] awprot;
    logic [           7:0] awlen;
    logic [           2:0] awsize;
    logic [           1:0] awburst;
    logic                  awlock;
    logic [           3:0] awcache;
    logic [           3:0] awregion;
    logic [           3:0] awqos;

    logic [DATA_WIDTH-1:0] wdata;
    logic [STRB_WIDTH-1:0] wstrb;
    logic                  wvalid;
    logic                  wready;
    logic                  wlast;

    logic [           1:0] bresp;
    logic                  bvalid;
    logic                  bready;

    logic [ADDR_WIDTH-1:0] araddr;
    logic                  arvalid;
    logic                  arready;
    logic [           2:0] arprot;
    logic [           7:0] arlen;
    logic [           2:0] arsize;
    logic [           1:0] arburst;
    logic                  arlock;
    logic [           3:0] arcache;
    logic [           3:0] arregion;
    logic [           3:0] arqos;

    logic [DATA_WIDTH-1:0] rdata;
    logic                  rvalid;
    logic                  rready;
    logic                  rlast;
    logic [           1:0] rresp;

    modport master(
        input clk_i,
        input arstn_i,
        output awaddr,
        output awprot,
        output awlen,
        output awsize,
        output awburst,
        output awlock,
        output awcache,
        output awregion,
        output awqos,
        output awvalid,
        input awready,
        output wdata,
        output wstrb,
        output wvalid,
        output wlast,
        input wready,
        input rresp,
        input bresp,
        input bvalid,
        output bready,
        output araddr,
        output arprot,
        output arlen,
        output arsize,
        output arburst,
        output arlock,
        output arcache,
        output arregion,
        output arqos,
        output arvalid,
        input arready,
        input rdata,
        input rvalid,
        input rlast,
        output rready
    );

    modport slave(
        input clk_i,
        input arstn_i,
        input awaddr,
        input awprot,
        input awlen,
        input awsize,
        input awburst,
        input awlock,
        input awcache,
        input awregion,
        input awqos,
        input awvalid,
        output awready,
        input wdata,
        input wstrb,
        input wlast,
        input wvalid,
        output wready,
        output rresp,
        output bresp,
        output bvalid,
        input bready,
        input araddr,
        input arprot,
        input arlen,
        input arsize,
        input arburst,
        input arlock,
        input arcache,
        input arregion,
        input arqos,
        input arvalid,
        output arready,
        output rdata,
        output rvalid,
        output rlast,
        input rready
    );

endinterface
