`ifndef AXI_DMA_SVH
`define AXI_DMA_SVH

`include "../../../../../../modules/axi_dma/rtl/axi_dma_pkg.svh"
`include "../../../../../../modules/verification/tb/axil_env.svh"

import axi_dma_pkg::*;

class axi_dma_class #(
    parameter int ADDR_WIDTH = 32,
    parameter int DATA_WIDTH = 32,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;

    logic                                                               [DATA_WIDTH-1:0] wdata;
    logic                                                               [DATA_WIDTH-1:0] rdata;

    axil_env #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))                         env;

    virtual axil_if #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH))                  s_axil;

    function new(
    virtual axil_if #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
    ) s_axil);
        this.s_axil = s_axil;
        env         = new(s_axil);
    endfunction

    task automatic axi_dma_reset();
        dmacr_t dmacr;
        dmacr       = '0;
        dmacr.reset = 1'b1;
        begin
            env.master_reset();
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_DMACR_REG_POS, dmacr);
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_DMACR_REG_POS, dmacr);
            dmacr.reset = 1'b0;
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_DMACR_REG_POS, dmacr);
            env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_DMACR_REG_POS, dmacr);
            $display("[%0t][AXI_DMA]: dmacr = %0d", $time, dmacr);
        end
    endtask

    task automatic axi_dma_transfer(input logic [63:0] addr, input logic [31:0] data_size, input ch_direction_e direction);
        channel_t channel_regs;
        channel_regs               = '0;
        channel_regs.addr          = addr;
        channel_regs.length.length = data_size;
        channel_regs.dmacr.rs      = 1'b1;
        begin
            if (direction == MM2S) begin
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_DMASR_REG_POS, channel_regs.dmasr);

                if (~channel_regs.dmasr.halted & ~channel_regs.dmasr.idle) begin
                    $error("[%0t][AXI_DMA]: MM2S channel is busy!", $time);
                end

                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_DMACR_REG_POS, channel_regs.dmacr);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_ADDR_LSB_REG_POS, channel_regs.addr.addr_lsb);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_ADDR_MSB_REG_POS, channel_regs.addr.addr_msb);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_LENGTH_REG_POS, channel_regs.length);
            end else begin
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_DMASR_REG_POS, channel_regs.dmasr);

                if (~channel_regs.dmasr.halted & ~channel_regs.dmasr.idle) begin
                    $error("[%0t][AXI_DMA]: S2MM channel is busy!", $time);
                end

                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_DMACR_REG_POS, channel_regs.dmacr);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_ADDR_LSB_REG_POS, channel_regs.addr.addr_lsb);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_ADDR_MSB_REG_POS, channel_regs.addr.addr_msb);
                env.master_write_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_LENGTH_REG_POS, channel_regs.length);
            end

            $display("[%0t][AXI_DMA]: addr   = %0h", $time, channel_regs.addr);
            $display("[%0t][AXI_DMA]: length = %0d", $time, channel_regs.length.length);
            $display("[%0t][AXI_DMA]: dmacr  = %0d", $time, channel_regs.dmacr);
        end
    endtask

    task automatic axi_dma_status(input ch_direction_e direction);
        dmasr_t dmasr;
        begin
            if (direction == MM2S) begin
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_MM2S_DMASR_REG_POS, dmasr);
                $display("[%0t][AXI_DMA]: MM2S", $time);
            end else begin
                env.master_read_reg(BASE_ADDR + ADDR_OFFSET * AXI_DMA_S2MM_DMASR_REG_POS, dmasr);
                $display("[%0t][AXI_DMA]: S2MM", $time);
            end

            $display("[%0t][AXI_DMA]: sg_incld          = %0d", $time, dmasr.sg_incld);
            $display("[%0t][AXI_DMA]: idle              = %0d", $time, dmasr.idle);
            $display("[%0t][AXI_DMA]: halted            = %0d", $time, dmasr.halted);
            $display("[%0t][AXI_DMA]: dma_int_err       = %0d", $time, dmasr.dma_int_err);
            $display("[%0t][AXI_DMA]: dma_slv_err       = %0d", $time, dmasr.dma_slv_err);
            $display("[%0t][AXI_DMA]: dma_dec_err       = %0d", $time, dmasr.dma_dec_err);
            $display("[%0t][AXI_DMA]: sg_int_err        = %0d", $time, dmasr.sg_int_err);
            $display("[%0t][AXI_DMA]: sg_slv_err        = %0d", $time, dmasr.sg_slv_err);
            $display("[%0t][AXI_DMA]: sg_dec_err        = %0d", $time, dmasr.sg_dec_err);
            $display("[%0t][AXI_DMA]: ioc_irq           = %0d", $time, dmasr.ioc_irq);
            $display("[%0t][AXI_DMA]: dly_irq           = %0d", $time, dmasr.dly_irq);
            $display("[%0t][AXI_DMA]: err_irq           = %0d", $time, dmasr.err_irq);
            $display("[%0t][AXI_DMA]: irq_treshhold_sts = %0d", $time, dmasr.irq_treshhold_sts);
            $display("[%0t][AXI_DMA]: irq_delay_sts     = %0d", $time, dmasr.irq_delay_sts);

            $display("[%0t][AXI_DMA]: base_addr         = %0h", $time, BASE_ADDR);
        end
    endtask

endclass

`endif  // AXI_DMA_SVH
