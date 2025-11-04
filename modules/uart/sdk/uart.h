#include <stdint.h>

#define UART_BASE_ADDR 0x43c00000

typedef struct __attribute__((packed)) {
    uint8_t fifo_depth;
    uint8_t reg_num;
    uint8_t data_width;
    uint8_t rsrvd;
} uart_param_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t rx_fifo_empty : 1;
    uint32_t tx_fifo_empty : 1;
    uint32_t rx_fifo_full  : 1;
    uint32_t tx_fifo_full  : 1;
    uint32_t parity_err    : 1;
    uint32_t rsrvd         : 27;
} uart_status_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t parity_even : 1;
    uint32_t parity_odd  : 1;
    uint32_t tx_reset    : 1;
    uint32_t rx_reset    : 1;
    uint32_t rsrvd       : 27;
} uart_control_reg_t;

typedef struct __attribute__((packed)) {
    uint8_t  data;
    uint32_t rsrvd : 24;
} uart_data_reg_t;

typedef volatile struct {
    uart_param_reg_t   param;
    uart_status_reg_t  status;
    uart_data_reg_t    rx;
    uart_data_reg_t    tx;
    uint32_t           clk_divider;
    uart_control_reg_t control;
} uart_regs_t;
