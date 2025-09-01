/* verilator lint_off TIMESCALEMOD */
module ram #(
    parameter int MEM_WIDTH  = 16,
    parameter int MEM_DEPTH  = 66,
    parameter     MEM_TYPE   = "distributed",
    parameter     MEM_FILE   = "",
    parameter int ADDR_WIDTH = $clog2(MEM_DEPTH)
) (
    input  logic                  clk_i,
    input  logic                  wr_en_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [ MEM_WIDTH-1:0] data_i,
    output logic [ MEM_WIDTH-1:0] data_o
);

    logic [MEM_WIDTH-1:0] ram[MEM_DEPTH];

    if (MEM_FILE != 0) begin : g_mem_file_init
        initial begin
            $readmemh(MEM_FILE, ram);
        end
    end

    always_ff @(posedge clk_i) begin
        if (wr_en_i) begin
            ram[addr_i] <= data_i;
        end
    end

    if (MEM_TYPE == "block") begin : g_block_ram
        always_ff @(posedge clk_i) begin
            data_o <= ram[addr_i];
        end
    end else if (MEM_TYPE == "distributed") begin : g_distributed_ram
        assign data_o = ram[addr_i];
    end else if (MEM_TYPE == "ultra") begin : g_ultra_ram
        logic [MEM_WIDTH-1:0] ram_pipe[PIPE_NUM];
        logic [MEM_WIDTH-1:0] ram_reg;

        always_ff @(posedge clk_i) begin
            ram_reg <= ram[rd_addr_i];
        end

        always_ff @(posedge clk_i) begin
            ram_pipe[0] <= ram_reg;
            for (int i = 1; i < PIPE_NUM; i++) begin
                ram_pipe[i] <= ram_pipe[i-1];
            end
        end

        always_ff @(posedge clk_i) begin
            data_o <= ram_pipe[PIPE_NUM-1];
        end
    end else begin : g_ram_err
        $error("Only ultra, block and distributed ram type supported!");
    end

endmodule
