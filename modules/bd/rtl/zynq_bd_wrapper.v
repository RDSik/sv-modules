//Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2019.1 (win64) Build 2552052 Fri May 24 14:49:42 MDT 2019
//Date        : Sun Aug 24 22:16:57 2025
//Host        : DESKTOP-FQLV1IA running 64-bit major release  (build 9200)
//Command     : generate_target zynq_bd_wrapper.bd
//Design      : zynq_bd_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module zynq_bd_wrapper (
    APB_M_0_paddr,
    APB_M_0_penable,
    APB_M_0_prdata,
    APB_M_0_pready,
    APB_M_0_psel,
    APB_M_0_pslverr,
    APB_M_0_pwdata,
    APB_M_0_pwrite,
    DDR_0_addr,
    DDR_0_ba,
    DDR_0_cas_n,
    DDR_0_ck_n,
    DDR_0_ck_p,
    DDR_0_cke,
    DDR_0_cs_n,
    DDR_0_dm,
    DDR_0_dq,
    DDR_0_dqs_n,
    DDR_0_dqs_p,
    DDR_0_odt,
    DDR_0_ras_n,
    DDR_0_reset_n,
    DDR_0_we_n,
    FCLK_CLK0_0,
    FIXED_IO_0_ddr_vrn,
    FIXED_IO_0_ddr_vrp,
    FIXED_IO_0_mio,
    FIXED_IO_0_ps_clk,
    FIXED_IO_0_ps_porb,
    FIXED_IO_0_ps_srstb,
    peripheral_aresetn_0
);
    output [31:0] APB_M_0_paddr;
    output APB_M_0_penable;
    input [31:0] APB_M_0_prdata;
    input [0:0] APB_M_0_pready;
    output [0:0] APB_M_0_psel;
    input [0:0] APB_M_0_pslverr;
    output [31:0] APB_M_0_pwdata;
    output APB_M_0_pwrite;
    inout [14:0] DDR_0_addr;
    inout [2:0] DDR_0_ba;
    inout DDR_0_cas_n;
    inout DDR_0_ck_n;
    inout DDR_0_ck_p;
    inout DDR_0_cke;
    inout DDR_0_cs_n;
    inout [3:0] DDR_0_dm;
    inout [31:0] DDR_0_dq;
    inout [3:0] DDR_0_dqs_n;
    inout [3:0] DDR_0_dqs_p;
    inout DDR_0_odt;
    inout DDR_0_ras_n;
    inout DDR_0_reset_n;
    inout DDR_0_we_n;
    output FCLK_CLK0_0;
    inout FIXED_IO_0_ddr_vrn;
    inout FIXED_IO_0_ddr_vrp;
    inout [53:0] FIXED_IO_0_mio;
    inout FIXED_IO_0_ps_clk;
    inout FIXED_IO_0_ps_porb;
    inout FIXED_IO_0_ps_srstb;
    output [0:0] peripheral_aresetn_0;

    wire [31:0] APB_M_0_paddr;
    wire APB_M_0_penable;
    wire [31:0] APB_M_0_prdata;
    wire [0:0] APB_M_0_pready;
    wire [0:0] APB_M_0_psel;
    wire [0:0] APB_M_0_pslverr;
    wire [31:0] APB_M_0_pwdata;
    wire APB_M_0_pwrite;
    wire [14:0] DDR_0_addr;
    wire [2:0] DDR_0_ba;
    wire DDR_0_cas_n;
    wire DDR_0_ck_n;
    wire DDR_0_ck_p;
    wire DDR_0_cke;
    wire DDR_0_cs_n;
    wire [3:0] DDR_0_dm;
    wire [31:0] DDR_0_dq;
    wire [3:0] DDR_0_dqs_n;
    wire [3:0] DDR_0_dqs_p;
    wire DDR_0_odt;
    wire DDR_0_ras_n;
    wire DDR_0_reset_n;
    wire DDR_0_we_n;
    wire FCLK_CLK0_0;
    wire FIXED_IO_0_ddr_vrn;
    wire FIXED_IO_0_ddr_vrp;
    wire [53:0] FIXED_IO_0_mio;
    wire FIXED_IO_0_ps_clk;
    wire FIXED_IO_0_ps_porb;
    wire FIXED_IO_0_ps_srstb;
    wire [0:0] peripheral_aresetn_0;

    zynq_bd zynq_bd_i (
        .APB_M_0_paddr(APB_M_0_paddr),
        .APB_M_0_penable(APB_M_0_penable),
        .APB_M_0_prdata(APB_M_0_prdata),
        .APB_M_0_pready(APB_M_0_pready),
        .APB_M_0_psel(APB_M_0_psel),
        .APB_M_0_pslverr(APB_M_0_pslverr),
        .APB_M_0_pwdata(APB_M_0_pwdata),
        .APB_M_0_pwrite(APB_M_0_pwrite),
        .DDR_0_addr(DDR_0_addr),
        .DDR_0_ba(DDR_0_ba),
        .DDR_0_cas_n(DDR_0_cas_n),
        .DDR_0_ck_n(DDR_0_ck_n),
        .DDR_0_ck_p(DDR_0_ck_p),
        .DDR_0_cke(DDR_0_cke),
        .DDR_0_cs_n(DDR_0_cs_n),
        .DDR_0_dm(DDR_0_dm),
        .DDR_0_dq(DDR_0_dq),
        .DDR_0_dqs_n(DDR_0_dqs_n),
        .DDR_0_dqs_p(DDR_0_dqs_p),
        .DDR_0_odt(DDR_0_odt),
        .DDR_0_ras_n(DDR_0_ras_n),
        .DDR_0_reset_n(DDR_0_reset_n),
        .DDR_0_we_n(DDR_0_we_n),
        .FCLK_CLK0_0(FCLK_CLK0_0),
        .FIXED_IO_0_ddr_vrn(FIXED_IO_0_ddr_vrn),
        .FIXED_IO_0_ddr_vrp(FIXED_IO_0_ddr_vrp),
        .FIXED_IO_0_mio(FIXED_IO_0_mio),
        .FIXED_IO_0_ps_clk(FIXED_IO_0_ps_clk),
        .FIXED_IO_0_ps_porb(FIXED_IO_0_ps_porb),
        .FIXED_IO_0_ps_srstb(FIXED_IO_0_ps_srstb),
        .peripheral_aresetn_0(peripheral_aresetn_0)
    );
endmodule
