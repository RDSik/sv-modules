#include "uart.h"

#include <stdlib.h>
#include <stdio.h>

#include "platform.h"
#include "xil_printf.h"
#include "xil_io.h"
#include "xparameters.h"
#include "sleep.h"

int main() {
    init_platform();

    while(1) {
        xil_printf("UART start test\n");

        uart_regs_t *regs_pt = 0x43c00000;

        regs_pt->control.rx_reset    = 0;
        regs_pt->control.tx_reset    = 0;
        regs_pt->control.parity_even = 0;
        regs_pt->control.parity_odd  = 0;
        regs_pt->clk_divider         = 50e6/115200;
        regs_pt->tx.data             = 0x4D; // ASCII - M

        xil_printf("clk_divider = %0d\n\r", regs_pt->clk_divider);
        xil_printf("tx_data = %0d\n\r", regs_pt->tx.data);
        xil_printf("parity_even = %0d\n\r", regs_pt->control.parity_even);
        xil_printf("parity_odd = %0d\n\r", regs_pt->control.parity_odd);
        xil_printf("rx_reset = %0d\n\r", regs_pt->control.rx_reset);
        xil_printf("tx_reset = %0d\n\r", regs_pt->control.tx_reset);
        xil_printf("rx_data = %0d\n\r", regs_pt->rx.data);
        xil_printf("\n\r");
        usleep(100000);

        xil_printf("UART stop test\n");
    }

    cleanup_platform();

    return EXIT_SUCCESS;
}
