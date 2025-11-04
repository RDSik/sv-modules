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

        uart_regs_t uart_regs;

        uart_regs->control.rx_reset    = 0;
        uart_regs->control.tx_reset    = 0;
        uart_regs->control.parity_even = 0;
        uart_regs->control.parity_odd  = 0;
        uart_regs->clk_divider         = 50e6/115200;
        uart_regs->tx.data             = 0x4D; // ASCII - M

        Xil_Out32(UART_BASE_ADDR + 0, uart_regs->control);
        Xil_Out32(UART_BASE_ADDR + 4, uart_regs->clk_divider);
        Xil_Out32(UART_BASE_ADDR + 8, uart_regs->tx.data);

        uint32_t reg_num;
        uint32_t addr_offset;
        uint32_t rd_data;

        addr_offset = sizeof(uint32_t);
        reg_num = sizeof(uart_regs) / addr_offset;
        xil_printf("Number of regs %0d\n\r", reg_num);    

        for (uint32_t i = 0; i < regs_num*addr_offset; i += addr_offset) {
            rd_data = Xil_In32(UART_BASE_ADDR + i);
            xil_printf("The data at 0x%x is 0x%x \n\r", UART_BASE_ADDR + i, rd_data);
            xil_printf("\n\r");
        }

        usleep(100000);

        xil_printf("UART stop test\n");
    }

    cleanup_platform();

    return EXIT_SUCCESS;
}
