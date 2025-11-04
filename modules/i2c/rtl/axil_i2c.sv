/* verilator lint_off TIMESCALEMOD */
`include "../rtl/i2c_pkg.svh"

module axil_i2c
    import i2c_pkg::*;
#(
    parameter int   AXIL_DATA_WIDTH = 32,
    parameter int   AXIL_ADDR_WIDTH = 32,
    parameter logic ILA_EN          = 0
) (
    input  logic scl_pad_i,
    output logic scl_pad_o,
    output logic scl_padoen_o,

    input  logic sda_pad_i,
    output logic sda_pad_o,
    output logic sda_padoen_o,

    axil_if.slave s_axil
);

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_axil.clk_i;
    assign rstn_i = s_axil.rstn_i;

    i2c_regs_t                  rd_regs;
    i2c_regs_t                  wr_regs;

    logic      [   REG_NUM-1:0] rd_valid;
    logic      [   REG_NUM-1:0] wr_valid;

    logic      [DATA_WIDTH-1:0] rx_data;
    logic                       i2c_busy;
    logic                       i2c_al;
    logic                       i2c_ack;
    logic                       cmd_ack;

    always_comb begin
        rd_valid               = '1;
        rd_regs                = wr_regs;

        rd_regs.status.busy    = i2c_busy;
        rd_regs.status.al      = i2c_al;
        rd_regs.status.rx_ack  = i2c_ack;
        rd_regs.status.cmd_ack = cmd_ack;
        rd_regs.rx.data        = rx_data;
    end

    axil_reg_file #(
        .REG_DATA_WIDTH(AXIL_DATA_WIDTH),
        .REG_ADDR_WIDTH(AXIL_ADDR_WIDTH),
        .REG_NUM       (REG_NUM),
        .reg_t         (i2c_regs_t),
        .REG_INIT      (REG_INIT),
        .ILA_EN        (ILA_EN)
    ) i_axil_reg_file (
        .s_axil    (s_axil),
        .rd_regs_i (rd_regs),
        .rd_valid_i(rd_valid),
        .wr_regs_o (wr_regs),
        .rd_req_o  (),
        .wr_valid_o(wr_valid)
    );

    i2c_master_byte_ctrl i_i2c_master_byte_ctrl (
        .clk     (clk_i),
        .rst     (wr_regs.control.core_rst),
        .nReset  ('1),
        .ena     (wr_regs.control.core_en),
        .clk_cnt (wr_regs.clk.prescale),
        .start   (wr_regs.command.start),
        .stop    (wr_regs.command.stop),
        .read    (wr_regs.command.rd),
        .write   (wr_regs.command.wr),
        .ack_in  (wr_regs.command.ack),
        .din     (wr_regs.tx.data),
        .cmd_ack (cmd_ack),
        .ack_out (i2c_ack),
        .dout    (rx_data),
        .i2c_busy(i2c_busy),
        .i2c_al  (i2c_al),
        .scl_i   (scl_pad_i),
        .scl_o   (scl_pad_o),
        .scl_oen (scl_padoen_o),
        .sda_i   (sda_pad_i),
        .sda_o   (sda_pad_o),
        .sda_oen (sda_padoen_o)
    );

endmodule
