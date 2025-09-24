/* verilator lint_off TIMESCALEMOD */
module ram_sp #(
    parameter int MEM_DEPTH    = 64,
    parameter int BYTE_WIDTH   = 8,
    parameter int BYTE_NUM     = 4,
    parameter int READ_LATENCY = 5,
    parameter     MEM_FILE     = "",
    parameter int ADDR_WIDTH   = $clog2(MEM_DEPTH),
    parameter int MEM_WIDTH    = BYTE_WIDTH * BYTE_NUM
) (
    input  logic                  clk_i,
    input  logic                  en_i,
    input  logic [  BYTE_NUM-1:0] wr_en_i,
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

    logic [MEM_WIDTH-1:0] data;

    always_ff @(posedge clk_i) begin
        for (int i = 0; i < BYTE_NUM; i++) begin
            if (en_i & wr_en_i[i]) begin
                ram[addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (en_i) begin
            data <= ram[addr_i];
        end
    end

    if (READ_LATENCY == 0) begin : g_no_read_latency
        assign data_o = data;
    end else begin : g_read_latency
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
                b_data_o <= pipe[READ_LATENCY-1];
            end
        end
    end

endmodule
