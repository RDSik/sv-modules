`timescale 1ns/1ps

module axis_uart_bridge_tb();

localparam int FIFO_DEPTH = 512;
localparam int MEM_DEPTH  = 8192;
localparam int BYTE_NUM   = 4;
localparam int BYTE_WIDTH = 8;
localparam int ADDR_WIDTH = 32;
localparam int MEM_WIDTH  = BYTE_NUM * BYTE_WIDTH;

localparam int CLK_PER_NS  = 2;
localparam int RESET_DELAY = 10;
localparam int CTRL_DELAY  = 4;

logic                  clk_i;
logic                  arstn_i;
logic                  uart;
logic                  en_i;
logic [BYTE_NUM-1:0]   wr_en_i;
logic [ADDR_WIDTH-1:0] addr_i;
logic [MEM_WIDTH-1:0]  data_i;
logic [MEM_WIDTH-1:0]  data_o;

initial begin
    arstn_i = 1'b0;
    repeat (RESET_DELAY) @(posedge clk_i);
    arstn_i = 1'b1;
    $display("Reset done in: %0t ns\n.", $time());
end

initial begin
    clk_i = 1'b0;
    forever begin
        #(CLK_PER_NS/2) clk_i = ~clk_i;
    end
end

initial begin
    wait (arstn_i);
    write_data(4, 32'ha, 1);
    write_data(12, 32'hfc, 1);
    write_data(8, 32'h3, 1);
    write_data(0, 2, CTRL_DELAY+2);
    write_data(8, 32'h4, CTRL_DELAY);
    write_data(0, 2, CTRL_DELAY);
    for (int i = 1; i <= 4; i++) begin
        write_data(0, i, CTRL_DELAY);
    end
    read_data(16, 200);
    $stop;
end

initial begin
    $dumpfile("axis_uart_bridge_tb.vcd");
    $dumpvars(0, axis_uart_bridge_tb);
end

task static write_data;
    input logic [ADDR_WIDTH-1:0] addr;
    input logic [MEM_WIDTH-1:0] data;
    input int delay;
    begin
        en_i    = '1;
        wr_en_i = '1;
        data_i  = data;
        addr_i  = addr;
        @(posedge clk_i);
        en_i    = '0;
        wr_en_i = '0;
        repeat (delay) @(posedge clk_i);
        $display("%t: address: 0x%0h data_write: 0x%0h", $time, addr, data);
    end
endtask

task static read_data;
    input logic [ADDR_WIDTH-1:0] addr;
    input int delay;
    begin
        en_i    = '1;
        wr_en_i = '0;
        addr_i  = addr;
        repeat (delay) @(posedge clk_i);
        en_i = 1'b0;
        $display("%t: address: 0x%0h data_read: 0x%0h", $time, addr, data_o);
    end
endtask

axis_uart_bridge #(
    .FIFO_DEPTH (FIFO_DEPTH),
    .MEM_DEPTH  (MEM_DEPTH ),
    .BYTE_NUM   (BYTE_NUM  ),
    .BYTE_WIDTH (BYTE_WIDTH),
    .ADDR_WIDTH (ADDR_WIDTH),
    .SIM_EN     (1         )
) dut (
    .clk_i      (clk_i     ),
    .arstn_i    (arstn_i   ),
    .uart_rx_i  (uart      ),
    .uart_tx_o  (uart      ),
    .en_i       (en_i      ),
    .wr_en_i    (wr_en_i   ),
    .addr_i     (addr_i    ),
    .data_i     (data_i    ),
    .data_o     (data_o    )
);

endmodule
