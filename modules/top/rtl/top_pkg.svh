`ifndef TOP_PKG_SVH
`define TOP_PKG_SVH

package top_pkg;

    localparam logic ILA_EN = 1;
    localparam real CLK_FREQ = 50 * 10 ** 6;
    localparam int SLAVE_NUM = 4;
    localparam int MASTER_NUM = 1;
    localparam int FIFO_DEPTH = 128;

    localparam int SPI_CS_WIDTH = 1;
    localparam int RGMII_WIDTH = 4;

    localparam int AXIL_ADDR_WIDTH = 32;
    localparam int AXIL_DATA_WIDTH = 32;
    localparam int AXIS_DATA_WIDTH = 8;

    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_HIGTH_ADDR = 32'h43c0_ffff;
    localparam logic [AXIL_ADDR_WIDTH-1:0] BASE_LOW_ADDR = 32'h43c0_0000;
    localparam logic [AXIL_ADDR_WIDTH-1:0] ADDR_OFFSET = 32'h0001_0000;

    function automatic logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] get_slave_addr;
        input logic [AXIL_ADDR_WIDTH-1:0] addr;
        begin
            for (int i = 0; i < SLAVE_NUM; i++) begin
                get_slave_addr[i] = addr + i * ADDR_OFFSET;
            end
        end
    endfunction

    localparam logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_HIGH_ADDR = get_slave_addr(
        BASE_HIGTH_ADDR
    );
    localparam logic [SLAVE_NUM-1:0][AXIL_ADDR_WIDTH-1:0] SLAVE_LOW_ADDR = get_slave_addr(
        BASE_LOW_ADDR
    );

endpackage

`endif  // TOP_PKG_SVH
