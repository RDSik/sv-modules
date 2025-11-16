`timescale 1ns / 1ps

`include "../rtl/spi_pkg.svh"
`include "../../verification/tb/axil_env.svh"

module axil_spi_tb ();

    import spi_pkg::*;

    localparam int FIFO_DEPTH = 128;
    localparam int CS_WIDTH = 8;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    localparam int WAT_CYCLES = 200;
    localparam int ADDR_OFFSET = AXIL_DATA_WIDTH / 8;
    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                      clk_i;
    logic                      rstn_i;
    logic [SPI_DATA_WIDTH-1:0] rdata;
    logic [SPI_DATA_WIDTH-1:0] wdata;

    spi_if #(.CS_WIDTH(CS_WIDTH)) m_spi ();

    assign m_spi.miso = m_spi.mosi;

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil (
        .clk_i (clk_i),
        .rstn_i(rstn_i)
    );

    initial begin
        rstn_i = 1'b0;
        repeat (RESET_DELAY) @(posedge clk_i);
        rstn_i = 1'b1;
        $display("Reset done in: %0t ns\n.", $time());
    end

    initial begin
        clk_i = 1'b0;
        forever begin
            #(CLK_PER_NS / 2) clk_i = ~clk_i;
        end
    end

    initial begin
        axil_env env;
        env   = new(s_axil);
        wdata = $urandom_range(0, (2 ** SPI_DATA_WIDTH) - 1);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * CLK_DIVIDER_REG_POS, 10);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * WAIT_TIME_REG_POS, 10);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * CONTROL_REG_POS, 2'b10);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * TX_DATA_REG_POS, {1'b1, wdata});
        #WAT_CYCLES;
        for (int i = 0; i < REG_NUM; i++) begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * i, rdata);
        end
        #10 $stop;
    end

    initial begin
        $dumpfile("axil_spi_tb.vcd");
        $dumpvars(0, axil_spi_tb);
    end

    axil_spi #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .SLAVE_NUM      (CS_WIDTH),
        .ILA_EN         (0)
    ) i_axil_spi (
        .s_axil(s_axil),
        .m_spi (m_spi)
    );

endmodule
