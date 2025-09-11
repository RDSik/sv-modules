/* verilator lint_off TIMESCALEMOD */
module ram_true_dp #(
    parameter int MEM_DEPTH  = 1024,
    parameter int BYTE_WIDTH = 8,
    parameter int BYTE_NUM   = 4,
    parameter int PIPE_NUM   = 5,
    parameter     MEM_MODE   = "no_change",
    parameter     MEM_TYPE   = "block",
    parameter     MEM_FILE   = "",
    parameter int ADDR_WIDTH = $clog2(MEM_DEPTH),
    parameter int MEM_WIDTH  = BYTE_WIDTH * BYTE_NUM
) (
    input  logic                  a_clk_i,
    input  logic                  a_en_i,
    input  logic                  a_rd_en_i,
    input  logic [  BYTE_NUM-1:0] a_wr_en_i,
    input  logic [ADDR_WIDTH-1:0] a_addr_i,
    input  logic [ MEM_WIDTH-1:0] a_data_i,
    output logic [ MEM_WIDTH-1:0] a_data_o,

    input  logic                  b_clk_i,
    input  logic                  b_en_i,
    input  logic                  b_rd_en_i,
    input  logic [  BYTE_NUM-1:0] b_wr_en_i,
    input  logic [ADDR_WIDTH-1:0] b_addr_i,
    input  logic [ MEM_WIDTH-1:0] b_data_i,
    output logic [ MEM_WIDTH-1:0] b_data_o
);

    logic [MEM_WIDTH-1:0] ram[MEM_DEPTH];

    logic [MEM_WIDTH-1:0] a_data;
    logic [MEM_WIDTH-1:0] b_data;

    if (MEM_FILE != 0) begin : g_mem_file_init
        initial begin
            $readmemh(MEM_FILE, ram);
        end
    end

    if (MEM_MODE == "write_first") begin : g_wr_first
        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (a_wr_en_i[i]) begin
                        ram[a_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= a_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                        a_data <= a_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                    end else begin
                        a_data <= ram[a_addr_i];
                    end
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (b_wr_en_i[i]) begin
                        ram[b_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= b_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                        b_data <= b_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                    end else begin
                        b_data <= ram[b_addr_i];
                    end
                end
            end
        end
    end else if (MEM_MODE == "read_first") begin : g_rd_first
        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                a_data <= ram[a_addr_i];
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (a_wr_en_i[i]) begin
                        ram[a_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= a_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                    end
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                b_data <= ram[b_addr_i];
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (b_wr_en_i[i]) begin
                        ram[b_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= b_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                    end
                end
            end
        end
    end else if (MEM_MODE == "no_change") begin : g_no_change
        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (a_wr_en_i[i]) begin
                        ram[a_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= a_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                    end
                end
            end
        end

        always_ff @(posedge a_clk_i) begin
            if (a_en_i) begin
                if (~|a_wr_en_i) begin
                    a_data <= ram[a_addr_i];
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                for (int i = 0; i < BYTE_NUM; i++) begin
                    if (b_wr_en_i[i]) begin
                        ram[b_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= b_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                    end
                end
            end
        end

        always_ff @(posedge b_clk_i) begin
            if (b_en_i) begin
                if (~|b_wr_en_i) begin
                    b_data <= ram[b_addr_i];
                end
            end
        end
    end else begin : g_mode_err
        $error("Only no_change, read_first and write_first MODE is available!");
    end

    if (MEM_TYPE == "block") begin : g_block_ram
        assign a_data_o = a_data;
        assign b_data_o = b_data;
    end else if (MEM_TYPE == "ultra") begin : g_ultra_ram
        logic [MEM_WIDTH-1:0] a_data_pipe[PIPE_NUM];
        logic a_en_pipe[PIPE_NUM+1];

        always_ff @(posedge a_clk_i) begin
            a_en_pipe[0] <= a_en_i;
            for (int i = 0; i < PIPE_NUM; i++) begin
                a_en_pipe[i+1] <= a_en_pipe[i];
            end
        end

        always_ff @(posedge a_clk_i) begin
            if (a_en_pipe[0]) begin
                a_pipe[0] <= a_data;
            end
        end

        always_ff @(posedge a_clk_i) begin
            for (int i = 0; i < PIPE_NUM - 1; i++) begin
                if (a_en_pipe[i+1]) begin
                    a_pipe[i+1] <= a_pipe[i];
                end
            end
        end

        always_ff @(posedge a_clk_i) begin
            if (a_en_pipe[PIPE_NUM] & a_rd_en_i) begin
                a_data_o <= a_pipe[PIPE_NUM-1];
            end
        end

        logic [MEM_WIDTH-1:0] b_pipe[PIPE_NUM];
        logic b_en_pipe[PIPE_NUM+1];

        always_ff @(posedge a_clk_i) begin
            b_en_pipe[0] <= b_en_i;
            for (int i = 0; i < PIPE_NUM; i++) begin
                b_en_pipe[i+1] <= b_en_pipe[i];
            end
        end

        always_ff @(posedge a_clk_i) begin
            if (b_en_pipe[0]) begin
                b_pipe[0] <= b_data;
            end
        end

        always_ff @(posedge a_clk_i) begin
            for (int i = 0; i < PIPE_NUM - 1; i++) begin
                if (b_en_pipe[i+1]) begin
                    b_pipe[i+1] <= b_pipe[i];
                end
            end
        end

        always_ff @(posedge a_clk_i) begin
            if (b_en_pipe[PIPE_NUM] & b_rd_en_i) begin
                b_data_o <= b_pipe[PIPE_NUM-1];
            end
        end
    end else begin : g_ram_err
        $error("Only ultra and block ram type supported!");
    end

endmodule
