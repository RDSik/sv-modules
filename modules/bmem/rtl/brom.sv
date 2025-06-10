module brom #(
    parameter int MEM_WIDTH   = 16,
    parameter int MEM_DEPTH   = 66,
    parameter     MEM_FILE    = "",
    parameter int ADDR_WIDTH  = $clog2(MEM_DEPTH)
) (
    input  logic                  clk_i,
    input  logic [ADDR_WIDTH-1:0] addr_i,
    output logic [MEM_WIDTH-1:0]  data_o
);

logic [MEM_WIDTH-1:0] rom [MEM_DEPTH];

initial begin
    $readmemh(MEM_FILE, rom);
end

always_ff @(posedge clk_i) begin
    data_o <= rom[addr_i];
end

endmodule
