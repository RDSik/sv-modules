`include "rgmii_pkg.svh"

module axil_rgmii
    import rgmii_pkg::*;
#(
    parameter real  CLK_FREQ        = 50 * 10 ** 6,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   RGMII_WIDTH     = 4,
    parameter logic ILA_EN          = 0,
    parameter       MODE            = "sync",
    parameter       VENDOR          = "xilinx"
) (
    eth_if.master m_eth,

    axis_if.slave  s_axis,
    axis_if.master m_axis,

    axil_if.slave s_axil
);

    localparam int PAYLOAD_WIDTH = 11;

    rgmii_reg_t                     rd_regs;
    rgmii_reg_t                     wr_regs;

    logic       [RGMII_REG_NUM-1:0] rd_request;
    logic       [RGMII_REG_NUM-1:0] rd_valid;
    logic       [RGMII_REG_NUM-1:0] wr_valid;
    logic                           sync_arstn;

    axil_reg_file_wrap #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (RGMII_REG_NUM),
        .reg_t         (rgmii_reg_t),
        .REG_INIT      (RGMII_REG_INIT),
        .ILA_EN        (ILA_EN),
        .MODE          (MODE)
    ) i_axil_reg_file (
        .clk_i       (m_eth.tx_clk),
        .s_axil      (s_axil),
        .rd_regs_i   (rd_regs),
        .rd_valid_i  (rd_valid),
        .rd_request_o(rd_request),
        .wr_regs_o   (wr_regs),
        .wr_valid_o  (wr_valid),
        .sync_arstn_o(sync_arstn)
    );

    logic crc_err;

    always_comb begin
        rd_valid                 = '1;
        rd_regs                  = wr_regs;

        rd_regs.param.reg_num    = RGMII_REG_NUM;
        rd_regs.param.fifo_depth = 2 ** PAYLOAD_WIDTH;

        rd_regs.status.crc_err   = crc_err;
    end

    if (VENDOR == "xilinx") begin : g_mmcm
        localparam real CLK_MULT = 5;
        localparam real CLK0_DIVIDE = 2;
        localparam real CLK1_DIVIDE = 10;
        localparam real CLK2_DIVIDE = 100;

        logic clk_125_m;
        logic clk_25_m;
        logic clk_2_5_m;

        clk_manager #(
            .CLK_FREQ   (CLK_FREQ),
            .CLK_MULT   (CLK_MULT),
            .CLK0_DIVIDE(CLK0_DIVIDE),
            .CLK1_DIVIDE(CLK1_DIVIDE),
            .CLK2_DIVIDE(CLK2_DIVIDE)
        ) i_clk_manager (
            .clk_i   (clk_i),
            .rst_i   (~sync_arstn),
            .clk0_o  (clk_125_m),
            .clk1_o  (clk_25_m),
            .clk2_o  (clk_2_5_m),
            .locked_o()
        );

        assign m_eth.tx_clk = clk_125_m;
    end else begin : g_other
        assign m_eth.tx_clk = m_eth.rx_clk;
    end

    axis_rgmii #(
        .RGMII_WIDTH  (RGMII_WIDTH),
        .PAYLOAD_WIDTH(PAYLOAD_WIDTH),
        .FIFO_MODE    (MODE),
        .VENDOR       (VENDOR)
    ) i_axis_rgmii (
        .rst_i              (wr_regs.control.reset),
        .check_destination_i(wr_regs.control.check_destination),
        .payload_bytes_i    (wr_regs.control.payload_bytes),
        .fpga_port_i        (wr_regs.port.fpga),
        .fpga_ip_i          (wr_regs.ip.fpga),
        .fpga_mac_i         (wr_regs.mac.fpga),
        .host_port_i        (wr_regs.port.host),
        .host_ip_i          (wr_regs.ip.host),
        .host_mac_i         (wr_regs.mac.host),
        .crc_err_o          (crc_err),
        .m_eth              (m_eth),
        .s_axis             (s_axis),
        .m_axis             (m_axis)
    );

endmodule
