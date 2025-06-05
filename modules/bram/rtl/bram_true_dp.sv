module bram_true_dp #(
    parameter     MODE       = "NO_CHANGE",
    parameter int BYTE_NUM   = 2,
    parameter int BYTE_WIDTH = 8,
    parameter int MEM_DEPTH  = 64,
    parameter int MEM_WIDTH  = BYTE_NUM * BYTE_WIDTH,
    parameter int ADDR_WIDTH = $clog2(MEM_DEPTH)
) (
    input  logic                  a_clk_i,
    input  logic                  a_rst_i,
    input  logic                  a_en_i,
    input  logic [BYTE_NUM-1:0]   a_wr_en_i,
    input  logic [ADDR_WIDTH-1:0] a_addr_i,
    input  logic [MEM_WIDTH-1:0]  a_data_i,
    output logic [MEM_WIDTH-1:0]  a_data_o,

    input  logic                  b_clk_i,
    input  logic                  b_rst_i,
    input  logic                  b_en_i,
    input  logic [BYTE_NUM-1:0]   b_wr_en_i,
    input  logic [ADDR_WIDTH-1:0] b_addr_i,
    input  logic [MEM_WIDTH-1:0]  b_data_i,
    output logic [MEM_WIDTH-1:0]  b_data_o
);

if ((MODE != "NO_CHANGE") && (MODE != "READ_FIRST")) begin
    $error("Only NO_CHANGE and READ_FIRST modes available!");
end

logic [MEM_WIDTH-1:0] ram [MEM_DEPTH];

always_ff @(posedge a_clk_i) begin
    if (a_en_i) begin
        for (int i = 0; i < BYTE_NUM; i++) begin
            if (a_wr_en_i[i]) begin
                ram[a_addr_i][i*BYTE_WIDTH+:BYTE_WIDTH] <= a_data_i[i*BYTE_WIDTH+:BYTE_WIDTH];
            end
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

if (MODE == "NO_CHANGE") begin : g_no_change
    logic a_rd_en;
    logic b_rd_en;

    always_ff @(posedge a_clk_i) begin
        if (a_rst_i) begin
            a_data_o <= '0;
        end else if (a_en_i) begin
            if (a_rd_en) begin
                a_data_o <= ram[a_addr_i];
            end
        end
    end

    always_ff @(posedge b_clk_i) begin
        if (b_rst_i) begin
            b_data_o <= '0;
        end else if (b_en_i) begin
            if (b_rd_en) begin
                b_data_o <= ram[b_addr_i];
            end
        end
    end

    assign a_rd_en = ~|a_wr_en_i;
    assign b_rd_en = ~|b_wr_en_i;
end else if (MODE == "READ_FIRST") begin : g_read_first
    always_ff @(posedge a_clk_i) begin
        if (a_rst_i) begin
            a_data_o <= '0;
        end else if (a_en_i) begin
            a_data_o <= ram[a_addr_i];
        end
    end

    always_ff @(posedge b_clk_i) begin
        if (b_rst_i) begin
            b_data_o <= '0;
        end else if (b_en_i) begin
            b_data_o <= ram[b_addr_i];
        end
    end
end

endmodule
