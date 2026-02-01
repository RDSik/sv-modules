#include "XAxidma.h"
#include "uart.h"
#include "spi.h"
#include "i2c.h"

#include "xil_cache.h"

int main() {
    Xil_DCacheDisable();
    Xil_ICacheDisable();

    while (1) {
        uart_test();
        spi_test();
        i2c_test();
    }

    return EXIT_SUCCESS;
}
