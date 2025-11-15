/* verilator lint_off TIMESCALEMOD */
/* verilator lint_off WIDTHEXPAND */
module ram_sp #(
    parameter int MEM_DEPTH    = 64,
    parameter int BYTE_WIDTH   = 8,
    parameter int BYTE_NUM     = 4,
    parameter int READ_LATENCY = 5,
    parameter     RAM_STYLE    = "block",
    parameter     MEM_FILE     = "",
    parameter int MEM_WIDTH    = BYTE_WIDTH * BYTE_NUM
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

    if (MEM_FILE != 0) begin : g_mem_file_init
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

    if (READ_LATENCY == 0) begin : g_distributed_ram
        assign data_o = ram[addr_i];
    end else begin : g_block_ultram_ram
        always_ff @(posedge clk_i) begin
            if (en_i) begin
                data <= ram[addr_i];
            end
        end

        if (READ_LATENCY == 1) begin : g_block_ram
            assign data_o = data;
        end else begin : g_ultra_ram
            logic [MEM_WIDTH-1:0] pipe[READ_LATENCY];
            logic en_pipe[READ_LATENCY+1];

            always_ff @(posedge clk_i) begin
                en_pipe[0] <= en_i;
                for (int i = 0; i < READ_LATENCY; i++) begin
                    en_pipe[i+1] <= en_pipe[i];
                end
            end

            always_ff @(posedge clk_i) begin
                if (en_pipe[0]) begin
                    pipe[0] <= data;
                end
            end

            always_ff @(posedge clk_i) begin
                for (int i = 0; i < READ_LATENCY - 1; i++) begin
                    if (en_pipe[i+1]) begin
                        pipe[i+1] <= pipe[i];
                    end
                end
            end

            always_ff @(posedge clk_i) begin
                if (en_pipe[READ_LATENCY]) begin
                    data_o <= pipe[READ_LATENCY-1];
                end
            end
        end
    end

endmodule
