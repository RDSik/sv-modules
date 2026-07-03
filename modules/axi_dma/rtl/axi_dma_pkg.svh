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
        logic       reserved;          // 15
        logic       err_irqen;         // 14
        logic       dly_irqen;         // 13
        logic       ioc_irqen;         // 12
        logic [6:0] reserved;          // 5 - 11
        logic       cyclic_bd_enable;  // 4
        logic       keyhole;           // 3
        logic       reset;             // 2
        logic       reserved;          // 1
        logic       rs;                // 0
    } dmacr_reg_t;

    typedef struct packed {
        logic [7:0] irq_delay_sts;      // 24 - 31
        logic [7:0] irq_treshhold_sts;  // 16 - 23
        logic       reserved;           // 15
        logic       err_irq;            // 14
        logic       dly_irq;            // 13
        logic       ioc_irq;            // 12
        logic       reserved;           // 11
        logic       sg_dec_err;         // 10
        logic       sg_slv_err;         // 9
        logic       sg_int_err;         // 8
        logic       reserved;           // 7
        logic       dma_dec_err;        // 6
        logic       dma_slv_err;        // 5
        logic       dma_int_err;        // 4 
        logic       sg_incld;           // 3
        logic       reserved;           // 2
        logic       idle;               // 1
        logic       halted;             // 0
    } dmasr_reg_t;

    typedef struct packed {
        logic [31:0] addr_msb;
        logic [31:0] addr_lsb;
    } addr_reg_t;

    typedef struct packed {
        logic [5:0]  reserverd;  // 26 - 31
        logic [25:0] length;     // 0 - 25
    } length_reg_t;

    typedef struct packed {
        logic [25:0] current_descriptor_pointer;  // 6 - 31
        logic [5:0]  reserved;                    // 0 - 5
    } curdesc_lsb_reg_t;

    typedef struct packed {logic [31:0] current_descriptor_pointer;} curdesc_msb_reg_t;

    typedef struct packed {
        logic [25:0] tail_descriptor_pointer;  // 6 - 31
        logic [5:0]  reserved;                 // 0 - 5
    } taildesc_lsb_reg_t;

    typedef struct packed {logic [31:0] tail_descriptor_pointer;} taildesc_msb_reg_t;

    typedef struct packed {
        taildesc_msb_reg_t taildesc_msb;
        taildesc_lsb_reg_t taildesc_lsb;
        curdesc_msb_reg_t  curdesc_msb;
        curdesc_lsb_reg_t  curdesc_lsb;
    } sg_reg_t;

    typedef union {
        sg_reg_t          regs;
        logic [3:0][31:0] reserved;
    } sg_union_reg_t;

    typedef struct packed {
        length_reg_t   length;
        addr_reg_t     addr;
        sg_union_reg_t sg;
        dmasr_reg_t    dmasr;
        dmacr_reg_t    dmacr;
    } channel_t;

    typedef struct packed {
        channel_t s2mm;
        channel_t mm2s;
    } axi_dma_direct_reg_t;

    localparam int CHANNGEL_OFFSET = $bits(channel_t) / 32;

    localparam int AXI_DMA_MM2S_DMACR_REG_POS = 0;
    localparam int AXI_DMA_MM2S_DMASR_REG_POS = AXI_DMA_MM2S_DMACR_REG_POS + $bits(dmacr_reg_t) / 32;
    localparam int AXI_DMA_MM2S_ADDR_LSB_REG_POS = AXI_DMA_MM2S_DMASR_REG_POS + $bits(sg_union_reg_t) / 32;
    localparam int AXI_DMA_MM2S_ADDR_MSB_REG_POS = AXI_DMA_MM2S_ADDR_LSB_REG_POS + 1;
    localparam int AXI_DMA_MM2S_LENGTH_REG_POS = AXI_DMA_MM2S_ADDR_LSB_REG_POS + $bits(addr_reg_t) / 32;

    localparam int AXI_DMA_S2MM_DMACR_REG_POS = AXI_DMA_MM2S_DMACR_REG_POS + $bits(channel_t) / 32;
    localparam int AXI_DMA_S2MM_DMASR_REG_POS = AXI_DMA_S2MM_DMACR_REG_POS + $bits(dmacr_reg_t) / 32;
    localparam int AXI_DMA_S2MM_ADDR_LSB_REG_POS = AXI_DMA_S2MM_DMASR_REG_POS + $bits(sg_union_reg_t) / 32;
    localparam int AXI_DMA_S2MM_ADDR_MSB_REG_POS = AXI_DMA_S2MM_ADDR_LSB_REG_POS + 1;
    localparam int AXI_DMA_S2MM_LENGTH_REG_POS = AXI_DMA_S2MM_ADDR_LSB_REG_POS + $bits(addr_reg_t) / 32;

    localparam int AXI_DMA_REG_NUM = $bits(axi_dma_direct_reg_t) / 32;

endpackage

`endif  // AXI_DMA_PKG_SVH
