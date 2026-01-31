#include <stdint.h>

#define I2C_BASE_OFFSET 0x20000
#define I2C_READ_ADDR   0xA1
#define I2C_WRITE_ADDR  0xA0

typedef struct __attribute__((packed)) {
    uint32_t data_width : 8;
    uint32_t reg_num    : 8;
    uint32_t fifo_depth : 8;
    uint32_t rsrvd      : 8;
} i2c_param_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t busy          : 1;
    uint32_t rx_ack        : 1;
    uint32_t tx_fifo_full  : 1;
    uint32_t rx_fifo_full  : 1;
    uint32_t tx_fifo_empty : 1;
    uint32_t rx_fifo_empty : 1;
    uint32_t rsrvd         : 26;
} i2c_status_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t prescale : 16;
    uint32_t rsrvd    : 16;
} i2c_clk_prescale_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t core_rst : 1;
    uint32_t core_en  : 1;
    uint32_t rsrvd    : 30;
} i2c_control_reg_t;

typedef struct __attribute__((packed)) {
    uint32_t data  : 8;
    uint32_t rsrvd : 24;
} i2c_data_reg_t;

typedef volatile struct {
    i2c_control_reg_t      control;
    i2c_clk_prescale_reg_t clk;
    i2c_data_reg_t         tx;
    i2c_data_reg_t         rx;
    i2c_status_reg_t       status;
    i2c_param_reg_t        param;
} i2c_regs_t;

int i2c_test();
