`timescale 1ns / 1ps

`include "../rtl/i2c_pkg.svh"
`include "../../verification/tb/axil_env.svh"

module axil_i2c_tb ();

    import i2c_pkg::*;

    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;

    localparam int WAT_CYCLES = 200;
    localparam int ADDR_OFFSET = AXIL_DATA_WIDTH / 8;
    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                  clk_i;
    logic                  rstn_i;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;

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
        wdata = 8'b10101011;
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * COMMAND_REG_POS, 5'b10011);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * CLK_PRESCALE_REG_POS, 10);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * TX_DATA_REG_POS, wdata);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * CONTROL_REG_POS, 2'b10);
        for (int i = 0; i < REG_NUM; i++) begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * i, rdata);
        end
        #WAT_CYCLES $stop;
    end

    initial begin
        $dumpfile("axil_i2c_tb.vcd");
        $dumpvars(0, axil_i2c_tb);
    end

    axil_i2c #(
        .AXIL_DATA_WIDTH(AXIL_DATA_WIDTH),
        .AXIL_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .ILA_EN         (0)
    ) i_axil_i2c (
        .scl_pad_i   (),
        .scl_pad_o   (),
        .scl_padoen_o(),
        .sda_pad_i   (),
        .sda_pad_o   (),
        .sda_padoen_o(),
        .s_axil      (s_axil)
    );

endmodule
