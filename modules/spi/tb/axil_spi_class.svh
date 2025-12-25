`ifndef AXIL_SPI_SVH
`define AXIL_SPI_SVH

`include "modules/spi/rtl/spi_pkg.svh"
`include "modules/verification/tb/axil_env.svh"

import spi_pkg::*;

class axil_spi_class #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;
    localparam int WAIT_TIME = 10;
    localparam int CLK_DIV = 10;
    localparam logic [SPI_MAX_SLAVE_NUM-1:0] SLAVE_SELECT = 8'b0000_0001;
    localparam logic CPHA = 1;
    localparam logic CPOL = 0;
    localparam logic LAST = 1;

    axil_env #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))        env;

    virtual axil_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) s_axil;

    function new(
    virtual axil_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) s_axil);
        this.s_axil = s_axil;
        env         = new(s_axil);
    endfunction

    task automatic spi_read_regs();
        spi_regs_t spi_regs;
        begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_CONTROL_REG_POS, spi_regs.control);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_CLK_DIVIDER_REG_POS,
                                spi_regs.clk_divider);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_WAIT_TIME_REG_POS,
                                spi_regs.wait_time);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_SLAVE_SELECT_REG_POS, spi_regs.slave);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_TX_DATA_REG_POS, spi_regs.tx);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_RX_DATA_REG_POS, spi_regs.rx);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_STATUS_REG_POS, spi_regs.status);
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_PARAM_REG_POS, spi_regs.param);

            $display("[%0t][SPI]: reset         = %0d", $time, spi_regs.control.reset);
            $display("[%0t][SPI]: cpol          = %0d", $time, spi_regs.control.cpol);
            $display("[%0t][SPI]: cpha          = %0d", $time, spi_regs.control.cpha);
            $display("[%0t][SPI]: clk_divider   = %0d", $time, spi_regs.clk_divider);
            $display("[%0t][SPI]: wait_time     = %0d", $time, spi_regs.wait_time);
            $display("[%0t][SPI]: slave_select  = %0d", $time, spi_regs.slave.select);
            $display("[%0t][SPI]: tx_data       = %0h", $time, spi_regs.tx.data);
            $display("[%0t][SPI]: tx_last       = %0h", $time, spi_regs.tx.last);
            $display("[%0t][SPI]: rx_data       = %0h", $time, spi_regs.rx.data);
            $display("[%0t][SPI]: rx_last       = %0h", $time, spi_regs.rx.last);
            $display("[%0t][SPI]: rx_fifo_empty = %0d", $time, spi_regs.status.rx_fifo_empty);
            $display("[%0t][SPI]: tx_fifo_empty = %0d", $time, spi_regs.status.tx_fifo_empty);
            $display("[%0t][SPI]: rx_fifo_full  = %0d", $time, spi_regs.status.rx_fifo_full);
            $display("[%0t][SPI]: tx_fifo_full  = %0d", $time, spi_regs.status.tx_fifo_full);
            $display("[%0t][SPI]: fifo_depth    = %0d", $time, spi_regs.param.fifo_depth);
            $display("[%0t][SPI]: data_width    = %0d", $time, spi_regs.param.data_width);
            $display("[%0t][SPI]: reg_num       = %0d", $time, spi_regs.param.reg_num);
        end
    endtask

    task automatic spi_start();
        spi_regs_t spi_regs;
        spi_regs              = '0;
        spi_regs.control.cpha = CPHA;
        spi_regs.control.cpol = CPOL;
        spi_regs.clk_divider  = CLK_DIV;
        spi_regs.wait_time    = WAIT_TIME;
        spi_regs.slave.select = SLAVE_SELECT;
        spi_regs.tx.data      = $urandom_range(0, (2 ** SPI_DATA_WIDTH) - 1);
        spi_regs.tx.last      = LAST;
        begin
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_WAIT_TIME_REG_POS,
                                 spi_regs.wait_time);
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_CLK_DIVIDER_REG_POS,
                                 spi_regs.clk_divider);
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_SLAVE_SELECT_REG_POS,
                                 spi_regs.slave);
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_CONTROL_REG_POS, spi_regs.control);
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * SPI_TX_DATA_REG_POS, spi_regs.tx);
            do begin
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * SPI_STATUS_REG_POS, spi_regs.status);
            end while (spi_regs.status.rx_fifo_empty);
            spi_read_regs();
        end
    endtask

endclass

`endif  // AXIL_SPI_SVH
