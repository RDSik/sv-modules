/* verilator lint_off TIMESCALEMOD */
module ram #(
    parameter int MEM_WIDTH  = 16,
    parameter int MEM_DEPTH  = 66,
    parameter     MEM_TYPE   = "distributed",
    parameter     MEM_FILE   = "",
    parameter int ADDR_WIDTH = $clog2(MEM_DEPTH)
) (
    input  logic                  clk_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    input  logic [ MEM_WIDTH-1:0] data_i,
    output logic [ MEM_WIDTH-1:0] data_o
);

    logic [MEM_WIDTH-1:0] ram[MEM_DEPTH];

    initial begin
        if (MEM_FILE != 0) begin
            $readmemh(MEM_FILE, ram);
        end
    end

    always_ff @(posedge clk_i) begin
        ram[addr_i] <= data_i;
    end

    if (MEM_TYPE == "block") begin : g_block_ram
        always_ff @(posedge clk_i) begin
            data_o <= ram[addr_i];
        end
    end else if (MEM_TYPE == "distributed") begin : g_distributed_ram
        assign data_o = ram[addr_i];
    end else begin : g_ram_err
        $error("Only block and distributed ram type supported!");
    end

endmodule
