`ifndef AXIL_RGMII_SVH
`define AXIL_RGMII_SVH

`include "modules/rgmii/rtl/rgmii_pkg.svh"
`include "modules/verification/tb/axil_env.svh"
`include "modules/verification/tb/env.svh"

import rgmii_pkg::*;

class axil_rgmii_class #(
    parameter int                    ADDR_WIDTH = 32,
    parameter int                    DATA_WIDTH = 32,
    parameter logic                  TLAST_EN   = 1,
    parameter logic [ADDR_WIDTH-1:0] BASE_ADDR  = 'h200000
);

    localparam int ADDR_OFFSET = DATA_WIDTH / 8;

    localparam logic CHECK_DESTINATION = 1;
    localparam logic [7:0] FPGA_IP_1 = 10;
    localparam logic [7:0] FPGA_IP_2 = 0;
    localparam logic [7:0] FPGA_IP_3 = 0;
    localparam logic [7:0] FPGA_IP_4 = 240;
    localparam logic [7:0] HOST_IP_1 = 10;
    localparam logic [7:0] HOST_IP_2 = 0;
    localparam logic [7:0] HOST_IP_3 = 0;
    localparam logic [7:0] HOST_IP_4 = 10;
    localparam logic [15:0] FPGA_PORT = 17767;
    localparam logic [15:0] HOST_PORT = 17767;
    localparam logic [47:0] FPGA_MAC = 48'he86a64e7e830;
    localparam logic [47:0] HOST_MAC = 48'he86a64e7e829;

    localparam int PAYLOAD = 340;
    localparam logic [31:0] HOST_IP = {HOST_IP_1, HOST_IP_2, HOST_IP_3, HOST_IP_4};
    localparam logic [31:0] FPGA_IP = {FPGA_IP_1, FPGA_IP_2, FPGA_IP_3, FPGA_IP_4};

    env_base #(
        .DATA_WIDTH_IN (DATA_WIDTH / ADDR_OFFSET),
        .DATA_WIDTH_OUT(DATA_WIDTH / ADDR_OFFSET),
        .TLAST_EN      (TLAST_EN)
    ) env;

    virtual axis_if #(.DATA_WIDTH(DATA_WIDTH / ADDR_OFFSET)) s_axis;

    virtual axis_if #(.DATA_WIDTH(DATA_WIDTH / ADDR_OFFSET)) m_axis;

    axil_env #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) axil_env;

    virtual axil_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) s_axil;

    function new(
    virtual axil_if #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) s_axil,
                 virtual axis_if #(.DATA_WIDTH(DATA_WIDTH / ADDR_OFFSET)) m_axis,
                 virtual axis_if #(.DATA_WIDTH(DATA_WIDTH / ADDR_OFFSET)) s_axis);
        this.s_axil = s_axil;
        this.s_axis = s_axis;
        this.m_axis = m_axis;
        axil_env    = new(s_axil);
        env         = new(s_axis, m_axis);
    endfunction

    task automatic rgmii_read_regs();
        rgmii_reg_t rgmii_regs;
        begin
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_CONTROL_REG_POS,
                                     rgmii_regs.control);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_PORT_REG_POS, rgmii_regs.port);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_FPGA_IP_REG_POS,
                                     rgmii_regs.ip.fpga);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_HOST_IP_REG_POS,
                                     rgmii_regs.ip.host);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_FPGA_MAC_REG_POS,
                                     rgmii_regs.mac.fpga);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_HOST_MAC_REG_POS,
                                     rgmii_regs.mac.host);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_STATUS_REG_POS,
                                     rgmii_regs.status);
            axil_env.master_read_reg(BASE_ADDR + ADDR_OFFSET * RGMII_PARAM_REG_POS,
                                     rgmii_regs.param);

            $display("[%0t][RGMII]: reset             = %0d", $time, rgmii_regs.control.reset);
            $display("[%0t][RGMII]: payload_bytes     = %0d", $time,
                     rgmii_regs.control.payload_bytes);
            $display("[%0t][RGMII]: check_destination = %0d", $time,
                     rgmii_regs.control.check_destination);
            $display("[%0t][RGMII]: port_fpga         = %0h", $time, rgmii_regs.port.fpga);
            $display("[%0t][RGMII]: port_host         = %0h", $time, rgmii_regs.port.host);
            $display("[%0t][RGMII]: ip_fpga           = %0h", $time, rgmii_regs.ip.fpga);
            $display("[%0t][RGMII]: ip_host           = %0h", $time, rgmii_regs.ip.host);
            $display("[%0t][RGMII]: mac_fpga          = %0h", $time, rgmii_regs.mac.fpga);
            $display("[%0t][RGMII]: mac_host          = %0h", $time, rgmii_regs.mac.host);
            $display("[%0t][RGMII]: crc_err           = %0d", $time, rgmii_regs.status.crc_err);
            $display("[%0t][RGMII]: fifo_depth        = %0d", $time, rgmii_regs.param.fifo_depth);
            $display("[%0t][RGMII]: reg_num           = %0d", $time, rgmii_regs.param.reg_num);
        end
    endtask

    task automatic rgmii_regs_init(logic [CONFIG_REG_NUM-1:0][DATA_WIDTH-1:0] config_regs);
        begin
            for (int i = 0; i < CONFIG_REG_NUM; i++) begin
                axil_env.master_write_reg(BASE_ADDR + ADDR_OFFSET * i, config_regs[i]);
            end
        end
    endtask

    task automatic rgmii_start();
        rgmii_config_t rgmii_regs;
        rgmii_regs                           = '0;
        rgmii_regs.control.payload_bytes     = PAYLOAD;
        rgmii_regs.control.check_destination = CHECK_DESTINATION;
        rgmii_regs.mac.fpga                  = FPGA_MAC;
        rgmii_regs.mac.host                  = HOST_MAC;
        rgmii_regs.ip.fpga                   = FPGA_IP;
        rgmii_regs.ip.host                   = HOST_IP;
        rgmii_regs.port.fpga                 = FPGA_PORT;
        rgmii_regs.port.host                 = HOST_PORT;
        begin
            rgmii_regs_init(rgmii_regs);
            rgmii_read_regs();
            env.run();
        end
    endtask

endclass

`endif  // AXIL_RGMII_SVH
