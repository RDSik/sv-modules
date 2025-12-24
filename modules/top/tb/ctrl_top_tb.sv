`timescale 1ns / 1ps

`include "../../spi/tb/axil_spi_class.svh"
`include "../../uart/tb/axil_uart_class.svh"
`include "../../i2c/tb/axil_i2c_class.svh"

module ctrl_top_tb ();

    localparam int FIFO_DEPTH = 128;
    localparam int CS_WIDTH = 8;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;
    localparam int MASTER_NUM = 1;
    localparam int SLAVE_NUM = 3;

    localparam logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_LOW_ADDR = '{
        32'h43c0_0000,
        32'h43c1_0000,
        32'h43c2_0000
    };
    localparam logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_HIGH_ADDR = '{
        32'h43c0_ffff,
        32'h43c1_ffff,
        32'h43c2_ffff
    };

    localparam int WAT_CYCLES = 250;
    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic clk_i;
    logic rstn_i;
    logic uart;

    spi_if #(.CS_WIDTH(CS_WIDTH)) m_spi ();

    assign m_spi.miso = m_spi.mosi;

    axil_if #(
        .ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .DATA_WIDTH(AXIL_DATA_WIDTH)
    ) s_axil[MASTER_NUM-1:0] (
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
        axil_uart_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (SLAVE_LOW_ADDR[2])
        ) uart;
        axil_spi_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (SLAVE_LOW_ADDR[1])
        ) spi;
        axil_i2c_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (SLAVE_LOW_ADDR[0])
        ) i2c;
        uart = new(s_axil[0]);
        spi  = new(s_axil[0]);
        i2c  = new(s_axil[0]);
        uart.uart_start();
        spi.spi_start();
        i2c.i2c_start();
        #WAT_CYCLES;
        $stop;
    end

    initial begin
        $dumpfile("ctrl_top_tb.vcd");
        $dumpvars(0, ctrl_top_tb);
    end

    ctrl_top #(
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .FIFO_DEPTH     (FIFO_DEPTH),
        .SPI_CS_WIDTH   (CS_WIDTH),
        .SLAVE_NUM      (SLAVE_NUM),
        .MASTER_NUM     (MASTER_NUM),
        .SLAVE_LOW_ADDR (SLAVE_LOW_ADDR),
        .SLAVE_HIGH_ADDR(SLAVE_HIGH_ADDR),
        .ILA_EN         (0),
        .MODE           ("sync")
    ) i_ctrl_top (
        .clk_i    (clk_i),
        .uart_rx_i(uart),
        .uart_tx_o(uart),
        .s_axil   (s_axil),
        .m_spi    (m_spi)
    );

endmodule
