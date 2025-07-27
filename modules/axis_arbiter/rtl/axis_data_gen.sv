/* verilator lint_off TIMESCALEMOD */
module axis_data_gen #(
    parameter int MEM_WIDTH = 16,
    parameter int MEM_DEPTH = 66
) (
    input logic start_i,
    input logic stop_i,

    axis_if.master m_axis
);

    localparam int ADDR_WIDTH = $clog2(MEM_DEPTH);

    logic                  clk_i;
    logic                  rstn_i;
    logic                  en;
    logic [ADDR_WIDTH-1:0] addr;
    logic                  addr_done;
    logic [ MEM_WIDTH-1:0] ram_data;
    logic                  m_handshake;

    logic [ MEM_WIDTH-1:0] ram         [MEM_DEPTH];

    initial begin
        for (int i = 0; i < MEM_DEPTH; i++) begin
            ram[i] = $urandom_range(0, (2 ** MEM_WIDTH) - 1);
        end
    end

    assign clk_i  = m_axis.clk_i;
    assign rstn_i = m_axis.rstn_i;

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            en <= 1'b0;
        end else if (stop_i) begin
            en <= 1'b0;
        end else if (start_i) begin
            en <= 1'b1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            addr <= '0;
        end else if (en) begin
            if (m_handshake) begin
                if (addr_done) begin
                    addr <= '0;
                end else begin
                    addr <= addr + 1'b1;
                end
            end
        end
    end

    assign addr_done = (addr == MEM_DEPTH - 1);

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            m_axis.tvalid <= 1'b0;
            m_axis.tlast  <= 1'b0;
        end else if (m_handshake) begin
            m_axis.tvalid <= 1'b0;
            m_axis.tlast  <= 1'b0;
        end else if (en) begin
            m_axis.tvalid <= 1'b1;
            if (addr_done) begin
                m_axis.tlast <= 1'b1;
            end
        end
    end

    always_ff @(posedge clk_i) begin
        ram_data <= ram[addr];
    end

    assign m_axis.tdata = ram_data;
    assign m_handshake  = m_axis.tvalid & m_axis.tready;

endmodule
