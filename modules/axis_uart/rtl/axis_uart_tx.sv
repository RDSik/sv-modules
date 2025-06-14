/* verilator lint_off TIMESCALEMOD */
`include "../rtl/axis_uart_pkg.svh"

module axis_uart_tx
    import axis_uart_pkg::*;
(
    input  uart_parity_reg_t      parity_i,
    input  uart_clk_divider_reg_t clk_divider_i,
    output logic                  uart_tx_o,

    axis_if                       s_axis
);

uart_state_e state;

logic [$clog2(DATA_WIDTH)-1:0] bit_cnt;
logic [DIVIDER_WIDTH-1:0]      baud_cnt;
logic [DATA_WIDTH-1:0]         tx_data;
logic                          bit_done;
logic                          baud_done;
logic                          baud_en;
logic                          s_handshake;

always_ff @(posedge s_axis.clk_i or negedge s_axis.arstn_i) begin
    if (~s_axis.arstn_i) begin
        state     <= IDLE;
        uart_tx_o <= '1;
        bit_cnt   <= '0;
        baud_en   <= '0;
    end else begin
        case (state)
            IDLE: begin
                uart_tx_o <= 1'b1;
                if (s_axis.tvalid) begin
                    state   <= START;
                    baud_en <= 1'b1;
                end
            end
            START: begin
                uart_tx_o <= 1'b0;
                if (baud_done) begin
                    state <= DATA;
                end
            end
            DATA: begin
                uart_tx_o <= tx_data[bit_cnt];
                if (baud_done) begin
                    if (bit_done) begin
                        bit_cnt <= '0;
                        if (parity_i != '0) begin
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
                uart_tx_o <= parity(tx_data, parity_i);
                if (baud_done) begin
                    state <= STOP;
                end
            end
            STOP: begin
                uart_tx_o <= 1'b1;
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

always @(posedge s_axis.clk_i or negedge s_axis.arstn_i) begin
    if (~s_axis.arstn_i) begin
        baud_cnt <= '0;
    end else if (baud_done) begin
        baud_cnt <= '0;
    end else if (baud_en) begin
        baud_cnt <= baud_cnt + 1'b1;
    end
end

always_ff @(posedge s_axis.clk_i or negedge s_axis.arstn_i) begin
    if (~s_axis.arstn_i) begin
        tx_data <= '0;
    end else if (s_handshake) begin
        tx_data <= s_axis.tdata;
    end
end

assign s_axis.tready = (state == IDLE);
assign s_handshake   = s_axis.tvalid & s_axis.tready;

/* verilator lint_off WIDTHEXPAND */
assign bit_done  = (bit_cnt == DATA_WIDTH - 1);
assign baud_done = (baud_cnt == clk_divider_i - 1);
/* verilator lint_on WIDTHEXPAND */

endmodule
