/* verilator lint_off TIMESCALEMOD */
/* verilator lint_off WIDTHEXPAND */
module rom #(
    parameter int MEM_DEPTH = 64,
    parameter int MEM_WIDTH = 32,
    parameter     ROM_STYLE = "block",
    parameter     MEM_FILE  = ""
) (
    input  logic                         clk_i,
    input  logic                         rst_i,
    input  logic                         en_i,
    input  logic [$clog2(MEM_DEPTH)-1:0] addr_i,
    output logic [        MEM_WIDTH-1:0] data_o
);

    (* rom_style = ROM_STYLE *) logic [MEM_WIDTH-1:0] rom[MEM_DEPTH];

    initial begin
        $readmemh(MEM_FILE, rom);
    end

    logic [MEM_WIDTH-1:0] data;

    if (ROM_STYLE == "distributed") begin : g_distributed_ram
        assign data_o = rom[addr_i];
    end else if (ROM_STYLE == "block") begin : g_other_ram
        always_ff @(posedge clk_i) begin
            if (rst_i) begin
                data <= '0;
            end else if (en_i) begin
                data <= rom[addr_i];
            end
        end
    end else begin : g_ram_style_err
        $error("Only distributed and block ROM_STYLE is available!");
    end

endmodule
