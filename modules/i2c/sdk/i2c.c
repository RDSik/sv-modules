#include "i2c.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

void i2c_read_regs(i2c_regs_t *i2c_regs) {
    xil_printf("[I2C] : core_en       = %d\n", i2c_regs->control.core_en);
    xil_printf("[I2C] : core_rst      = %d\n", i2c_regs->control.core_rst);
    xil_printf("[I2C] : clk_prescale  = %d\n", i2c_regs->clk.prescale);
    xil_printf("[I2C] : tx_data       = %c\n", i2c_regs->tx.data);
    xil_printf("[I2C] : rx_data       = %c\n", i2c_regs->rx.data);
    xil_printf("[I2C] : rx_fifo_empty = %d\n", i2c_regs->status.rx_fifo_empty);
    xil_printf("[I2C] : rx_fifo_full  = %d\n", i2c_regs->status.rx_fifo_full);
    xil_printf("[I2C] : tx_fifo_empty = %d\n", i2c_regs->status.tx_fifo_empty);
    xil_printf("[I2C] : tx_fifo_full  = %d\n", i2c_regs->status.tx_fifo_full);
    xil_printf("[I2C] : rx_ack        = %d\n", i2c_regs->status.rx_ack);
    xil_printf("[I2C] : busy          = %d\n", i2c_regs->status.busy);
    xil_printf("[I2C] : data_width    = %d\n", i2c_regs->param.data_width);
    xil_printf("[I2C] : fifo_depth    = %d\n", i2c_regs->param.fifo_depth);
    xil_printf("[I2C] : reg_num       = %d\n", i2c_regs->param.reg_num);
}

int i2c_test(i2c_regs_t *i2c_regs, uint32_t clk_freq) {
    uint32_t data_num = 10;

    i2c_regs->control.core_rst = 0;
    i2c_regs->control.core_en  = 1;
    i2c_regs->clk.prescale     = clk_freq/(5*100e3);
    i2c_regs->tx.data          = I2C_WRITE_ADDR;

    for (uint32_t i = 0; i < data_num; i++) {
        i2c_regs->tx.data = i;
    }

    i2c_read_regs(i2c_regs);

    usleep(100000);

    xil_printf("[I2C]: stop test\n");

    return EXIT_SUCCESS;
}
