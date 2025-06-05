interface axis_if #(
    parameter int DATA_WIDTH = 8,
    parameter int DEST_WIDTH = 1,
    parameter int USER_WIDTH = 1,
    parameter int ID_WIDTH   = 1,
    parameter int KEEP_WIDTH = (DATA_WIDTH/8),
    parameter int STRB_WIDTH = (DATA_WIDTH/8)
) (
    input logic clk_i,
    input logic arstn_i
);

logic [DATA_WIDTH-1:0] tdata;
logic                  tvalid;
logic                  tready;
logic                  tlast;
logic [KEEP_WIDTH-1:0] tkeep;
logic [STRB_WIDTH-1:0] tstrb;
logic [DEST_WIDTH-1:0] tdest;
logic [USER_WIDTH-1:0] tuser;
logic [ID_WIDTH-1:0]   tid;

modport master (
    input  clk_i,
    input  arstn_i,
    input  tready,
    output tdata,
    output tvalid,
    output tlast,
    output tkeep,
    output tstrb,
    output tdest,
    output tuser,
    output tid
);

modport slave (
    input  clk_i,
    input  arstn_i,
    output tready,
    input  tdata,
    input  tvalid,
    input  tlast,
    input  tkeep,
    input  tstrb,
    input  tdest,
    input  tuser,
    input  tid
);

endinterface
