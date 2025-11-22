`timescale 1ns / 1ps

`include "../rtl/uart_pkg.svh"
`include "../../verification/tb/axil_env.svh"

module axil_uart_tb ();

    import uart_pkg::*;

    localparam int FIFO_DEPTH = 128;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    localparam int ADDR_OFFSET = AXIL_DATA_WIDTH / 8;
    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                       clk_i;
    logic                       rstn_i;
    logic [AXIL_DATA_WIDTH-1:0] wdata;
    logic [AXIL_DATA_WIDTH-1:0] rdata;

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
        wdata = $urandom_range(0, (2 ** UART_DATA_WIDTH) - 1);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * CLK_DIVIDER_REG_POS, 10);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * CONTROL_REG_POS, 0);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * TX_DATA_REG_POS, wdata);
        do begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * STATUS_REG_POS, rdata);
        end while (rdata[4]);
        for (int i = 0; i < REG_NUM; i++) begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * i, rdata);
        end
        #10 $stop;
    end

    initial begin
        $dumpfile("axil_uart_tb.vcd");
        $dumpvars(0, axil_uart_tb);
    end

    axil_uart #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .ILA_EN         (0),
        .MODE           ("sync")
    ) i_axil_uart (
        .clk_i    (clk_i),
        .uart_rx_i(uart),
        .uart_tx_o(uart),
        .s_axil   (s_axil)
    );

endmodule
