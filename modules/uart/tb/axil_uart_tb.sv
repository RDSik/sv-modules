`timescale 1ns / 1ps

`include "modules/uart/tb/axil_uart_class.svh"

module axil_uart_tb ();

    localparam int FIFO_DEPTH = 128;
    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic clk_i;
    logic arstn_i;
    logic rx_tx;

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
        axil_uart_class #(
            .DATA_WIDTH(AXIL_DATA_WIDTH),
            .ADDR_WIDTH(AXIL_ADDR_WIDTH),
            .BASE_ADDR (BASE_ADDR)
        ) uart;
        uart = new(s_axil);
        uart.uart_start();
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
        .arstn_i  (arstn_i),
        .uart_rx_i(rx_tx),
        .uart_tx_o(rx_tx),
        .s_axil   (s_axil)
    );

endmodule
