#include <stdint.h>

#define SPI_ADDR_OFFSET 0x10000

typedef struct __attribute__((packed)) {
    uint32_t data_width : 8;
    uint32_t reg_num    : 8;
    uint32_t fifo_depth : 8;
    uint32_t rsrvd      : 8;
} spi_param_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t tx_fifo_full  : 1;
    uint32_t rx_fifo_full  : 1;
    uint32_t tx_fifo_empty : 1;
    uint32_t rx_fifo_empty : 1;
    uint32_t rsrvd         : 28;
} spi_status_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t select : 8;
    uint32_t rsrvd  : 24;
} spi_slave_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t reset : 1;
    uint32_t cpha  : 1;
    uint32_t cpol  : 1;
    uint32_t rsrvd : 29;
} spi_control_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t data  : 8;
    uint32_t last  : 1;
    uint32_t rsrvd : 23;
} spi_data_reg_t;

typedef volatile struct {
    spi_control_reg_t  control;
    uint32_t           clk_divider;
    uint32_t           wait_time;
    spi_slave_reg_t    slave;
    spi_data_reg_t     tx;
    spi_data_reg_t     rx;
    spi_status_reg_t   status;
    spi_param_reg_t    param;
} spi_regs_t;

int spi_test();
