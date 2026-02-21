#include "XAxidma.h"
#include "uart.h"
#include "spi.h"
#include "i2c.h"

#include "xil_cache.h"
#include "xparameters.h"

#define ADDR_OFFSET 0x10000
#define CLK_FREQ    50000000

int main() {
    Xil_DCacheDisable();
    Xil_ICacheDisable();

    while (1) {
        i2c_regs_t *i2c_regs   = (i2c_regs_t *)((size_t)(XPAR_M01_AXI_0_BASEADDR + 0 * ADDR_OFFSET));
        spi_regs_t *spi_regs   = (spi_regs_t *)((size_t)(XPAR_M01_AXI_0_BASEADDR + 1 * ADDR_OFFSET));
        uart_regs_t *uart_regs = (uart_regs_t *)((size_t)(XPAR_M01_AXI_0_BASEADDR + 2 * ADDR_OFFSET));

        uart_test(uart_regs, CLK_FREQ);
        spi_test(spi_regs, CLK_FREQ);
        i2c_test(i2c_regs, CLK_FREQ);
    }

    return EXIT_SUCCESS;
}
