#include "uart.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "xil_printf.h"
#include "xil_io.h"
#include "sleep.h"

void uart_read_regs(uart_regs_t *uart_regs) {
    xil_printf("[UART] : parity_even   = %d\n", uart_regs->control.parity_even);
    xil_printf("[UART] : parity_odd    = %d\n", uart_regs->control.parity_odd);
    xil_printf("[UART] : rx_reset      = %d\n", uart_regs->control.rx_reset);
    xil_printf("[UART] : tx_reset      = %d\n", uart_regs->control.tx_reset);
    xil_printf("[UART] : clk_divider   = %d\n", uart_regs->clk_divider);
    xil_printf("[UART] : tx_data       = %c\n", uart_regs->tx.data);
    xil_printf("[UART] : rx_data       = %c\n", uart_regs->rx.data);
    xil_printf("[UART] : parity_err    = %d\n", uart_regs->status.parity_err);
    xil_printf("[UART] : rx_fifo_empty = %d\n", uart_regs->status.rx_fifo_empty);
    xil_printf("[UART] : rx_fifo_full  = %d\n", uart_regs->status.rx_fifo_full);
    xil_printf("[UART] : tx_fifo_empty = %d\n", uart_regs->status.tx_fifo_empty);
    xil_printf("[UART] : tx_fifo_full  = %d\n", uart_regs->status.tx_fifo_full);
    xil_printf("[UART] : data_width    = %d\n", uart_regs->param.data_width);
    xil_printf("[UART] : fifo_depth    = %d\n", uart_regs->param.fifo_depth);
    xil_printf("[UART] : reg_num       = %d\n", uart_regs->param.reg_num);
}

int uart_test(uart_regs_t *uart_regs, uint32_t clk_freq) {
    char words[]       = "Hello world";
    uint32_t baud_rate = 115200;

    uart_regs->control.rx_reset    = 0;
    uart_regs->control.tx_reset    = 0;
    uart_regs->control.parity_even = 0;
    uart_regs->control.parity_odd  = 0;
    uart_regs->clk_divider         = clk_freq/baud_rate;

    for (uint32_t i = 0; i < strlen(words); i++) {
        uart_regs->tx.data = words[i];
    }

    uart_read_regs(uart_regs);

    usleep(100000);

    xil_printf("[UART]: stop test\n");

    return EXIT_SUCCESS;
}
