module bram_dp_2clk #(
    parameter int MEM_WIDTH   = 16,
    parameter int MEM_DEPTH   = 64,
    parameter int ADDR_WIDTH  = $clog2(MEM_DEPTH)
) (
    input  logic                  wr_clk_i,
    input  logic                  wr_en_i,
    input  logic [ADDR_WIDTH-1:0] wr_addr_i,
    input  logic [MEM_WIDTH-1:0]  wr_data_i,

    input  logic                  rd_clk_i,
    input  logic                  rd_en_i,
    input  logic [ADDR_WIDTH-1:0] rd_addr_i,
    output logic [MEM_WIDTH-1:0]  rd_data_o
);

logic [MEM_WIDTH-1:0] ram [MEM_DEPTH];

always_ff @(posedge wr_clk_i) begin
    if (wr_en_i) begin
        ram[wr_addr_i] <= wr_data_i;
    end
end

always_ff @(posedge rd_clk_i) begin
    if (rd_en_i) begin
        rd_data_o <= ram[rd_addr_i];
    end
end

endmodule
