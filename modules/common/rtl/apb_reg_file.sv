/* verilator lint_off TIMESCALEMOD */
module apb_reg_file #(
    parameter int      REG_DATA_WIDTH = 32,
    parameter int      REG_ADDR_WIDTH = 32,
    parameter int      RD_REG_NUM     = 5,
    parameter int      WR_REG_NUM     = 3,
    parameter type     rd_reg_t       = logic          [RD_REG_NUM-1:0][REG_DATA_WIDTH-1:0],
    parameter type     wr_reg_t       = logic          [WR_REG_NUM-1:0][REG_DATA_WIDTH-1:0],
    parameter rd_reg_t REG_INIT       = '{default: '0}
) (
    input rd_reg_t                  rd_regs_i,
    input logic    [RD_REG_NUM-1:0] rd_valid_i,

    output wr_reg_t                  wr_regs_o,
    output logic    [WR_REG_NUM-1:0] wr_valid_o,

    apb_if.slave s_apb
);

    typedef logic [REG_DATA_WIDTH-1:0] reg_unpack_t[RD_REG_NUM-1:0];

    localparam int BYTE_WIDTH = 8;
    localparam int ADDR_OFFSET = REG_ADDR_WIDTH / BYTE_WIDTH;
    localparam reg_unpack_t REG_INIT_UNPACK = reg_unpack_t'(REG_INIT);

    logic [REG_DATA_WIDTH-1:0] wr_reg[WR_REG_NUM-1:0];
    logic [REG_DATA_WIDTH-1:0] rd_reg[RD_REG_NUM-1:0];
    logic [REG_DATA_WIDTH-1:0] rd_reg_unpack[RD_REG_NUM-1:0];

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_apb.clk_i;
    assign rstn_i = s_apb.rstn_i;

    logic write;
    logic read;

    assign write         = s_apb.psel & s_apb.penable & s_apb.pwrite;
    assign read          = s_apb.psel & s_apb.penable & ~s_apb.pwrite;

    assign rd_reg_unpack = reg_unpack_t'(rd_regs_i);
    assign wr_regs_o     = wr_reg_t'(wr_reg);

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            for (int reg_indx = 0; reg_indx < WR_REG_NUM; reg_indx++) begin
                wr_reg[reg_indx]     <= REG_INIT_UNPACK[reg_indx];
                wr_valid_o[reg_indx] <= 1'b0;
            end
        end else begin
            if (write) begin
                for (int reg_indx = 0; reg_indx < WR_REG_NUM; reg_indx++) begin
                    if (s_apb.paddr == reg_indx * ADDR_OFFSET) begin
                        wr_reg[reg_indx]     <= s_apb.pwdata;
                        wr_valid_o[reg_indx] <= 1'b1;
                    end else begin
                        wr_valid_o[reg_indx] <= 1'b0;
                    end
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            for (int reg_indx = 0; reg_indx < RD_REG_NUM; reg_indx++) begin
                rd_reg[reg_indx] <= REG_INIT_UNPACK[reg_indx];
            end
        end else begin
            for (int reg_indx = 0; reg_indx < RD_REG_NUM; reg_indx++) begin
                if (rd_valid_i[reg_indx]) begin
                    rd_reg[reg_indx] <= rd_reg_unpack[reg_indx];
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (read) begin
            for (int reg_indx = 0; reg_indx < RD_REG_NUM; reg_indx++) begin
                if (s_apb.paddr == reg_indx * ADDR_OFFSET) begin
                    s_apb.prdata <= rd_reg[reg_indx];
                end
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            s_apb.pready <= 1'b0;
        end else begin
            if (read | write) begin
                s_apb.pready <= 1'b1;
            end else begin
                s_apb.pready <= 1'b0;
            end
        end
    end

endmodule
