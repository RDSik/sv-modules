#include "uart.h"

#include "xil_cache.h"

int main() {
    Xil_DCacheDisable();
    Xil_ICacheDisable();

    while(1) {
        uart_test();
    }
}
