#include <stdint.h>

#define UART_ADDR_OFFSET 0x0

typedef struct __attribute__((packed)) {
    uint32_t data_width : 8;
    uint32_t reg_num    : 8;
    uint32_t fifo_depth : 8;
    uint32_t rsrvd      : 8;
} uart_param_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t parity_err    : 1;
    uint32_t tx_fifo_full  : 1;
    uint32_t rx_fifo_full  : 1;
    uint32_t tx_fifo_empty : 1;
    uint32_t rx_fifo_empty : 1;
    uint32_t rsrvd         : 27;
} uart_status_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t rx_reset    : 1;
    uint32_t tx_reset    : 1;
    uint32_t parity_odd  : 1;
    uint32_t parity_even : 1;
    uint32_t rsrvd       : 28;
} uart_control_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t data  : 8;
    uint32_t rsrvd : 24;
} uart_data_reg_t;

typedef volatile struct {
    uart_control_reg_t control;
    uint32_t           clk_divider;
    uart_data_reg_t    tx;
    uart_data_reg_t    rx;
    uart_status_reg_t  status;
    uart_param_reg_t   param;
} uart_regs_t;

int uart_test(uint32_t module_addr);
