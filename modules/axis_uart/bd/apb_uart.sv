/* verilator lint_off TIMESCALEMOD */
`include "../rtl/uart_pkg.svh"

module apb_uart
    import uart_pkg::*;
#(
    parameter int FIFO_DEPTH      = 128,
    parameter int APB_ADDR_WIDTH  = 32,
    parameter int APB_DATA_WIDTH  = 32,
    parameter int AXIS_DATA_WIDTH = 8
) (
    input  logic uart_rx_i,
    output logic uart_tx_o,

    apb_if.slave s_apb
);

    uart_regs_t uart_regs;

    logic clk_i;
    logic rstn_i;

    assign clk_i  = s_apb.clk_i;
    assign rstn_i = s_apb.rstn_i;

    logic tx_reset;
    logic rx_reset;

    assign tx_reset = ~uart_regs.control.tx_reset;
    assign rx_reset = ~uart_regs.control.rx_reset;

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) fifo_tx (
        .clk_i (clk_i),
        .rstn_i(tx_reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) fifo_rx (
        .clk_i (clk_i),
        .rstn_i(rx_reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) uart_tx (
        .clk_i (clk_i),
        .rstn_i(tx_reset)
    );

    axis_if #(
        .DATA_WIDTH(AXIS_DATA_WIDTH)
    ) uart_rx (
        .clk_i (clk_i),
        .rstn_i(rx_reset)
    );

    // TODO: Add AXIS to APB logic
    logic wr_valid;
    logic rd_valid;
    logic tx_handshake;
    logic rx_handshake;

    assign wr_valid                       = s_apb.psel & s_apb.penable & s_apb.pwrite;
    assign rd_valid                       = s_apb.psel & s_apb.penable & ~s_apb.pwrite;

    assign tx_handshake                   = fifo_tx.tvalid & fifo_tx.tready;
    assign rx_handshake                   = fifo_rx.tvalid & fifo_rx.tready;

    assign uart_regs.status.rx_fifo_empty = ~fifo_rx.tvalid;
    assign uart_regs.status.tx_fifo_empty = ~uart_tx.tvalid;
    assign uart_regs.status.rx_fifo_full  = ~uart_rx.tready;
    assign uart_regs.status.tx_fifo_full  = ~fifo_tx.tready;
    assign uart_regs.status.rsrvd         = '0;

    assign uart_regs.rx.data              = fifo_rx.tdata;
    assign uart_regs.rx.rsrvd             = '0;

    assign fifo_tx.tdata                  = uart_regs.tx.data;
    assign fifo_rx.tready                 = rd_valid && (s_apb.paddr == RX_DATA_REG_ADDR);

    assign s_apb.pslverr                  = '0;

    always_comb begin
        if (rd_valid && (s_apb.paddr == RX_DATA_REG_ADDR)) begin
            s_apb.pready = rx_handshake;
        end else if (wr_valid && (s_apb.paddr == TX_DATA_REG_ADDR)) begin
            s_apb.pready = tx_handshake;
        end else begin
            s_apb.pready = 1'b1;
        end
    end

    always_comb begin
        if (rd_valid) begin
            case (s_apb.paddr)
                CLK_DIVIDER_REG_ADDR: s_apb.prdata = uart_regs.clk_divider;
                CONTROL_REG_ADDR:     s_apb.prdata = uart_regs.control;
                TX_DATA_REG_ADDR:     s_apb.prdata = uart_regs.tx;
                RX_DATA_REG_ADDR:     s_apb.prdata = uart_regs.rx;
                STATUS_REG_ADDR:      s_apb.prdata = uart_regs.status;
                default:              s_apb.prdata = '0;
            endcase
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            uart_regs.clk_divider <= '0;
            uart_regs.control     <= '0;
            uart_regs.tx          <= '0;
        end else begin
            if (wr_valid) begin
                case (s_apb.paddr)
                    CLK_DIVIDER_REG_ADDR: uart_regs.clk_divider <= s_apb.pwdata;
                    CONTROL_REG_ADDR:     uart_regs.control <= s_apb.pwdata;
                    TX_DATA_REG_ADDR:     uart_regs.tx <= s_apb.pwdata;
                    default:              ;
                endcase
            end
        end
    end

    always_ff @(posedge clk_i) begin
        if (~rstn_i) begin
            fifo_tx.tvalid <= 1'b0;
        end else if (tx_handshake) begin
            fifo_tx.tvalid <= 1'b0;
        end else if (wr_valid && (s_apb.paddr == TX_DATA_REG_ADDR)) begin
            fifo_tx.tvalid <= 1'b1;
        end
    end

    axis_uart_tx i_axis_uart_tx (
        .clk_divider_i(uart_regs.clk_divider),
        .parity_odd_i (uart_regs.control.parity_odd),
        .parity_even_i(uart_regs.control.parity_even),
        .uart_tx_o    (uart_tx_o),
        .s_axis       (uart_tx)
    );

    axis_uart_rx i_axis_uart_rx (
        .clk_divider_i(uart_regs.clk_divider),
        .parity_odd_i (uart_regs.control.parity_odd),
        .parity_even_i(uart_regs.control.parity_even),
        .uart_rx_i    (uart_rx_i),
        .parity_err_o (uart_regs.status.parity_err),
        .m_axis       (uart_rx)
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(AXIS_DATA_WIDTH),
        .FIFO_MODE ("sync"),
        .FIFO_TYPE ("distributed")
    ) i_axis_fifo_tx (
        .s_axis(fifo_tx),
        .m_axis(uart_tx)
    );

    axis_fifo_wrap #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .FIFO_WIDTH(AXIS_DATA_WIDTH),
        .FIFO_MODE ("sync"),
        .FIFO_TYPE ("distributed")
    ) i_axis_fifo_rx (
        .s_axis(uart_rx),
        .m_axis(fifo_rx)
    );

endmodule
