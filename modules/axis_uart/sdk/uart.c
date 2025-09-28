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

        uart_regs_t *regs_pt;
        regs_pt = (uart_regs_t *)malloc(sizeof(uart_regs_t));

        if (regs_pt == NULL) {
            xil_printf("Error while allocate memory!\n");
            return EXIT_FAILURE;
        }

        regs_pt->control.rx_reset    = 0;
        regs_pt->control.tx_reset    = 0;
        regs_pt->control.parity_even = 0;
        regs_pt->control.parity_odd  = 0;
        regs_pt->clk_divider         = 50e6/115200;
        regs_pt->tx.data             = 0x4D; // ASCII - M

        Xil_Out32(XPAR_APB_M_0_BASEADDR + 4, regs_pt->clk_divider);
        xil_printf("Write data 0x%x to 0x%x \n\r", regs_pt->clk_divider, XPAR_APB_M_0_BASEADDR + 4);
        Xil_Out32(XPAR_APB_M_0_BASEADDR + 8, regs_pt->tx.data);
        xil_printf("Write data 0x%x to 0x%x \n\r", regs_pt->tx.data, XPAR_APB_M_0_BASEADDR + 8);
        Xil_Out32(XPAR_APB_M_0_BASEADDR + 0, regs_pt->control);
        xil_printf("Write data 0x%x to 0x%x \n\r", regs_pt->control, XPAR_APB_M_0_BASEADDR + 0);

        uint8_t regs_num    = 6;
        uint8_t addr_offset = sizeof(uint32_t);
        uint32_t rd_data;

        for (int i = 0; i < regs_num*addr_offset; i += addr_offset) {
            rd_data = Xil_In32(XPAR_APB_M_0_BASEADDR + i);
            xil_printf("Read data from 0x%x equal 0x%x \n\r", XPAR_APB_M_0_BASEADDR + i, rd_data);
            xil_printf("\n\r");
        }

        usleep(100000);

        free(regs_pt);
        xil_printf("UART stop test\n");
    }

    cleanup_platform();

    return EXIT_SUCCESS;
}
