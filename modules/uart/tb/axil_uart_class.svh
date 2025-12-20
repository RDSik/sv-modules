`ifndef AXIL_UART_SVH
`define AXIL_UART_SVH

`include "../rtl/uart_pkg.svh"
`include "../../verification/tb/axil_env.svh"

import uart_pkg::*;

class axil_uart_class #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;
    localparam int CLK_DIV = 10;

    logic [UART_DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;

    axil_env #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) env;

    virtual axil_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) s_axil;

    function new(
    virtual axil_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) s_axil);
        this.s_axil = s_axil;
        env         = new(s_axil);
    endfunction

    task automatic uart_start();
        wdata = $urandom_range(0, (2 ** UART_DATA_WIDTH) - 1);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * UART_CLK_DIVIDER_REG_POS, CLK_DIV);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * UART_CONTROL_REG_POS, 0);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * UART_TX_DATA_REG_POS, wdata);
        do begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * UART_STATUS_REG_POS, rdata);
        end while (rdata[4]);
        for (int i = 0; i < UART_REG_NUM; i++) begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * i, rdata);
        end
    endtask

endclass

`endif  // AXIL_UART_SVH
