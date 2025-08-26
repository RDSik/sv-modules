/* verilator lint_off TIMESCALEMOD */
module bram_true_dp #(
    parameter int MEM_WIDTH  = 32,
    parameter int MEM_DEPTH  = 1024,
    parameter     MODE       = "NO_CHANGE",
    parameter     MEM_FILE   = "",
    parameter int ADDR_WIDTH = $clog2(MEM_DEPTH),
    parameter int BYTE_NUM  = MEM_WIDTH / 8
) (
    input  logic                  a_clk_i,
    input  logic                  a_en_i,
    input  logic [  BYTE_NUM-1:0] a_wr_en_i,
    input  logic [ADDR_WIDTH-1:0] a_addr_i,
    input  logic [ MEM_WIDTH-1:0] a_data_i,
    output logic [ MEM_WIDTH-1:0] a_data_o,

    input  logic                  b_clk_i,
    input  logic                  b_en_i,
    input  logic [  BYTE_NUM-1:0] b_wr_en_i,
    input  logic [ADDR_WIDTH-1:0] b_addr_i,
    input  logic [ MEM_WIDTH-1:0] b_data_i,
    output logic [ MEM_WIDTH-1:0] b_data_o
);

    logic [MEM_WIDTH-1:0] ram[MEM_DEPTH];

    initial begin
        if (MEM_FILE != 0) begin
            $readmemh(MEM_FILE, ram);
        end else begin
            for (int i = 0; i < MEM_DEPTH; i++) begin
                ram[i] = '0;
            end
        end
    end

    if (MODE == "WRITE_FIRST") begin : g_wr_first
        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (a_wr_en_i[i]) begin
                        ram[a_addr_i][i*8+:8] <= a_data_i[i*8+:8];
                        a_data_o              <= a_data_i[i*8+:8];
                    end else begin
                        a_data_o <= ram[a_addr_i];
                    end
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (b_wr_en_i[i]) begin
                        ram[b_addr_i][i*8+:8] <= b_data_i[i*8+:8];
                        b_data_o              <= b_data_i[i*8+:8];
                    end else begin
                        b_data_o <= ram[b_addr_i];
                    end
                end
            end
        end
    end else if (MODE == "READ_FIRST") begin : g_rd_first
        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                a_data_o <= ram[a_addr_i];
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (a_wr_en_i[i]) begin
                        ram[a_addr_i][i*8+:8] <= a_data_i[i*8+:8];
                    end
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                b_data_o <= ram[b_addr_i];
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (b_wr_en_i[i]) begin
                        ram[b_addr_i][i*8+:8] <= b_data_i[i*8+:8];
                    end
                end
            end
        end
    end else if (MODE == "NO_CHANGE") begin : g_no_change
        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (a_wr_en_i[i]) begin
                        ram[a_addr_i][i*8+:8] <= a_data_i[i*8+:8];
                    end
                end
            end
        end

        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                if (~|a_wr_en_i) begin
                    a_data_o <= ram[a_addr_i];
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (b_wr_en_i[i]) begin
                        ram[b_addr_i][i*8+:8] <= b_data_i[i*8+:8];
                    end
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                if (~|b_wr_en_i) begin
                    b_data_o <= ram[b_addr_i];
                end
            end
        end
    end else begin : g_mode_err
        $error("Only NO_CHANGE, READ_FIRST and WRITE_FIRST MODE is available!");
    end

endmodule
