`ifndef AXI_DMA_PKG_SVH
`define AXI_DMA_PKG_SVH

package axi_dma_pkg;

    typedef enum logic {
        S2MM,
        MM2S
    } ch_direction_e;

    typedef struct packed {
        logic [7:0] irq_delay;         // 24 - 31
        logic [7:0] irq_treshhold;     // 16 -23
        logic       reserved_2;        // 15
        logic       err_irqen;         // 14
        logic       dly_irqen;         // 13
        logic       ioc_irqen;         // 12
        logic [6:0] reserved_1;        // 5 - 11
        logic       cyclic_bd_enable;  // 4
        logic       keyhole;           // 3
        logic       reset;             // 2
        logic       reserved_0;        // 1
        logic       rs;                // 0
    } dmacr_t;

    typedef struct packed {
        logic [7:0] irq_delay_sts;      // 24 - 31
        logic [7:0] irq_treshhold_sts;  // 16 - 23
        logic       reserved_3;         // 15
        logic       err_irq;            // 14
        logic       dly_irq;            // 13
        logic       ioc_irq;            // 12
        logic       reserved_2;         // 11
        logic       sg_dec_err;         // 10
        logic       sg_slv_err;         // 9
        logic       sg_int_err;         // 8
        logic       reserved_1;         // 7
        logic       dma_dec_err;        // 6
        logic       dma_slv_err;        // 5
        logic       dma_int_err;        // 4 
        logic       sg_incld;           // 3
        logic       reserved_0;         // 2
        logic       idle;               // 1
        logic       halted;             // 0
    } dmasr_t;

    typedef struct packed {
        logic [31:0] addr_msb;
        logic [31:0] addr_lsb;
    } addr_t;

    typedef struct packed {
        logic [5:0]  reserved;  // 26 - 31
        logic [25:0] length;    // 0 - 25
    } length_t;

    typedef struct packed {
        logic [25:0] current_descriptor_pointer;  // 6 - 31
        logic [5:0]  reserved;                    // 0 - 5
    } curdes_lsb_t;

    typedef struct packed {logic [31:0] current_descriptor_pointer;} curdes_msb_t;

    typedef struct packed {
        logic [25:0] tail_descriptor_pointer;  // 6 - 31
        logic [5:0]  reserved;                 // 0 - 5
    } taildesc_lsb_t;

    typedef struct packed {logic [31:0] tail_descriptor_pointer;} taildesc_msb_t;

    typedef struct packed {
        taildesc_msb_t taildesc_msb;
        taildesc_lsb_t taildesc_lsb;
        curdes_msb_t   curdesc_msb;
        curdes_lsb_t   curdesc_lsb;
    } sg_t;

    typedef struct packed {
        logic [19:0] reserved_1;  // 12 - 31
        logic [3:0]  sg_user;     // 8 - 11
        logic [3:0]  reserved_0;  // 4 - 7
        logic [3:0]  sg_cache;    // 0 - 3
    } sg_ctl_t;

    typedef struct packed {
        length_t length;
        addr_t   addr;
        sg_t     sg;
        dmasr_t  dmasr;
        dmacr_t  dmacr;
    } channel_t;

    typedef struct packed {
        channel_t s2mm;
        sg_ctl_t  sg_ctl;
        channel_t mm2s;
    } axi_dma_direct_t;

    localparam int AXI_DMA_MM2S_DMACR_REG_POS = 0;
    localparam int AXI_DMA_MM2S_DMASR_REG_POS = AXI_DMA_MM2S_DMACR_REG_POS + $bits(dmacr_t) / 32;
    localparam int AXI_DMA_MM2S_CURDES_LSB_REG_POS = AXI_DMA_MM2S_DMASR_REG_POS + $bits(dmasr_t) / 32;
    localparam int AXI_DMA_MM2S_CURDES_MSB_REG_POS = AXI_DMA_MM2S_CURDES_LSB_REG_POS + $bits(curdes_lsb_t) / 32;
    localparam int AXI_DMA_MM2S_TAILDESC_LSB_REG_POS = AXI_DMA_MM2S_CURDES_MSB_REG_POS + $bits(curdes_msb_t) / 32;
    localparam int AXI_DMA_MM2S_TAILDESC_MSB_REG_POS = AXI_DMA_MM2S_TAILDESC_LSB_REG_POS + $bits(taildesc_lsb_t) / 32;
    localparam int AXI_DMA_MM2S_ADDR_LSB_REG_POS = AXI_DMA_MM2S_TAILDESC_MSB_REG_POS + $bits(taildesc_msb_t) / 32;
    localparam int AXI_DMA_MM2S_ADDR_MSB_REG_POS = AXI_DMA_MM2S_ADDR_LSB_REG_POS + 1;
    localparam int AXI_DMA_MM2S_LENGTH_REG_POS = AXI_DMA_MM2S_ADDR_MSB_REG_POS + 3;

    localparam int AXI_DMA_SG_CTL_REG_POS = AXI_DMA_MM2S_LENGTH_REG_POS + $bits(length_t) / 32;

    localparam int AXI_DMA_S2MM_DMACR_REG_POS = AXI_DMA_SG_CTL_REG_POS + $bits(sg_ctl_t) / 32;
    localparam int AXI_DMA_S2MM_DMASR_REG_POS = AXI_DMA_S2MM_DMACR_REG_POS + $bits(dmacr_t) / 32;
    localparam int AXI_DMA_S2MM_CURDES_LSB_REG_POS = AXI_DMA_S2MM_DMASR_REG_POS + $bits(dmasr_t) / 32;
    localparam int AXI_DMA_S2MM_CURDES_MSB_REG_POS = AXI_DMA_S2MM_CURDES_LSB_REG_POS + $bits(curdes_lsb_t) / 32;
    localparam int AXI_DMA_S2MM_TAILDESC_LSB_REG_POS = AXI_DMA_S2MM_CURDES_MSB_REG_POS + $bits(curdes_msb_t) / 32;
    localparam int AXI_DMA_S2MM_TAILDESC_MSB_REG_POS = AXI_DMA_S2MM_TAILDESC_LSB_REG_POS + $bits(taildesc_lsb_t) / 32;
    localparam int AXI_DMA_S2MM_ADDR_LSB_REG_POS = AXI_DMA_S2MM_TAILDESC_MSB_REG_POS + $bits(taildesc_msb_t) / 32;
    localparam int AXI_DMA_S2MM_ADDR_MSB_REG_POS = AXI_DMA_S2MM_ADDR_LSB_REG_POS + 1;
    localparam int AXI_DMA_S2MM_LENGTH_REG_POS = AXI_DMA_S2MM_ADDR_MSB_REG_POS + 3;

endpackage

`endif  // AXI_DMA_PKG_SVH
