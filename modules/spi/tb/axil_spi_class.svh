`ifndef AXIL_SPI_SVH
`define AXIL_SPI_SVH

`include "../rtl/spi_pkg.svh"
`include "../../verification/tb/axil_env.svh"

import spi_pkg::*;

class axil_spi_class #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;
    localparam int WAIT_TIME = 10;
    localparam int CLK_DIV = 10;
    localparam logic CPHA = 1;
    localparam logic CPOL = 0;
    localparam logic LAST = 1;

    logic                                                               [SPI_DATA_WIDTH-1:0] wdata;
    logic                                                               [    DATA_WIDTH-1:0] rdata;

    axil_env #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))                             env;

    virtual axil_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))                      s_axil;

    function new(
    virtual axil_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) s_axil);
        this.s_axil = s_axil;
        env         = new(s_axil);
    endfunction

    task automatic spi_start();
        wdata = $urandom_range(0, (2 ** SPI_DATA_WIDTH) - 1);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_WAIT_TIME_REG_POS, WAIT_TIME);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_CLK_DIVIDER_REG_POS, CLK_DIV);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_CONTROL_REG_POS, {CPOL, CPHA, 1'b0});
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_TX_DATA_REG_POS, {LAST, wdata});
        do begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_STATUS_REG_POS, rdata);
        end while (rdata[3]);
        for (int i = 0; i < SPI_REG_NUM; i++) begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * i, rdata);
        end
    endtask

endclass

`endif  // AXIL_SPI_SVH
