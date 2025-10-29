`timescale 1ns / 1ps

`include "../../verification/tb/axil_env.svh"

module axil_i2c_tb ();

    localparam int ADDR_WIDTH = 32;
    localparam int DATA_WIDTH = 32;

    localparam int WAT_CYCLES = 200;
    localparam int ADDR_OFFSET = DATA_WIDTH / 8;
    localparam logic [ADDR_WIDTH-1:0] BASE_ADDR = 'h200000;

    localparam int CLK_PER_NS = 2;
    localparam int RESET_DELAY = 10;

    logic                  clk_i;
    logic                  rstn_i;
    logic [DATA_WIDTH-1:0] wdata;
    logic [DATA_WIDTH-1:0] rdata;

    axil_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
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
        wdata = $urandom_range(0, (2 * DATA_WIDTH) - 1);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * 2, 8'b1000_0000);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * 3, wdata);
        env.master_write_reg(BASE_ADDR + ADDR_OFFSET * 4, 8'b1001_0000);
        for (int i = 0; i < 5; i++) begin
            env.master_read_reg(BASE_ADDR + ADDR_OFFSET * i, rdata);
        end
        #WAT_CYCLES $stop;
    end

    initial begin
        $dumpfile("axil_i2c_tb.vcd");
        $dumpvars(0, axil_i2c_tb);
    end

    axil_i2c #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
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
