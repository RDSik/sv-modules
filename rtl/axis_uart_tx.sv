/* verilator lint_off TIMESCALEMOD */
module axis_uart_tx #(
    parameter int CLK_FREQ   = 27,
    parameter int BAUD_RATE  = 115_200,
    parameter int DATA_WIDTH = 8
) (
    output logic uart_tx_o,

    axis_if      s_axis
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
logic [DATA_WIDTH-1:0]         tx_data;
logic                          bit_done;
logic                          baud_done;
logic                          s_handshake;

always_ff @(posedge s_axis.clk_i or negedge s_axis.arstn_i) begin
    if (~s_axis.arstn_i) begin
        state     <= IDLE;
        uart_tx_o <= '0;
        bit_cnt   <= '0;
    end else begin
        case (state)
            IDLE: begin
                uart_tx_o <= 1'b1;
                if (s_axis.tvalid) begin
                    state <= START;
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
                        state   <= STOP;
                        bit_cnt <= '0;
                    end else begin
                        bit_cnt <= bit_cnt + 1'b1;
                    end
                end
            end
            STOP: begin
                uart_tx_o <= 1'b1;
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

always @(posedge s_axis.clk_i or negedge s_axis.arstn_i) begin
    if (~s_axis.arstn_i) begin
        baud_cnt <= '0;
    end else if (baud_done) begin
        baud_cnt <= '0;
    end else if ((state == DATA) || (state == START) || (state == STOP)) begin
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

assign bit_done  = (bit_cnt == DATA_WIDTH - 1);
assign baud_done = (baud_cnt == DIVIDER - 1);

endmodule
