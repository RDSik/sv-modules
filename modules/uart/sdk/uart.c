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

        uart_regs.control.rx_reset    = 0;
        uart_regs.control.tx_reset    = 0;
        uart_regs.control.parity_even = 0;
        uart_regs.control.parity_odd  = 0;
        uart_regs.clk_divider         = 100e6/115200;
        uart_regs.tx.data             = 0x4D; // ASCII - M

        Xil_Out32(UART_BASE_ADDR + UART_CLK_DIV_OFFSET, uart_regs.clk_divider);
        Xil_Out32(UART_BASE_ADDR + UART_TX_OFFSET, uart_regs.tx.data);
        Xil_Out32(UART_BASE_ADDR + UART_CTRL_OFFSET, uart_regs.control);

        uint32_t addr_offset = sizeof(uint32_t);
        uint32_t regs_num = sizeof(uart_regs) / addr_offset;
        uint32_t rd_data[regs_num];

        xil_printf("Number of regs %0d\n\r", regs_num);    

        for (uint32_t i = 0; i < regs_num; i++) {
            rd_data[i] = Xil_In32(UART_BASE_ADDR + i*addr_offset);
            xil_printf("The data at 0x%x is 0x%x \n\r", UART_BASE_ADDR + i*addr_offset, rd_data);
            xil_printf("\n\r");
        }

        memcpy(&uart_regs; rd_data; sizeof(uart_regs_t));

        xil_printf("[UART] : parity_even   = %d\n", uart_regs.control.parity_even);
        xil_printf("[UART] : parity_odd    = %d\n", uart_regs.control.parity_odd);
        xil_printf("[UART] : rx_reset      = %d\n", uart_regs.control.rx_reset);
        xil_printf("[UART] : tx_reset      = %d\n", uart_regs.control.tx_reset);
        xil_printf("[UART] : clk_divider   = %d\n", uart_regs.clk_divider);
        xil_printf("[UART] : tx_data       = %d\n", uart_regs.tx.data);
        xil_printf("[UART] : rx_data       = %d\n", uart_regs.rx.data);
        xil_printf("[UART] : parity_err    = %d\n", uart_regs.status.parity_err);
        xil_printf("[UART] : rx_fifo_empty = %d\n", uart_regs.status.rx_fifo_empty);
        xil_printf("[UART] : rx_fifo_full  = %d\n", uart_regs.status.rx_fifo_full);
        xil_printf("[UART] : tx_fifo_empty = %d\n", uart_regs.status.tx_fifo_empty);
        xil_printf("[UART] : tx_fifo_full  = %d\n", uart_regs.status.tx_fifo_full);
        xil_printf("[UART] : data_width    = %d\n", uart_regs.param.data_width);
        xil_printf("[UART] : fifo_depth    = %d\n", uart_regs.param.fifo_depth);
        xil_printf("[UART] : reg_num       = %d\n", uart_regs.param.reg_num);

        usleep(100000);

        xil_printf("UART stop test\n");
    }

    cleanup_platform();

    return EXIT_SUCCESS;
}
