/* verilator lint_off TIMESCALEMOD */
`include "../rtl/axis_uart_pkg.svh"

module axis_uart_rx
    import axis_uart_pkg::*;
(
    input logic [DIVIDER_WIDTH-1:0] clk_divider_i,
    input logic                     odd_i,
    input logic                     even_i,
    input logic                     uart_rx_i,

    axis_if                         m_axis
);

uart_state_e state;

logic [$clog2(DATA_WIDTH)-1:0] bit_cnt;
logic [DIVIDER_WIDTH-1:0]      baud_cnt;
logic [DATA_WIDTH-1:0]         rx_data;
logic                          bit_done;
logic                          baud_done;
logic                          baud_en;
logic                          start_bit_check;
logic                          m_handshake;
logic                          parity_bit;
logic                          parity_err;

always_ff @(posedge m_axis.clk_i or negedge m_axis.arstn_i) begin
    if (~m_axis.arstn_i) begin
        state      <= IDLE;
        rx_data    <= '0;
        bit_cnt    <= '0;
        parity_bit <= '0;
        parity_err <= '0;
        baud_en    <= '0;
    end else begin
        case (state)
            IDLE: begin
                parity_bit <= '0;
                parity_err <= '0;
                if (~uart_rx_i) begin
                    state   <= START;
                    baud_en <= 1'b1;
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
                        bit_cnt <= '0;
                        if (odd_i | even_i) begin
                            state <= PARITY;
                        end else begin
                            state <= STOP;
                        end
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end
            end
            PARITY: begin
                parity_bit <= parity(rx_data, odd_i, even_i);
                if (baud_done) begin
                    state      <= STOP;
                    parity_err <= (parity_bit != uart_rx_i);
                end
            end
            STOP: begin
                if (baud_done) begin
                    state   <= WAIT;
                    baud_en <= 1'b0;
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
    end else if (baud_en) begin
        baud_cnt <= baud_cnt + 1'b1;
    end
end

always_ff @(posedge m_axis.clk_i or negedge m_axis.arstn_i) begin
    if (~m_axis.arstn_i) begin
        m_axis.tvalid <= 1'b0;
    end else if (m_handshake) begin
        m_axis.tvalid <= 1'b0;
    end else if ((state == WAIT) && (~parity_err)) begin
        m_axis.tvalid <= 1'b1;
    end
end

always_ff @(posedge m_axis.clk_i) begin
    if ((state == WAIT) && (~parity_err)) begin
        m_axis.tdata <= rx_data;
    end
end

assign m_handshake = m_axis.tvalid & m_axis.tready;

/* verilator lint_off WIDTHEXPAND */
assign bit_done        = (bit_cnt == DATA_WIDTH - 1);
assign baud_done       = (baud_cnt == clk_divider_i - 1);
assign start_bit_check = ((state == START) && (baud_cnt == (clk_divider_i/2) - 1));
/* verilator lint_on WIDTHEXPAND */

endmodule
