`ifndef AXIL_I2C_SVH
`define AXIL_I2C_SVH

`include "../rtl/i2c_pkg.svh"
`include "../../verification/tb/axil_env.svh"

import i2c_pkg::*;

class axil_i2c_class #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;
    localparam logic RW = 1;

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

    task automatic i2c_start();
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * I2C_CONTROL_REG_POS, 2'b10);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * I2C_TX_DATA_REG_POS, {RW, 8'ha2});
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * I2C_TX_DATA_REG_POS, {RW, 8'hac});
    endtask

endclass

`endif  // AXIL_I2C_SVH
