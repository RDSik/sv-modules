/* verilator lint_off TIMESCALEMOD */
module axis_uart_rx #(
    parameter int CLK_FREQ   = 27,
    parameter int BAUD_RATE  = 115_200,
    parameter int DATA_WIDTH = 8
) (
    input logic uart_rx_i,

    axis_if     m_axis
);

typedef enum logic [2:0] {
    IDLE  = 3'b000,
    START = 3'b001,
    DATA  = 3'b010,
    STOP  = 3'b011,
    WAIT  = 3'b100
} state_e;

state_e state;

localparam int DIVIDER = (CLK_FREQ*1_000_000)/BAUD_RATE;

logic [$clog2(DATA_WIDTH)-1:0] bit_cnt;
logic [$clog2(DIVIDER)-1:0]    baud_cnt;
logic [DATA_WIDTH-1:0]         rx_data;
logic                          bit_done;
logic                          baud_done;
logic                          start_bit_check;
logic                          m_handshake;

always_ff @(posedge m_axis.clk_i or negedge m_axis.arstn_i) begin
    if (~m_axis.arstn_i) begin
        state   <= IDLE;
        rx_data <= '0;
        bit_cnt <= '0;
    end else begin
        case (state)
            IDLE: begin
                if (~uart_rx_i) begin
                    state <= START;
                end
            end
            START: begin
                if (start_bit_check) begin
                    if (~uart_rx_i) begin
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end
            end
            DATA: begin
                rx_data[bit_cnt] <= uart_rx_i;
                if (baud_done) begin
                    if (bit_done) begin
                        state   <= STOP;
                        bit_cnt <= '0;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end
            end
            STOP: begin
                if (baud_done) begin
                    state <= WAIT;
                end
            end
            WAIT: begin
                state <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

always @(posedge m_axis.clk_i or negedge m_axis.arstn_i) begin
    if (~m_axis.arstn_i) begin
        baud_cnt <= '0;
    end else if (baud_done | start_bit_check) begin
        baud_cnt <= '0;
    end else if ((state == DATA) || (state == START) || (state == STOP)) begin
        baud_cnt <= baud_cnt + 1'b1;
    end
end

always_ff @(posedge m_axis.clk_i or negedge m_axis.arstn_i) begin
    if (~m_axis.arstn_i) begin
        m_axis.tvalid <= '0;
        m_axis.tdata  <= '0;
    end else if (m_handshake) begin
        m_axis.tvalid <= 1'b0;
    end else if (state == WAIT) begin
        m_axis.tvalid <= 1'b1;
        m_axis.tdata  <= rx_data;
    end
end

assign m_handshake = m_axis.tvalid & m_axis.tready;

/* verilator lint_off WIDTHEXPAND */
assign bit_done        = (bit_cnt == DATA_WIDTH - 1);
assign baud_done       = (baud_cnt == DIVIDER - 1);
assign start_bit_check = ((state == START) && (baud_cnt == (DIVIDER/2) - 1));
/* verilator lint_on WIDTHEXPAND */

endmodule
