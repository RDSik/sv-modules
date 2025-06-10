/* verilator lint_off TIMESCALEMOD */
module axis_data_gen #(
    parameter int MEM_WIDTH = 16,
    parameter int MEM_DEPTH = 66,
    parameter     MEM_FILE  = ""
) (
    axis_if m_axis
);

localparam int ADDR_WIDTH = $clog2(MEM_DEPTH);

logic [ADDR_WIDTH-1:0] addr;
logic                  addr_done;
logic [MEM_WIDTH-1:0]  rom_data;
logic                  m_handshake;

always_ff @(posedge m_axis.clk or negedge m_axis.arstn) begin
    if (~m_axis.arstn) begin
        addr <= '0;
    end else if (m_handshake) begin
        if (addr_done) begin
            addr <= '0;
        end else begin
            addr <= addr + 1'b1;
        end
    end
end

assign addr_done = (addr == MEM_DEPTH - 1);

brom #(
    .MEM_FILE  (MEM_FILE  ),
    .MEM_DEPTH (MEM_DEPTH ),
    .MEM_WIDTH (MEM_WIDTH )
) i_rom (
    .clk_i     (m_axis.clk),
    .addr_i    (addr      ),
    .data_o    (rom_data  )
);

always_ff @(posedge m_axis.clk or negedge m_axis.arstn) begin
    if (~m_axis.arstn) begin
        m_axis.tvalid <= 1'b0;
        m_axis.tlast  <= 1'b0;
    end else if (m_handshake) begin
        m_axis.tvalid <= 1'b0;
        m_axis.tlast  <= 1'b0;
    end else begin
        m_axis.tvalid <= 1'b1;
        if (addr_done) begin
            m_axis.tlast <= 1'b1;
        end
    end
end

assign m_axis.tdata = rom_data;
assign m_handshake  = m_axis.tvalid & m_axis.tready;

endmodule
