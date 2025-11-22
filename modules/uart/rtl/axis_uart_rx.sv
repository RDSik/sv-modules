/* verilator lint_off TIMESCALEMOD */
`include "../rtl/uart_pkg.svh"

module axis_uart_rx
    import uart_pkg::*;
#(
    parameter int DATA_WIDTH    = 8,
    parameter int DIVIDER_WIDTH = 32
) (
    input  logic [DIVIDER_WIDTH-1:0] clk_divider_i,
    input  logic                     parity_odd_i,
    input  logic                     parity_even_i,
    input  logic                     uart_rx_i,
    output logic                     parity_err_o,

    axis_if.master m_axis
);

    localparam int DATA_CNT_WIDTH = $clog2(DATA_WIDTH);

    logic                      clk_i;
    logic                      rst_i;
    logic [DATA_CNT_WIDTH-1:0] bit_cnt;
    logic [ DIVIDER_WIDTH-1:0] baud_cnt;
    logic [    DATA_WIDTH-1:0] rx_data;
    logic                      bit_done;
    logic                      baud_done;
    logic                      baud_en;
    logic                      start_bit_check;
    logic                      m_handshake;
    logic                      parity_bit;

    typedef enum logic [2:0] {
        IDLE   = 3'b000,
        START  = 3'b001,
        DATA   = 3'b010,
        PARITY = 3'b011,
        STOP   = 3'b100,
        WAIT   = 3'b101
    } uart_state_e;

    uart_state_e state;

    assign clk_i = m_axis.clk_i;
    assign rst_i = m_axis.rst_i;

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            state        <= IDLE;
            rx_data      <= '0;
            bit_cnt      <= '0;
            parity_bit   <= '0;
            parity_err_o <= '0;
            baud_en      <= '0;
        end else begin
            case (state)
                IDLE: begin
                    parity_bit   <= '0;
                    parity_err_o <= '0;
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
                            if (parity_odd_i | parity_even_i) begin
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
                    parity_bit <= parity(rx_data, parity_odd_i, parity_even_i);
                    if (baud_done) begin
                        state        <= STOP;
                        parity_err_o <= (parity_bit != uart_rx_i);
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

    always @(posedge clk_i) begin
        if (rst_i) begin
            baud_cnt <= '0;
        end else if (baud_done | start_bit_check) begin
            baud_cnt <= '0;
        end else if (baud_en) begin
            baud_cnt <= baud_cnt + 1'b1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
            m_axis.tvalid <= 1'b0;
        end else if (m_handshake) begin
            m_axis.tvalid <= 1'b0;
        end else if ((state == WAIT) && (~parity_err_o)) begin
            m_axis.tvalid <= 1'b1;
        end
    end

    always_ff @(posedge clk_i) begin
        if (state == WAIT) begin
            m_axis.tdata <= rx_data;
        end
    end

    assign m_handshake     = m_axis.tvalid & m_axis.tready;

    /* verilator lint_off WIDTHEXPAND */
    assign bit_done        = (bit_cnt == DATA_WIDTH - 1);
    assign baud_done       = (baud_cnt == clk_divider_i - 1);
    assign start_bit_check = ((state == START) && (baud_cnt == (clk_divider_i / 2) - 1));
    /* verilator lint_on WIDTHEXPAND */

endmodule
