`ifndef AXI_DMA_SVH
`define AXI_DMA_SVH

`include "modules/axi_dma/rtl/axi_dma_pkg.svh"
`include "modules/verification/tb/axil_env.svh"

import axi_dma_pkg::*;

class axi_dma_class #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;

    logic                                                               [DATA_WIDTH-1:0] wdata;
    logic                                                               [DATA_WIDTH-1:0] rdata;

    axil_env #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))                         env;

    virtual axil_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))                  s_axil;

    function new(
    virtual axil_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) s_axil);
        this.s_axil = s_axil;
        env         = new(s_axil);
    endfunction



endclass

`endif  // AXI_DMA_SVH
