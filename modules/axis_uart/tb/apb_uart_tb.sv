`timescale 1ns / 1ps

`include "../rtl/uart_pkg.svh"

module apb_uart_tb ();
    import uart_pkg::*;

    localparam int FIFO_DEPTH = 128;
    localparam int APB_ADDR_WIDTH = 32;
    localparam int APB_DATA_WIDTH = 32;
    localparam int AXIS_DATA_WIDTH = 8;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

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
        wait (rstn_i);
        uart_init();
    end

    initial begin
        $dumpfile("apb_uart_tb.vcd");
        $dumpvars(0, apb_uart_tb);
    end

    task static uart_init;
        uart_wr_regs_t uart_regs;
        logic [31:0] rdata;
        logic [31:0] wdata;
        begin
            wdata                 = $urandom_range(0, (2 * 8) - 1);
            uart_regs             = '0;
            uart_regs.clk_divider = 10;
            uart_regs.tx.data     = wdata;
            write_reg(CONTROL_REG_POS * 4, uart_regs.control);
            write_reg(CLK_DIVIDER_REG_POS * 4, uart_regs.clk_divider);
            write_reg(TX_DATA_REG_POS * 4, uart_regs.tx.data);
            #190;
            for (int i = 0; i < RD_REG_NUM; i++) begin
                read_reg(i * 4, rdata);
            end
            #20;
            if (wdata == rdata) begin
                $display("Success wdata = %0d, rdata = %0d", wdata, rdata);
            end else begin
                $display("Error wdata = %0d, rdata = %0d", wdata, rdata);
            end
        end
        $stop;
    endtask

    task static write_reg;
        input logic [31:0] addr;
        input logic [31:0] data;
        begin
            @(posedge clk_i);
            s_apb.pwdata  = data;
            s_apb.paddr   = addr;
            s_apb.penable = 1'b1;
            s_apb.psel    = 1'b1;
            s_apb.pwrite  = 1'b1;
            wait (s_apb.pready);
            $display("%0t Write data: addr - %0d, data - %0d\n", $time, addr, data);
            @(posedge clk_i);
            s_apb.psel    = 1'b0;
            s_apb.penable = 1'b0;
        end
    endtask

    task static read_reg;
        input logic [31:0] addr;
        output logic [31:0] data;
        begin
            @(posedge clk_i);
            s_apb.paddr   = addr;
            s_apb.psel    = 1'b1;
            s_apb.penable = 1'b1;
            s_apb.pwrite  = 1'b0;
            wait (s_apb.pready);
            data = s_apb.prdata;
            $display("%0t Read data: addr - %0d, data - %0d\n", $time, addr, data);
            @(posedge clk_i);
            s_apb.psel    = 1'b0;
            s_apb.penable = 1'b0;
        end
    endtask

    apb_uart #(
        .FIFO_DEPTH     (FIFO_DEPTH),
        .APB_ADDR_WIDTH (APB_ADDR_WIDTH),
        .APB_DATA_WIDTH (APB_DATA_WIDTH),
        .AXIS_DATA_WIDTH(AXIS_DATA_WIDTH)
    ) i_apb_uart (
        .uart_rx_i(uart),
        .uart_tx_o(uart),
        .s_apb    (s_apb)
    );

endmodule
