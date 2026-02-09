#include "XAxidma.h"
#include "uart.h"
#include "spi.h"
#include "i2c.h"

#include "xil_cache.h"
#include "xparameters.h"

#define ADDR_OFFSET 0x10000

int main() {
    Xil_DCacheDisable();
    Xil_ICacheDisable();

    while (1) {
        uart_test(XPAR_M01_AXI_0_BASEADDR + 0 * ADDR_OFFSET);
        spi_test(XPAR_M01_AXI_0_BASEADDR + 1 * ADDR_OFFSET);
        i2c_test(XPAR_M01_AXI_0_BASEADDR + 2 * ADDR_OFFSET);
    }

    return EXIT_SUCCESS;
}
