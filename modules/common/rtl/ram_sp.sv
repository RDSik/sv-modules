/* verilator lint_off TIMESCALEMOD */
/* verilator lint_off WIDTHEXPAND */
module ram_sp #(
    parameter int MEM_DEPTH  = 64,
    parameter int BYTE_WIDTH = 8,
    parameter int BYTE_NUM   = 4,
    parameter int PIPE_STAGE = 5,
    parameter     RAM_STYLE  = "block",
    parameter     MEM_MODE   = "no_change",
    parameter     MEM_FILE   = "",
    parameter int MEM_WIDTH  = BYTE_WIDTH * BYTE_NUM
) (
    input  logic                         clk_i,
    input  logic                         en_i,
    input  logic [         BYTE_NUM-1:0] wr_en_i,
    input  logic [$clog2(MEM_DEPTH)-1:0] addr_i,
    input  logic [        MEM_WIDTH-1:0] data_i,
    output logic [        MEM_WIDTH-1:0] data_o
);

    if (MEM_WIDTH != BYTE_WIDTH * BYTE_NUM) begin : g_mem_width_err
        $error("MEM_WIDTH must be equal BYTE_WIDTH * BYTE_NUM!");
    end

    (* ram_style = RAM_STYLE *) logic [MEM_WIDTH-1:0] ram[MEM_DEPTH];

    if (MEM_FILE != "") begin : g_mem_file_init
        initial begin
            $readmemh(MEM_FILE, ram);
        end
    end

    logic [MEM_WIDTH-1:0] data;

    always_ff @(posedge clk_i) begin
        for (int i = 0; i < BYTE_NUM; i++) begin
            if (en_i & wr_en_i[i]) begin
                ram[addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
            end
        end
    end

    if (RAM_STYLE == "distributed") begin : g_distributed_ram
        assign data_o = ram[addr_i];
    end else begin : g_other_ram
        if (MEM_MODE == "write_first") begin : g_wr_first
            always_ff @(posedge clk_i) begin
                if (en_i) begin
                    for (int i = 0; i < BYTE_NUM; i++) begin
                        if (wr_en_i[i]) begin
                            data[i*BYTE_WIDTH+:BYTE_WIDTH] <= data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
                        end else begin
                            data[i*BYTE_WIDTH+:BYTE_WIDTH] <= ram[addr_i][i*BYTE_WIDTH+:BYTE_WIDTH];
                        end
                    end
                end
            end
        end else if (MEM_MODE == "read_first") begin : g_rd_first
            always_ff @(posedge clk_i) begin
                if (en_i) begin
                    data <= ram[addr_i];
                end
            end
        end else if (MEM_MODE == "no_change") begin : g_no_change
            always_ff @(posedge clk_i) begin
                if (en_i & ~|wr_en_i) begin
                    data <= ram[addr_i];
                end
            end
        end else begin : g_mode_err
            $error("Only no_change, read_first and write_first MODE is available!");
        end

        if (RAM_STYLE == "block") begin : g_block_ram
            assign data_o = data;
        end else if (RAM_STYLE == "ultra") begin : g_ultra_ram
            logic [MEM_WIDTH-1:0] pipe[PIPE_STAGE];
            logic en_pipe[PIPE_STAGE+1];

            always_ff @(posedge clk_i) begin
                en_pipe[0] <= en_i;
                for (int i = 0; i < PIPE_STAGE; i++) begin
                    en_pipe[i+1] <= en_pipe[i];
                end
            end

            always_ff @(posedge clk_i) begin
                if (en_pipe[0]) begin
                    pipe[0] <= data;
                end
            end

            always_ff @(posedge clk_i) begin
                for (int i = 0; i < PIPE_STAGE - 1; i++) begin
                    if (en_pipe[i+1]) begin
                        pipe[i+1] <= pipe[i];
                    end
                end
            end

            always_ff @(posedge clk_i) begin
                if (en_pipe[PIPE_STAGE]) begin
                    data_o <= pipe[PIPE_STAGE-1];
                end
            end
        end else begin : g_ram_style_err
            $error("Only distributed, block and ultra RAM_STYLE is available!");
        end
    end

endmodule
