`timescale 1ns / 1ps

`include "axi_dma_class.svh"

module axi_dma_tb ();

    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = '0;
    localparam logic [AXIL_ADDR_WIDTH-1:0] MEM_ADDR = 'hc000_0000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;
    localparam int WAT_CYCLES = 250;

    logic clk_i;
    logic arstn_i;
    logic s2mm_introut;
    logic mm2s_introut;

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil (
        .clk_i  (clk_i),
        .arstn_i(arstn_i)
    );

    initial begin
        arstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        arstn_i = 1'b1;
        $display("Reset done in: %0t ns\n.", $time());
    end

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER_NS / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        axi_dma_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (BASE_ADDR)
        ) dma;
        dma = new(s_axil);
        dma.axi_dma_tansfer(MEM_ADDR, 128, MM2S);
        dma.axi_dma_tansfer(MEM_ADDR, 128, S2MM);
        dma.status();
        #WAT_CYCLES;
        $stop;
    end

    initial begin
        $dumpfile("axi_dma_tb.vcd");
        $dumpvars(0, axi_dma_tb);
    end

    axi_dma_test_wrap i_axi_dma_test_wrap (
        .s_axil        (s_axil),
        .s2mm_introut_o(s2mm_introut),
        .mm2s_introut_o(mm2s_introut)
    );

endmodule
