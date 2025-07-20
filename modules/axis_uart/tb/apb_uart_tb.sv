`timescale 1ns / 1ps

module apb_uart_tb ();

    localparam int FIFO_DEPTH = 128;
    localparam int APB_ADDR_WIDTH = 32;
    localparam int APB_DATA_WIDTH = 32;
    localparam int AXIS_DATA_WIDTH = 8;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;
    localparam int CTRL_DELAY = 4;

    logic clk_i;
    logic rstn_i;

    apb_if #(
        .ADDR_WIDTH(APB_ADDR_WIDTH),
        .DATA_WIDTH(APB_DATA_WIDTH)
    ) s_apb (
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

    end

    initial begin
        $dumpfile("apb_uart_tb.vcd");
        $dumpvars(0, axis_uart_bridge_tb);
    end

    apb_uart #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .APB_ADDR_WIDTH(APB_ADDR_WIDTH),
        .APB_DATA_WIDTH(APB_DATA_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
    ) i_axis_uart_bram_ctrl (
        .uart_rx_i(uart),
        .uart_tx_o(uart),
        .s_apb    (s_apb)
    );

endmodule
