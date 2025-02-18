/* verilator lint_off TIMESCALEMOD */
module axis_uart_rx #(
    parameter CLK_FREQ   = 27_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter DATA_WIDTH = 8
)(
    input logic clk_i,
    input logic arstn_i,
    input logic rx_i,

    axis_if.master m_axis
);

localparam RATIO = CLK_FREQ/BAUD_RATE;

logic [$clog2(DATA_WIDTH)-1:0] bit_cnt;
logic [$clog2(RATIO)-1:0]      baud_cnt;
logic [DATA_WIDTH-1:0]         rx_data;
logic                          bit_done;
logic                          baud_done;

enum logic [2:0] {
    IDLE  = 3'b000,
    START = 3'b001,
    DATA  = 3'b010,
    STOP  = 3'b011,
    WAIT  = 3'b100
} state;

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        state  <= IDLE;
        rx_data <= '0;
    end else begin
        case (state)
            IDLE: begin
                if (~rx_i) begin
                    state <= START;
                end
            end
            START: begin
                if (baud_done) begin
                    if (~rx_i) begin
                        state <= DATA;
                    end else begin
                        state <= IDLE;
                    end
                end
            end
            DATA: begin
                rx_data[bit_cnt] <= rx_i;
                if (bit_done) begin
                    state <= STOP;
                end
            end
            STOP: begin
                if (baud_done) begin
                    state <= WAIT;
                end
            end
            WAIT: begin
                state  <= IDLE;
            end
            default: state <= IDLE;
        endcase
    end
end

always @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        baud_cnt <= '0;
    end else if (baud_done) begin
        baud_cnt <= '0;
    end else if ((state == DATA) || (state == START) || (state == STOP)) begin
        baud_cnt <= baud_cnt + 1;
    end
end

always @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        bit_cnt <= '0;
    end else if (bit_done) begin
        bit_cnt <= '0;
    end else if ((state == DATA) && (baud_done)) begin
        bit_cnt <= bit_cnt + 1;
    end
end

always_ff @(posedge clk_i or negedge arstn_i) begin
    if (~arstn_i) begin
        m_axis.tdata <= '0;
    end else if (m_axis.tvalid & m_axis.tready) begin
        m_axis.tdata <= rx_data;
    end
end

assign m_axis.tvalid = (state == STOP) ? 1'b1 : 1'b0;

/* verilator lint_off WIDTHEXPAND */
assign bit_done  = (bit_cnt == DATA_WIDTH - 1) ? 1'b1 : 1'b0;
assign baud_done = ((baud_cnt == RATIO - 1) || ((state == START) && (baud_cnt == (RATIO/2) - 1))) ? 1'b1 : 1'b0;
/* verilator lint_on WIDTHEXPAND */

endmodule
