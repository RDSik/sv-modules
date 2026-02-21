#include "spi.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

void spi_read_regs(spi_regs_t *spi_regs) {
    xil_printf("[SPI] : cpol          = %d\n", spi_regs->control.cpol);
    xil_printf("[SPI] : cpha          = %d\n", spi_regs->control.cpha);
    xil_printf("[SPI] : reset         = %d\n", spi_regs->control.reset);
    xil_printf("[SPI] : clk_divider   = %d\n", spi_regs->clk_divider);
    xil_printf("[SPI] : wait_time     = %d\n", spi_regs->wait_time);
    xil_printf("[SPI] : slave_select  = %d\n", spi_regs->slave.select);
    xil_printf("[SPI] : tx_data       = %c\n", spi_regs->tx.data);
    xil_printf("[SPI] : tx_last       = %c\n", spi_regs->tx.last);
    xil_printf("[SPI] : rx_data       = %c\n", spi_regs->rx.data);
    xil_printf("[SPI] : rx_last       = %c\n", spi_regs->rx.last);
    xil_printf("[SPI] : rx_fifo_empty = %d\n", spi_regs->status.rx_fifo_empty);
    xil_printf("[SPI] : rx_fifo_full  = %d\n", spi_regs->status.rx_fifo_full);
    xil_printf("[SPI] : tx_fifo_empty = %d\n", spi_regs->status.tx_fifo_empty);
    xil_printf("[SPI] : tx_fifo_full  = %d\n", spi_regs->status.tx_fifo_full);
    xil_printf("[SPI] : data_width    = %d\n", spi_regs->param.data_width);
    xil_printf("[SPI] : fifo_depth    = %d\n", spi_regs->param.fifo_depth);
    xil_printf("[SPI] : reg_num       = %d\n", spi_regs->param.reg_num);
}

int spi_test(spi_regs_t *spi_regs, uint32_t clk_freq) {
    uint32_t clk_div  = 4;
    uint32_t data_num = 10;

    spi_regs->control.reset = 0;
    spi_regs->control.cpol  = 0;
    spi_regs->control.cpha  = 1;
    spi_regs->clk_divider   = clk_freq/clk_div;

    for (uint32_t i = 0; i < data_num; i++) {
        spi_regs->tx.data = i;
        if (i == data_num - 1) {
            spi_regs->tx.last = 1;
        }
    }

    spi_read_regs(spi_regs);

    usleep(100000);

    xil_printf("[SPI]: stop test\n");

    return EXIT_SUCCESS;
}
