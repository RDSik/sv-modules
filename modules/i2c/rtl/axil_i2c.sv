/* verilator lint_off TIMESCALEMOD */
module axil_i2c #(
    parameter int DATA_WIDTH = 32,
    parameter int ADDR_WIDTH = 32
) (
    input  logic scl_pad_i,
    output logic scl_pad_o,
    output logic scl_padoen_o,

    input  logic sda_pad_i,
    output logic sda_pad_o,
    output logic sda_padoen_o,

    axil_if.slave s_axil
);

    localparam int REG_NUM = 5;
    localparam int ADDR_LSB = DATA_WIDTH / 32 + 1;
    localparam int ADDR_MSB = ADDR_LSB + $clog2(REG_NUM);

    wb_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) m_wb (
        .clk_i(s_axil.clk_i),
        .rst_i(~s_axil.rstn_i)
    );

    axil2wb_bridge i_axil2wb_bridge (
        .s_axil(s_axil),
        .m_wb  (m_wb)
    );

    i2c_master_top i_i2c_master_top (
        .wb_clk_i    (m_wb.clk_i),
        .wb_rst_i    (m_wb.rst_i),
        .arst_i      ('1),
        .wb_adr_i    (m_wb.adr[ADDR_MSB:ADDR_LSB]),
        .wb_dat_i    (m_wb.wdat),
        .wb_dat_o    (m_wb.rdat),
        .wb_we_i     (m_wb.we),
        .wb_stb_i    (m_wb.stb),
        .wb_cyc_i    (m_wb.cyc),
        .wb_ack_o    (m_wb.ack),
        .wb_inta_o   (m_wb.inta),
        .scl_pad_i   (scl_pad_i),
        .scl_pad_o   (scl_pad_o),
        .scl_padoen_o(scl_padoen_o),
        .sda_pad_i   (sda_pad_i),
        .sda_pad_o   (sda_pad_o),
        .sda_padoen_o(sda_padoen_o)
    );

endmodule
